# MCP Integration

This module provides a minimal integration with the Model Context Protocol (MCP).

## Usage

```python
from synapticore.mcp import MCPSessionManager, ConnectionType

async def main():
    manager = MCPSessionManager()
    
    async with manager.managed_session(
        "session_id",
        ConnectionType.STDIO,
        "python",
        ["path/to/server.py"]
    ) as session:
        # Use session methods directly
        tools = await session.list_tools()
        result = await session.call_tool("tool_name", {"param": "value"})
```

## Dependencies

Make sure your pyproject.toml includes:

```toml
[project.dependencies]
mcp = ">=1.2.1"

[project.optional-dependencies]
mcp = [
    "aiohttp>=3.8.0",
    "sseclient-py>=1.7.0",
]
```
