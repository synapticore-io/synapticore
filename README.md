# Hierarchical Agent Manager

A flexible framework for building, managing, and orchestrating complex hierarchical multi-agent systems with support for multiple language models and MCP tool integration.

## Features

- 🌳 **Complex Agent Hierarchies** - Create multi-level agent structures with unlimited depth
- 🧠 **Multi-LLM Support** - Use different language models for different agents and tasks
- 🔌 **MCP Integration** - Seamlessly integrate with external tools via [langchain-mcp-adapters](https://github.com/langchain-ai/langchain-mcp-adapters)
- 🔄 **Intelligent Task Routing** - Automatically route tasks to the most appropriate specialized agent
- 📊 **Visualization** - Visualize your agent structures for better understanding and debugging

## Installation

```bash
# Basic installation
pip install hierarchical-agent-manager

# With specific LLM integrations
pip install "hierarchical-agent-manager[openai,anthropic]"

# With MCP support
pip install "hierarchical-agent-manager[mcp]"

# Complete installation
pip install "hierarchical-agent-manager[all]"
```

## Quick Start

```python
from synapticore import AgentManager
from synapticore.llms import LLMRegistry
from langchain_core.tools import tool

# Define some tools
@tool
def add(a: float, b: float) -> float:
    """Add two numbers."""
    return a + b

@tool
def web_search(query: str) -> str:
    """Search the web for information."""
    return f"Results for: {query}"

# Set up LLM registry
llm_registry = LLMRegistry()
llm_registry.register_openai("gpt-4", model="gpt-4")
llm_registry.register_anthropic("claude", model="claude-3-sonnet")

# Create agent manager
manager = AgentManager(llm_registry=llm_registry)

# Create specialized agents with different LLMs
math_agent = manager.create_agent(
    name="math_expert",
    llm_id="gpt-4",
    tools=[add],
    prompt="You are a mathematics expert. Use tools when needed."
)

research_agent = manager.create_agent(
    name="researcher",
    llm_id="claude",
    tools=[web_search],
    prompt="You are a research expert with access to web search."
)

# Create a supervisor to manage these agents
team_lead = manager.create_supervisor(
    name="team_lead",
    llm_id="gpt-4",
    agent_ids=[math_agent, research_agent],
    prompt=(
        "You are a team supervisor. For math problems, use math_expert. "
        "For information gathering, use researcher."
    )
)

# Compile the workflow
manager.compile(team_lead)

# Execute a query
result = manager.invoke(team_lead, "What is 42 + 18, and can you find information about hierarchical agents?")
```

## MCP Tool Integration

Integrate with Machine Communication Protocol (MCP) tools:

```python
# Register an MCP server
await manager.register_mcp_client(
    "data_processing",
    {
        "transport": "stdio",
        "command": "python",
        "args": ["data_processor_server.py"],
    }
)

# Create an agent with MCP tools
data_agent = await manager.create_agent_with_mcp(
    name="data_expert",
    llm_id="gpt-4",
    mcp_server_ids=["data_processing"]
)
```

## Multi-level Hierarchies

Create complex agent organizations:

```python
# Create team supervisors
research_team = manager.create_supervisor(
    name="research_team",
    llm_id="claude",
    agent_ids=[research_agent, data_agent],
)

content_team = manager.create_supervisor(
    name="content_team",
    llm_id="gpt-4",
    agent_ids=[writing_agent, editing_agent],
)

# Compile the teams
manager.compile(research_team)
manager.compile(content_team)

# Create a top-level director
director = manager.create_supervisor(
    name="project_director",
    llm_id="gpt-4",
    agent_ids=[research_team, content_team],
)

# Compile the director
manager.compile(director)

# Visualize the hierarchy
print(manager.visualize_hierarchy())
```

## Documentation

For more detailed documentation, see the [Developer Guide](./DEVELOPER_GUIDE.md).

## Examples

Explore complete examples in the `examples/` directory:

- `complex_hierarchy.py` - Creating multi-level agent organizations
- `mcp_integration.py` - Working with external tools via MCP

## Requirements

- Python 3.11+
- LangGraph 0.3.5+
- LangChain Core 0.2.0+

## License

This project is licensed under the MIT License - see the LICENSE file for details.
