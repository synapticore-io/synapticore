"""Message Control Protocol (MCP) manager for external tools and services."""

from mcp.client import ClientSession
from mcp.client.stdio import stdio_client
from mcp.client.sse import sse_client

__all__ = ["MCPManager", "StdioConnection", "SSEConnection"]
