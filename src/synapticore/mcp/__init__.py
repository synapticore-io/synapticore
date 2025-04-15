"""Model Context Protocol (MCP) integration for Synapticore."""
from contextlib import asynccontextmanager

from langgraph.prebuilt import create_react_agent
from langgraph_supervisor.supervisor import create_supervisor
from mcp.server.fastmcp import FastMCP as MCPServer
from mcp.client.session import ClientSession
from mcp.client.stdio import StdioServerParameters

client_session = ClientSession()
from mcp import types
from langchain_mcp_adapters.client import MultiServerMCPClient as MCPClient
from langchain_core.prompts import ChatPromptTemplate

__all__ = [
    "MCPServer",
    "MCPClient",
    "types",
]

@asynccontextmanager
async def create_mcp_agent(chat, config):
    async with MCPClient(config) as client:
        prompt = ChatPromptTemplate.from_messages(config.prompt, client.get)
        agent = create_react_agent(
            model=chat,
            tools=client.get_tools(),
            name=config.name,
            prompt=config.prompt,
        )
            
        agent.mcp = {
            "client": client,
            "config": config
        }
        yield agent

@asynccontextmanager
async def create_mcp_supervisor(chat, agents, config):
    async with MCPClient(config) as client:
        supervisor = create_supervisor(
            agents=agents,
            model=chat,
            tools=client.get_tools(),
            supervisor_name=config.name,
            prompt=config.prompt,
            parallel_tool_calls=config.parallel_tool_calls,
            
        )
        supervisor.mcp = {
            "client": client,
            "config": config
        }
        yield supervisor
