# Developer Guide - Synapticore

This guide provides detailed information for developers who want to understand, modify, or extend the Synapticore framework.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Core Components](#core-components)
3. [Development Workflow](#development-workflow)
4. [Adding New Features](#adding-new-features)
5. [Working with MCP Tools](#working-with-mcp-tools)
6. [Testing Your Changes](#testing-your-changes)
7. [Common Development Tasks](#common-development-tasks)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)

## Architecture Overview

The Synapticore framework follows a modular architecture designed to facilitate complex multi-agent systems with different language models and external tool integration. Here's a high-level overview:

```
src/
└── synapticore/
    ├── llms/             # LLM Registry and model management
    ├── mcp/              # MCP session and tool management
    ├── agents/           # Agent and supervisor management
    ├── utils/            # Utility functions
examples/         # Usage examples
tests/            # Test suite
└── synapticore/
    ├── llms/             # LLM Registry and model management tests
    ├── mcp/              # MCP session and tool management tests
    ├── agents/           # Agent and supervisor management test
```

The system uses a hierarchical approach where:

- **Leaf nodes** are specialized agents with specific tools and capabilities
- **Intermediate nodes** are supervisors that manage groups of agents
- **Root nodes** are top-level supervisors that coordinate the entire system

This hierarchical structure allows for complex delegations and specializations while maintaining a coherent overall system.

## Core Components

### 1. LLM Registry

The `LLMRegistry` manages multiple language models and provides them to agents as needed:

- **Key Concept**: Each language model is registered with a unique ID and can be referenced by this ID
- **Main File**: `llms/registry.py`
- **Extension Point**: Add methods to support additional LLM providers

### 2. MCP Manager

The `MCPManager` handles integration with the langchain-mcp-adapters for external tool access:

- **Key Concept**: Manages connections to MCP servers and provides their tools to agents
- **Main File**: `mcp/manager.py`
- **Extension Point**: Add support for additional connection types or tool discovery methods

### 3. Agent Manager

The `AgentManager` ties everything together, managing the creation, connection, and execution of agents:

- **Key Concept**: Maintains a hierarchy of agents and supervisors with parent-child relationships
- **Main File**: `agents/manager.py`
- **Extension Point**: Add new agent types or modify hierarchy management

## Development Workflow

### Setting Up Development Environment

### Prerequisites

- Python 3.8 or higher
- [UV](https://github.com/astral-sh/uv) - Fast Python package installer and resolver

### Clone the Repository

```bash
git clone https://github.com/yourusername/synapticore.git
cd synapticore
```

### Setup with UV (Recommended)

UV provides faster dependency resolution and installation compared to pip:

```bash
# Install UV if you don't have it yet
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/astral-sh/uv/releases/download/0.5.24/uv-installer.sh | sh

# Create a virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Synchronize the project dependencies with UV
uv pip sync -e ".[dev,all]"
```

### Alternative Setup with Pip

If you prefer using pip:

```bash
# Create a virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install the package with all dependencies
pip install -e ".[all,dev]"
```

### DevContainer Setup (Recommended for VSCode Users)

This repository includes a DevContainer configuration for VSCode, which provides a fully configured development environment:

1. Install [VSCode](https://code.visualstudio.com/) and the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Clone the repository and open it in VSCode
3. When prompted, click "Reopen in Container" or use the command palette (F1) and select "Dev Containers: Reopen in Container"
4. The container will automatically set up the development environment with all dependencies

### Development Cycle

1. **Make Changes**: Modify the code in your editor of choice
2. **Run Tests**: Execute `pytest` to ensure your changes don't break existing functionality
3. **Run Examples**: Test your changes with the provided examples
4. **Format Code**: Run `black .` and `isort .` to ensure code style consistency
5. **Commit Changes**: Use descriptive commit messages explaining what you changed and why

## Adding New Features

### Adding Support for a New LLM Provider

1. Add a new method to `LLMRegistry` following this pattern:

   ```python
   def register_new_provider(
       self,
       model_id: str,
       model: str = "default-model-name",
       **kwargs
   ) -> None:
       try:
           from langchain_new_provider import ChatNewProvider
           chat_model = ChatNewProvider(model=model, **kwargs)
           self.register(model_id, chat_model)
       except ImportError:
           raise ImportError(
               "langchain-new-provider is not installed. Please install it."
           )
   ```

2. Update the package dependencies in `pyproject.toml` to include the new provider as an optional dependency.

### Creating a New Agent Type

1. Create a new function in `agents/types.py` (you may need to create this file):

   ```python
   def create_custom_agent(
       model: LanguageModelLike,
       tools: List[Union[BaseTool, Callable]],
       name: str,
       prompt: Optional[Union[str, SystemMessage, Callable, Any]] = None,
       **kwargs
   ) -> Pregel:
       # Custom agent creation logic
       ...
       return agent
   ```

2. Add a method to `AgentManager` that uses your new agent creation function.

## Working with MCP Tools

### Creating an MCP Server

1. Define your tools using the MCP protocol:

   ```python
   from mcp.server import ToolServerProtocol, register_tool, run

   @register_tool("my_custom_tool")
   async def my_custom_tool(param1: str, param2: int) -> Dict[str, Any]:
       # Tool implementation
       return {"result": f"Processed {param1} {param2} times"}

   if __name__ == "__main__":
       server = ToolServerProtocol()
       run(server)
   ```

2. Register the server with the MCP Manager:

   ```python
   # For stdio connection
   manager.mcp_manager.register_stdio_server(
       server_id="my_tools",
       command="python",
       args=["path/to/my_server.py"],
   )

   # For SSE connection
   manager.mcp_manager.register_sse_server(
       server_id="web_tools",
       url="http://localhost:8000/sse",
   )
   ```

3. Initialize the MCP Manager:

   ```python
   await manager.mcp_manager.initialize()
   ```

4. Create an agent that uses the MCP tools:
   ```python
   agent_id = await manager.create_agent_with_mcp(
       name="mcp_agent",
       mcp_server_ids=["my_tools", "web_tools"],
   )
   ```

## Testing Your Changes

### Unit Tests

Run the full test suite:

```bash
pytest
```

Test a specific module:

```bash
pytest tests/test_llm_registry.py
```

### Integration Tests

The examples in the `examples/` directory serve as integration tests. Run them to ensure your changes work in a complete system:

```bash
python -m synapticore.examples.complex_hierarchy
```

### Adding New Tests

1. Create or modify test files in the `tests/` directory
2. Follow the existing test patterns using the `unittest` framework
3. Use mocks for external dependencies to ensure tests run quickly and reliably

## Common Development Tasks

### Adding a New Dependency

1. Update `pyproject.toml` with the new dependency
2. For optional dependencies, add them to the appropriate section:

   ```toml
   [project.optional-dependencies]
   new-feature = ["new-package>=1.0.0"]
   all = [
       # Include existing dependencies
       "new-package>=1.0.0",
   ]
   ```

3. Update the environment with UV:
   ```bash
   uv pip sync -e ".[all,dev]"
   ```

### Modifying the Agent Hierarchy Visualization

The visualization logic is in `utils/hierarchy.py`. To modify:

1. Update the `generate_mermaid_diagram` function for Mermaid diagram generation
2. Update the `print_hierarchy_tree` function for console output

## Best Practices

### Code Style

- Follow the [Black](https://black.readthedocs.io/en/stable/) code formatting style
- Use [isort](https://pycqa.github.io/isort/) for import sorting
- Add docstrings to all public functions and classes
- Use type hints consistently

### Architecture Guidelines

- Maintain separation of concerns between modules
- Keep the hierarchy structure clean and consistent
- Make all components extendable and customizable
- Provide sensible defaults while allowing for configuration

### Testing Guidelines

- Write unit tests for all new functionality
- Mock external dependencies in tests
- Test edge cases and error handling
- Ensure backwards compatibility

## Troubleshooting

### Common Issues

#### MCP Tools Not Available

**Symptom**: `RuntimeError: MCPManager is not initialized.`

**Solution**: Ensure you've called `await mcp_manager.initialize()` before trying to use MCP tools.

#### Agent Creation Fails

**Symptom**: `ValueError: No LLM ID provided and no default LLM set.`

**Solution**: Either provide an `llm_id` when creating the agent or set a `default_llm_id` when creating the `AgentManager`.

#### Model Import Errors

**Symptom**: `ImportError: langchain-openai is not installed.`

**Solution**: Install the optional dependency: `uv pip install "synapticore[openai]"` or `uv pip install langchain-openai`.

### Debugging Tips

1. Use `print_hierarchy()` to visualize the current agent structure
2. Enable more verbose logging to see what's happening:
   ```python
   import logging
   logging.basicConfig(level=logging.DEBUG)
   ```
3. Inspect message content at each step of the process to identify where issues occur

---

This developer guide should be considered a living document. As the framework evolves, this guide should be updated to reflect new features, patterns, and best practices.
