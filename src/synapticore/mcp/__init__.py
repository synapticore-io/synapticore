"""Message Control Protocol (MCP) manager for external tools and services."""

from synapticore.mcp.manager import MCPManager, SSEConnection, StdioConnection

__all__ = ["MCPManager", "StdioConnection", "SSEConnection"]
