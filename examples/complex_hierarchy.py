"""Example of a complex agent hierarchy with different LLMs and MCP tools."""

import asyncio
from typing import List, Tuple

from langchain_core.tools import BaseTool, tool

from synapticore import AgentManager, LLMRegistry, MCPManager


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
