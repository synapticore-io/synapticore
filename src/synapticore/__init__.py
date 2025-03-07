"""
Synapticore - A framework for building, managing, and orchestrating complex hierarchical multi-agent systems.

This package provides tools and utilities for creating advanced AI agent systems
with support for multiple language models and MCP tool integration.
"""

from synapticore.agents import AgentManager
from synapticore.llms import LLMRegistry
from synapticore.mcp import MCPManager

__version__ = "0.1.0"
__all__ = ["AgentManager", "LLMRegistry", "MCPManager"]
