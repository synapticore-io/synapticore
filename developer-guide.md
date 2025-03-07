# Developer Guide - Hierarchical Agent Manager

This guide provides detailed information for developers who want to understand, modify, or extend the Hierarchical Agent Manager framework.

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

The Hierarchical Agent Manager follows a modular architecture designed to facilitate complex multi-agent systems with different language models and external tool integration. Here's a high-level overview:

```
hierarchical_agent_manager/
├── llms/             # LLM Registry and model management
├── mcp/              # MCP integration for external tools
├── agents/           # Agent and supervisor management
├── utils/            # Utility functions (visualization, etc.)
├── examples/         # Usage examples
└── tests/            # Test suite
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

1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/hierarchical_agent_manager.git
   cd hierarchical_agent_manager
   ```

2. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install the package in development mode with all dependencies:
   ```bash
   pip install -e ".[all,dev]"
   ```

### Development Cycle

1. **Make Changes**: Modify the code in your editor of choice
2. **Run Tests**: Execute `pytest` to ensure your changes don't break existing functionality
3. **Run Examples**: Test your changes with the provided examples
4. **Format Code**: Run `black .` and `ruff .` to ensure code style consistency
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
python -m hierarchical_agent_manager.examples.complex_hierarchy
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

### Modifying the Agent Hierarchy Visualization

The visualization logic is in `utils/visualization.py`. To modify:

1. Update the `generate_mermaid_diagram` function for Mermaid diagram generation
2. Update the `print_hierarchy_tree` function for console output

## Best Practices

### Code Style

- Follow the [Black](https://black.readthedocs.io/en/stable/) code formatting style
- Use [ruff](https://github.com/charliermarsh/ruff) for linting
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

**Solution**: Install the optional dependency: `pip install "hierarchical_agent_manager[openai]"` or `pip install langchain-openai`.

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
