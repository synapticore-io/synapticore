to use from the registry.
            prompt: The prompt for the supervisor.
            tools: Additional tools for the supervisor.
            output_mode: Mode for adding agent outputs to the message history.
            add_handoff_back_messages: Whether to add handoff messages.
            
        Returns:
            The ID of the created supervisor.
            
        Raises:
            ValueError: If a supervisor with the name already exists.
            ValueError: If no LLM ID is provided and no default LLM is set.
            ValueError: If the specified LLM is not registered.
            ValueError: If a specified agent does not exist.
        """
        if name in self._supervisors:
            raise ValueError(f"Supervisor with name '{name}' already exists.")
        
        used_llm_id = llm_id or self.default_llm_id
        if used_llm_id is None:
            raise ValueError(
                "No LLM ID provided and no default LLM set. "
                "Please provide an LLM ID or set a default LLM."
            )
        
        # Get the LLM from the registry
        try:
            llm = self.llm_registry.get(used_llm_id)
        except ValueError as e:
            raise ValueError(f"Error retrieving LLM: {str(e)}")
        
        agents = []
        for agent_id in agent_ids:
            if agent_id in self._agents:
                agents.append(self._agents[agent_id])
            elif agent_id in self._compiled_workflows:
                agents.append(self._compiled_workflows[agent_id])
            else:
                raise ValueError(f"Agent or workflow with ID '{agent_id}' does not exist.")
        
        supervisor = create_supervisor(
            agents=agents,
            model=llm,
            tools=tools,
            prompt=prompt,
            state_schema=self.state_schema,
            config_schema=self.config_schema,
            output_mode=output_mode or self.default_output_mode,
            add_handoff_back_messages=add_handoff_back_messages,
            supervisor_name=name,
            include_agent_name=self.include_agent_name,
        )
        
        supervisor_id = name
        self._supervisors[supervisor_id] = supervisor
        self._hierarchy[supervisor_id] = {
            "type": "supervisor",
            "name": name,
            "llm_id": used_llm_id,
            "children": agent_ids,
            "parent": None
        }
        
        # Update hierarchy information for children
        for agent_id in agent_ids:
            if agent_id in self._hierarchy:
                self._hierarchy[agent_id]["parent"] = supervisor_id
        
        return supervisor_id
    
    def compile(
        self, 
        supervisor_id: str, 
        checkpointer=None, 
        store=None
    ) -> str:
        """
        Compile a supervisor workflow for execution.
        
        Args:
            supervisor_id: The ID of the supervisor to compile.
            checkpointer: An optional checkpointer for persistence.
            store: An optional store for persistence.
            
        Returns:
            The ID of the compiled workflow.
            
        Raises:
            ValueError: If the supervisor does not exist.
        """
        if supervisor_id not in self._supervisors:
            raise ValueError(f"Supervisor with ID '{supervisor_id}' does not exist.")
        
        supervisor = self._supervisors[supervisor_id]
        compiled = supervisor.compile(
            name=supervisor_id,
            checkpointer=checkpointer,
            store=store,
        )
        
        self._compiled_workflows[supervisor_id] = compiled
        return supervisor_id
    
    def invoke(self, workflow_id: str, input_data: Union[str, List[BaseMessage], Dict[str, Any]]) -> Dict[str, Any]:
        """
        Execute a compiled workflow with given input.
        
        Args:
            workflow_id: The ID of the workflow to execute.
            input_data: The input for the workflow. Can be a string, a list of messages, 
                       or a dictionary with complete state.
            
        Returns:
            The result of the workflow execution.
            
        Raises:
            ValueError: If the workflow does not exist.
        """
        if workflow_id not in self._compiled_workflows:
            raise ValueError(f"Compiled workflow with ID '{workflow_id}' does not exist.")
        
        workflow = self._compiled_workflows[workflow_id]
        
        # Prepare input
        if isinstance(input_data, str):
            # If input is a string, convert to a HumanMessage
            messages = [HumanMessage(content=input_data)]
            state = {"messages": messages}
        elif isinstance(input_data, list) and all(isinstance(m, BaseMessage) for m in input_data):
            # If input is a list of messages
            state = {"messages": input_data}
        elif isinstance(input_data, dict):
            # If input is a complete state
            state = input_data
        else:
            raise ValueError(f"Invalid input format: {type(input_data)}. "
                            "Must be a string, a list of messages, or a state dictionary.")
        
        return workflow.invoke(state)
    
    async def ainvoke(self, workflow_id: str, input_data: Union[str, List[BaseMessage], Dict[str, Any]]) -> Dict[str, Any]:
        """
        Execute a compiled workflow asynchronously with given input.
        
        Args:
            workflow_id: The ID of the workflow to execute.
            input_data: The input for the workflow. Can be a string, a list of messages, 
                       or a dictionary with complete state.
            
        Returns:
            The result of the workflow execution.
            
        Raises:
            ValueError: If the workflow does not exist.
        """
        if workflow_id not in self._compiled_workflows:
            raise ValueError(f"Compiled workflow with ID '{workflow_id}' does not exist.")
        
        workflow = self._compiled_workflows[workflow_id]
        
        # Prepare input
        if isinstance(input_data, str):
            # If input is a string, convert to a HumanMessage
            messages = [HumanMessage(content=input_data)]
            state = {"messages": messages}
        elif isinstance(input_data, list) and all(isinstance(m, BaseMessage) for m in input_data):
            # If input is a list of messages
            state = {"messages": input_data}
        elif isinstance(input_data, dict):
            # If input is a complete state
            state = input_data
        else:
            raise ValueError(f"Invalid input format: {type(input_data)}. "
                            "Must be a string, a list of messages, or a state dictionary.")
        
        return await workflow.ainvoke(state)
    
    def get_agent(self, agent_id: str) -> Pregel:
        """
        Get the agent with the specified ID.
        
        Args:
            agent_id: The ID of the agent.
            
        Returns:
            The agent.
            
        Raises:
            ValueError: If the agent does not exist.
        """
        if agent_id in self._agents:
            return self._agents[agent_id]
        elif agent_id in self._compiled_workflows:
            return self._compiled_workflows[agent_id]
        else:
            raise ValueError(f"Agent or workflow with ID '{agent_id}' does not exist.")
    
    def get_hierarchy(self, root_id: Optional[str] = None) -> Dict:
        """
        Get the hierarchy of agents, starting from the specified root.
        
        Args:
            root_id: The ID of the root. If None, return the entire hierarchy.
            
        Returns:
            The hierarchy as a nested dictionary.
        """
        if root_id is None:
            # Find all root supervisors (those without parents)
            roots = {
                id: info for id, info in self._hierarchy.items() 
                if info["parent"] is None
            }
            
            if len(roots) == 1:
                # If there's only one root, return its hierarchy
                root_id = next(iter(roots.keys()))
                return self._build_hierarchy_tree(root_id)
            else:
                # If there are multiple roots, return the entire hierarchy
                return {
                    id: self._build_hierarchy_tree(id) 
                    for id in roots.keys()
                }
        else:
            # Return the hierarchy for the specified root
            if root_id not in self._hierarchy:
                raise ValueError(f"Agent or supervisor with ID '{root_id}' does not exist.")
                
            return self._build_hierarchy_tree(root_id)
    
    def _build_hierarchy_tree(self, node_id: str) -> Dict:
        """
        Build a hierarchy tree recursively, starting from the specified node.
        
        Args:
            node_id: The ID of the starting node.
            
        Returns:
            The hierarchy tree as a nested dictionary.
        """
        node_info = self._hierarchy[node_id]
        result = {
            "type": node_info["type"],
            "name": node_info["name"],
            "llm_id": node_info.get("llm_id", ""),
        }
        
        if node_info["children"]:
            result["children"] = {
                child_id: self._build_hierarchy_tree(child_id)
                for child_id in node_info["children"]
            }
        
        return result
    
    def print_hierarchy(self, root_id: Optional[str] = None, indent: int = 0) -> None:
        """
        Print the hierarchy in a readable format.
        
        Args:
            root_id: The ID of the root. If None, print the entire hierarchy.
            indent: The indentation level for recursive output.
        """
        print_hierarchy_tree(self._hierarchy, root_id, indent)
    
    def visualize_hierarchy(self, root_id: Optional[str] = None, title: str = "Agent Hierarchy") -> str:
        """
        Generate a Mermaid diagram to visualize the agent structure.
        
        Args:
            root_id: The ID of the root. If None, visualize the entire hierarchy.
            title: The title of the diagram.
            
        Returns:
            A Mermaid diagram as a string.
        """
        return generate_mermaid_diagram(self._hierarchy, root_id, title)
    
    async def register_mcp_client(
        self,
        server_id: str,
        connection_params: Union[StdioConnection, SSEConnection],
    ) -> None:
        """
        Register and connect an MCP client.
        
        Args:
            server_id: A unique ID for the server.
            connection_params: Parameters for the connection.
            
        Raises:
            ValueError: If the server is already registered.
        """
        transport = connection_params.get("transport")
        if transport == "stdio":
            self.mcp_manager.register_stdio_server(
                server_id=server_id,
                command=connection_params["command"],
                args=connection_params["args"],
                env=connection_params.get("env"),
                encoding=connection_params.get("encoding", "utf-8"),
                encoding_error_handler=connection_params.get("encoding_error_handler", "strict"),
            )
        elif transport == "sse":
            self.mcp_manager.register_sse_server(
                server_id=server_id,
                url=connection_params["url"],
            )
        else:
            raise ValueError(f"Unknown transport type: {transport}")
        
        # Initialize the MCP manager if it's not already initialized
        if not self.mcp_manager.is_initialized:
            await self.mcp_manager.initialize()
EOL

    cat > "$PROJECT_NAME/agents/__init__.py" << 'EOL'
"""Agents and supervisors for hierarchical structures."""

from hierarchical_agent_manager.agents.manager import AgentManager

__all__ = ["AgentManager"]
EOL
    
    echo -e "Agent Manager module created.\n"
}

# Create a basic example
create_example() {
    echo -e "${GREEN}Creating example...${NC}"
    
    cat > "$PROJECT_NAME/examples/complex_hierarchy.py" << 'EOL'
"""Example of a complex agent hierarchy with different LLMs and MCP tools."""

import asyncio
from typing import List, Tuple

from langchain_core.tools import BaseTool, tool

from hierarchical_agent_manager import AgentManager, LLMRegistry, MCPManager


# Define tool functions
@tool
def add(a: float, b: float) -> float:
    """Add two numbers."""
    return a + b

@tool
def multiply(a: float, b: float) -> float:
    """Multiply two numbers."""
    return a * b

@tool
def web_search(query: str) -> str:
    """Search the web for information."""
    return (
        "Here are the employee counts for FAANG companies in 2024:\n"
        "1. **Facebook (Meta)**: 67,317 employees.\n"
        "2. **Apple**: 164,000 employees.\n"
        "3. **Amazon**: 1,551,000 employees.\n"
        "4. **Netflix**: 14,000 employees.\n"
        "5. **Google (Alphabet)**: 181,269 employees."
    )

@tool
def write_report(content: str) -> str:
    """Write a report with the specified content."""
    return f"Report created: {content}"

@tool
def format_document(content: str, style: str) -> str:
    """Format a document according to the specified style."""
    return f"Document formatted in '{style}' style: {content}"


async def main():
    # Initialize LLM Registry
    llm_registry = LLMRegistry()
    
    # Register OpenAI and Anthropic models
    try:
        llm_registry.register_openai("gpt-4", model="gpt-4o")
        llm_registry.register_anthropic("claude", model="claude-3-sonnet-20240229")
        print("LLM models successfully registered.")
    except ImportError as e:
        print(f"Error registering models: {e}")
        print("Please install the required packages.")
        return
    
    # Create Agent Manager
    manager = AgentManager(
        llm_registry=llm_registry,
        include_agent_name="inline",
        default_llm_id="gpt-4",  # Default LLM for agents without explicit LLM
    )
    
    print("1. Creating specialized agents...")
    # Create specialized agents
    math_agent_id = manager.create_agent(
        name="math_expert",
        llm_id="gpt-4",
        tools=[add, multiply],
        prompt="You are a mathematics expert. Always use one tool at a time."
    )
    
    research_agent_id = manager.create_agent(
        name="research_expert",
        llm_id="claude",  # Use Claude for this agent
        tools=[web_search],
        prompt="You are a world-class researcher with access to web search. Do not perform mathematical calculations."
    )
    
    writing_agent_id = manager.create_agent(
        name="writing_expert",
        tools=[write_report],
        prompt="You are an expert report writer. Use clear and precise language."
    )
    
    formatting_agent_id = manager.create_agent(
        name="formatting_expert",
        tools=[format_document],
        prompt="You are a document formatting expert. Follow best practices for the specified format."
    )
    
    print("2. Creating team supervisors...")
    # Create the first hierarchy level with two supervisor teams
    research_team_id = manager.create_supervisor(
        name="research_team",
        agent_ids=[research_agent_id, math_agent_id],
        llm_id="claude",  # Use Claude for this supervisor
        prompt=(
            "You are a team leader managing a research team and a mathematics expert. "
            "For current events and data research, use the research_expert. "
            "For mathematical problems, use the math_expert."
        )
    )
    
    content_team_id = manager.create_supervisor(
        name="content_team",
        agent_ids=[writing_agent_id, formatting_agent_id],
        prompt=(
            "You are a team leader managing a content production team. "
            "For writing reports, use the writing_expert. "
            "For formatting documents, use the formatting_expert."
        )
    )
    
    print("3. Compiling team workflows...")
    # Compile the team workflows
    manager.compile(research_team_id)
    manager.compile(content_team_id)
    
    print("4. Creating top-level supervisor...")
    # Create a top-level supervisor that manages both teams
    top_level_id = manager.create_supervisor(
        name="project_director",
        agent_ids=[research_team_id, content_team_id],
        prompt=(
            "You are the project director, managing both the research team and the content team. "
            "Use the research_team for information gathering and data analysis. "
            "Use the content_team for creating and formatting reports."
        )
    )
    
    print("5. Compiling top-level workflow...")
    # Compile the top-level workflow
    manager.compile(top_level_id)
    
    print("\nAgent system hierarchy:")
    manager.print_hierarchy()
    
    print("\nMermaid diagram for visualizing hierarchy:")
    mermaid_diagram = manager.visualize_hierarchy(title="Complex Agent Hierarchy")
    print(mermaid_diagram)
    
    print("\n6. Executing a sample query...")
    # Execute a sample query
    query = "Create a brief report on the total employee count of FAANG companies in 2024. Calculate the sum and show the percentage each company makes up."
    
    try:
        # Execute the top-level workflow
        result = manager.invoke(top_level_id, query)
        
        print("\nQuery result:")
        if "messages" in result:
            for message in result["messages"]:
                print(f"[{message.type}] {message.content}")
        else:
            print(result)
            
    except Exception as e:
        print(f"Error during execution: {e}")


if __name__ == "__main__":
    asyncio.run(main())
EOL
    
    echo -e "Example created.\n"
}

# Create basic test files
create_tests() {
    echo -e "${GREEN}Creating basic tests...${NC}"
    
    cat > "$PROJECT_NAME/tests/test_llm_registry.py" << 'EOL'
"""Tests for the LLM Registry."""

import unittest
from unittest.mock import MagicMock, patch

from hierarchical_agent_manager.llms import LLMRegistry


class TestLLMRegistry(unittest.TestCase):
    """Tests for the LLMRegistry class."""
    
    def setUp(self):
        """Initialize before each test."""
        self.registry = LLMRegistry()
        
    def test_register_and_get(self):
        """Test registering and retrieving a model."""
        mock_model = MagicMock()
        
        # Register a model
        self.registry.register("test_model", mock_model)
        
        # Get the model back
        retrieved_model = self.registry.get("test_model")
        
        # Check if it's the same model
        self.assertEqual(retrieved_model, mock_model)
        
    def test_list_models(self):
        """Test listing all models."""
        mock_model1 = MagicMock()
        mock_model2 = MagicMock()
        
        # Register two models
        self.registry.register("model1", mock_model1)
        self.registry.register("model2", mock_model2)
        
        # Get the list of all models
        models = self.registry.list_models()
        
        # Check if both models are in the list
        self.assertEqual(len(models), 2)
        self.assertIn("model1", models)
        self.assertIn("model2", models)
        self.assertEqual(models["model1"], mock_model1)
        self.assertEqual(models["model2"], mock_model2)
        
    def test_register_duplicate(self):
        """Test registering a model with an already used ID."""
        mock_model = MagicMock()
        
        # Register a model
        self.registry.register("test_model", mock_model)
        
        # Try to register a model with the same ID
        with self.assertRaises(ValueError):
            self.registry.register("test_model", mock_model)
            
    def test_get_nonexistent(self):
        """Test retrieving a non-registered model."""
        # Try to get a non-registered model
        with self.assertRaises(ValueError):
            self.registry.get("nonexistent_model")
EOL

    cat > "$PROJECT_NAME/tests/test_agent_manager.py" << 'EOL'
"""Tests for the Agent Manager."""

import unittest
from unittest.mock import MagicMock, patch

from hierarchical_agent_manager.agents import AgentManager
from hierarchical_agent_manager.llms import LLMRegistry


class TestAgentManager(unittest.TestCase):
    """Tests for the AgentManager class."""
    
    def setUp(self):
        """Initialize before each test."""
        # Mock for LLMRegistry
        self.llm_registry = MagicMock(spec=LLMRegistry)
        self.mock_llm = MagicMock()
        self.llm_registry.get.return_value = self.mock_llm
        
        # Create AgentManager with the mock
        self.manager = AgentManager(llm_registry=self.llm_registry, default_llm_id="default_llm")
    
    @patch("hierarchical_agent_manager.agents.manager.create_react_agent")
    def test_create_agent(self, mock_create_agent):
        """Test creating an agent."""
        # Mock for create_react_agent
        mock_agent = MagicMock()
        mock_create_agent.return_value = mock_agent
        
        # Create an agent
        agent_id = self.manager.create_agent(
            name="test_agent",
            llm_id="test_llm",
            tools=[],
            prompt="Test instructions"
        )
        
        # Checks
        self.assertEqual(agent_id, "test_agent")
        self.llm_registry.get.assert_called_once_with("test_llm")
        mock_create_agent.assert_called_once()
        self.assertIn(agent_id, self.manager._agents)
        self.assertIn(agent_id, self.manager._hierarchy)
        self.assertEqual(self.manager._hierarchy[agent_id]["type"], "agent")
        self.assertEqual(self.manager._hierarchy[agent_id]["name"], "test_agent")
        self.assertEqual(self.manager._hierarchy[agent_id]["llm_id"], "test_llm")
EOL
    
    echo -e "Basic tests created.\n"
}

# Main function to execute the script
main() {
    # Create all components
    create_package_files
    create_llm_registry
    create_mcp_manager
    create_utils
    create_agent_manager
    create_example
    create_tests
    
    echo -e "${GREEN}Installation complete!${NC}"
    echo -e "${YELLOW}Project was created in the '${PROJECT_NAME}' directory.${NC}"
    echo -e "You can use it with the following commands:\n"
    echo -e "cd ${PROJECT_NAME}"
    echo -e "pip install -e .\n"
    echo -e "For development: pip install -e '.[dev]'"
    echo -e "For MCP support: pip install -e '.[mcp]'"
    echo -e "For all features: pip install -e '.[all]'\n"
    echo -e "Run example: python -m hierarchical_agent_manager.examples.complex_hierarchy"
}

# Execute the script
main
