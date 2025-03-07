"""Utilities for working with agent hierarchies."""

from typing import Dict, Optional


def print_hierarchy_tree(
    hierarchy: Dict,
    root_id: Optional[str] = None,
    indent: int = 0
) -> None:
    """
    Print the hierarchy tree in a human-readable format.
    
    Args:
        hierarchy: The hierarchy dictionary.
        root_id: The ID of the root node. If None, print all root nodes.
        indent: The indentation level for recursive output.
    """
    # Helper function to print a node
    def print_node(node_id: str, indent_level: int) -> None:
        node_info = hierarchy.get(node_id)
        if not node_info:
            print(" " * indent_level + f"[Invalid node: {node_id}]")
            return
        
        # Print node information
        llm_info = f" (LLM: {node_info.get('llm_id', 'default')})" if node_info.get('llm_id') else ""
        print(" " * indent_level + f"[{node_info.get('type', 'unknown')}] {node_info.get('name', node_id)}{llm_info}")
        
        # Print children recursively
        for child_id in node_info.get("children", []):
            print_node(child_id, indent_level + 2)
    
    if root_id is None:
        # Find root nodes (nodes without parents)
        root_nodes = [
            node_id for node_id, info in hierarchy.items() 
            if info.get("parent") is None
        ]
        
        # Print each root node
        for node_id in root_nodes:
            print_node(node_id, indent)
    else:
        # Print the specified root node
        print_node(root_id, indent)


def generate_mermaid_diagram(
    hierarchy: Dict,
    root_id: Optional[str] = None,
    title: str = "Agent Hierarchy"
) -> str:
    """
    Generate a Mermaid diagram for visualizing the agent hierarchy.
    
    Args:
        hierarchy: The hierarchy dictionary.
        root_id: The ID of the root node. If None, include all root nodes.
        title: The title of the diagram.
        
    Returns:
        A Mermaid diagram as a string.
    """
    mermaid_lines = ["graph TD", f"    title{title.replace(' ', '_')}[\"<b>{title}</b>\"]", "    classDef default fill:#f9f9f9,stroke:#333,stroke-width:1px;", "    classDef agent fill:#d4f1f9,stroke:#1a6ee4,stroke-width:1px;", "    classDef supervisor fill:#ffe6cc,stroke:#d79b00,stroke-width:1px;", ""]
    
    # Helper function to add a node and its connections
    def add_node(node_id: str, is_root: bool = False) -> None:
        node_info = hierarchy.get(node_id)
        if not node_info:
            return
        
        # Add node
        node_type = node_info.get("type", "unknown")
        node_name = node_info.get("name", node_id)
        llm_id = node_info.get("llm_id", "")
        llm_display = f"<br><i>LLM: {llm_id}</i>" if llm_id else ""
        
        mermaid_lines.append(f"    {node_id}[\"{node_name}{llm_display}\"]")
        mermaid_lines.append(f"    class {node_id} {node_type};")
        
        # Connect to title if root
        if is_root:
            mermaid_lines.append(f"    title{title.replace(' ', '_')} --> {node_id}")
        
        # Add connections to children
        for child_id in node_info.get("children", []):
            mermaid_lines.append(f"    {node_id} --> {child_id}")
            add_node(child_id)
    
    if root_id is None:
        # Find root nodes (nodes without parents)
        root_nodes = [
            node_id for node_id, info in hierarchy.items() 
            if info.get("parent") is None
        ]
        
        # Add each root node
        for node_id in root_nodes:
            add_node(node_id, is_root=True)
    else:
        # Add the specified root node
        add_node(root_id, is_root=True)
    
    return "\n".join(mermaid_lines)
