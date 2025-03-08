<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" class="logo" width="120"/>

# erzeug davon ein hochoptimierte und gut strukturierte version

---
Hier ist eine hochoptimierte und gut strukturierte Version des Codes, der FastMCP-Server, einen Supervisor und React-Agenten unter Verwendung des MCP Python SDK und des LangGraph-Supervisor-Konzepts integriert:

```python
import asyncio
from typing import List, Dict, Any
from dataclasses import dataclass, field

from mcp.server.fastmcp import FastMCP, Context
from mcp.client import ClientSession
from mcp.client.stdio import stdio_client
from mcp.server.models import InitializationOptions

from langchain_openai import ChatOpenAI
from langgraph.prebuilt import create_react_agent
from langgraph_supervisor import create_supervisor

# Constants
DEFAULT_MODEL = "gpt-4o"
SUPERVISOR_PROMPT = """
You are a team leader. Delegate tasks to the appropriate agent.
Use MathAgent for mathematical calculations and InfoAgent for retrieving information.
"""

# Server Configuration
@dataclass
class ServerConfig:
    name: str
    port: int
    tools: List[Dict[str, Any]]
    resources: List[Dict[str, Any]]

# Agent Configuration
@dataclass
class AgentConfig:
    name: str
    model_name: str = DEFAULT_MODEL
    server_connections: Dict[str, str] = field(default_factory=dict)

# Server Creation
def create_mcp_server(config: ServerConfig) -> FastMCP:
    mcp = FastMCP(
        name=config.name,
        initialization_options=InitializationOptions(
            allow_origins=["*"],
            enable_cors=True,
        ),
    )

    for tool in config.tools:
        @mcp.tool()
        async def dynamic_tool(ctx: Context, **kwargs) -> Any:
            ctx.info(f"Executing {tool['name']} on {config.name}")
            return await tool['function'](**kwargs)

    for resource in config.resources:
        @mcp.resource(resource['uri'])
        async def dynamic_resource() -> Any:
            return await resource['function']()

    return mcp

# Agent State Management
@dataclass
class AgentState:
    name: str
    model: ChatOpenAI
    server_connections: Dict[str, ClientSession] = field(default_factory=dict)

    async def connect_to_server(self, server_name: str, server_url: str):
        async with stdio_client(server_url) as (read, write):
            session = ClientSession(read, write)
            await session.initialize()
            self.server_connections[server_name] = session

    async def call_tool(self, server_name: str, tool_name: str, arguments: Dict[str, Any]) -> Any:
        if server_name not in self.server_connections:
            raise ValueError(f"Not connected to server {server_name}")
        session = self.server_connections[server_name]
        return await session.call_tool(tool_name, arguments)

# Supervisor Creation
async def create_supervisor(agent_states: List[AgentState], llm: ChatOpenAI) -> Any:
    agents = [
        create_react_agent(
            model=state.model,
            tools=[],
            name=state.name,
            prompt=f"You are a specialized {state.name}. Use tools to fulfill user requests."
        ) for state in agent_states
    ]

    return create_supervisor(agents=agents, model=llm, prompt=SUPERVISOR_PROMPT)

# Main Application
class MCPApplication:
    def __init__(self, server_configs: List[ServerConfig], agent_configs: List[AgentConfig]):
        self.server_configs = server_configs
        self.agent_configs = agent_configs
        self.servers = []
        self.agent_states = []
        self.supervisor = None

    async def initialize(self):
        # Start MCP Servers
        for config in self.server_configs:
            server = create_mcp_server(config)
            self.servers.append(server)
            asyncio.create_task(server.run())

        # Initialize Agent States
        for config in self.agent_configs:
            state = AgentState(name=config.name, model=ChatOpenAI(model=config.model_name))
            for server_name, server_url in config.server_connections.items():
                await state.connect_to_server(server_name, server_url)
            self.agent_states.append(state)

        # Create Supervisor
        llm = ChatOpenAI(model=DEFAULT_MODEL)
        self.supervisor = await create_supervisor(self.agent_states, llm)

    async def run_query(self, query: str) -> Any:
        app = self.supervisor.compile()
        return await app.ainvoke({"messages": [{"role": "user", "content": query}]})

# Example Usage
async def main():
    server_configs = [
        ServerConfig(
            name="MathServer",
            port=8001,
            tools=[{"name": "add", "function": lambda a, b: a + b}],
            resources=[{"uri": "data://MathServer/info", "function": lambda: "Math Server Info"}]
        ),
        ServerConfig(
            name="InfoServer",
            port=8002,
            tools=[],
            resources=[{"uri": "data://InfoServer/info", "function": lambda: "Info Server Data"}]
        )
    ]

    agent_configs = [
        AgentConfig(name="MathAgent", server_connections={"MathServer": "http://localhost:8001"}),
        AgentConfig(name="InfoAgent", server_connections={"InfoServer": "http://localhost:8002"})
    ]

    app = MCPApplication(server_configs, agent_configs)
    await app.initialize()

    result = await app.run_query("What is the sum of 5 and 3? Also, provide the information from the InfoServer.")
    print("Supervisor Result:", result)

if __name__ == "__main__":
    asyncio.run(main())
```

Diese optimierte Version bietet folgende Verbesserungen:

1. **Modulare Struktur**: Verwendung von Dataclasses für Konfigurationen und Zustände.
2. **Dynamische Tool- und Ressourcenerstellung**: Ermöglicht einfaches Hinzufügen neuer Funktionalitäten.
3. **Zentralisierte Anwendungsklasse**: `MCPApplication` kapselt die gesamte Logik.
4. **Verbesserte Typisierung**: Verstärkte Verwendung von Typ-Annotationen für bessere Codequalität.
5. **Konfigurierbarkeit**: Leicht anpassbar durch Änderung der Konfigurations-Dataclasses.
6. **Asynchrone Implementierung**: Durchgängige Verwendung von `async/await` für bessere Performance.
7. **Trennung von Konfiguration und Logik**: Erleichtert das Testen und die Wartung.

Diese Struktur ist skalierbar, leicht erweiterbar und folgt Best Practices für Python-Entwicklung und Anwendungsarchitektur.

