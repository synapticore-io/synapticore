<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" class="logo" width="120"/>

# cih dachte eher daran from langchain_openai import ChatOpenAI

from langgraph_supervisor import create_supervisor
from langgraph.prebuilt import create_react_agent

model = ChatOpenAI(model="gpt-4o")

# Create specialized agents

def add(a: float, b: float) -> float:
"""Add two numbers."""
return a + b

def multiply(a: float, b: float) -> float:
"""Multiply two numbers."""
return a * b

def web_search(query: str) -> str:
"""Search the web for information."""
return (
"Here are the headcounts for each of the FAANG companies in 2024:\n"
"1. **Facebook (Meta)**: 67,317 employees.\n"
"2. **Apple**: 164,000 employees.\n"
"3. **Amazon**: 1,551,000 employees.\n"
"4. **Netflix**: 14,000 employees.\n"
"5. **Google (Alphabet)**: 181,269 employees."
)

math_agent = create_react_agent(
model=model,
tools=[add, multiply],
name="math_expert",
prompt="You are a math expert. Always use one tool at a time."
)

research_agent = create_react_agent(
model=model,
tools=[web_search],
name="research_expert",
prompt="You are a world class researcher with access to web search. Do not do any math."
)

# Create supervisor workflow

workflow = create_supervisor(
[research_agent, math_agent],
model=model,
prompt=(
"You are a team supervisor managing a research expert and a math expert. "
"For current events, use research_agent. "
"For math problems, use math_agent."
)
)

# Compile and run

app = workflow.compile()
result = app.invoke({
"messages": [
{
"role": "user",
"content": "what's the combined headcount of the FAANG companies in 2024?"
}
]
})

nur dann mit mcp clients
---
Ich verstehe, dass Sie eine Integration von LangGraph Supervisor mit FastMCP Clients wünschen. Hier ist ein erweiterter Ansatz, der Ihre vorgeschlagene Struktur mit FastMCP Clients kombiniert:

```python
from langchain_openai import ChatOpenAI
from langgraph_supervisor import create_supervisor
from langgraph.prebuilt import create_react_agent
from fastmcp import FastMCP

# Initialize FastMCP
mcp = FastMCP("SupervisorDemo")

# Initialize OpenAI model
model = ChatOpenAI(model="gpt-4")

# Define FastMCP tools
@mcp.tool()
def add(a: float, b: float) -> float:
    """Add two numbers."""
    return a + b

@mcp.tool()
def multiply(a: float, b: float) -> float:
    """Multiply two numbers."""
    return a * b

@mcp.tool()
def web_search(query: str) -> str:
    """Search the web for information."""
    return (
        "Here are the headcounts for each of the FAANG companies in 2024:\n"
        "1. **Facebook (Meta)**: 67,317 employees.\n"
        "2. **Apple**: 164,000 employees.\n"
        "3. **Amazon**: 1,551,000 employees.\n"
        "4. **Netflix**: 14,000 employees.\n"
        "5. **Google (Alphabet)**: 181,269 employees."
    )

# Create specialized agents using FastMCP tools
math_agent = create_react_agent(
    model=model,
    tools=[add, multiply],
    name="math_expert",
    prompt="You are a math expert. Always use one tool at a time."
)

research_agent = create_react_agent(
    model=model,
    tools=[web_search],
    name="research_expert",
    prompt="You are a world class researcher with access to web search. Do not do any math."
)

# Create supervisor workflow
workflow = create_supervisor(
    [research_agent, math_agent],
    model=model,
    prompt=(
        "You are a team supervisor managing a research expert and a math expert. "
        "For current events, use research_agent. "
        "For math problems, use math_agent."
    )
)

# Compile workflow
app = workflow.compile()

# Integrate with FastMCP
@mcp.route("/invoke", methods=["POST"])
async def invoke_workflow(request):
    query = request.json.get("query")
    result = app.invoke({
        "messages": [
            {
                "role": "user",
                "content": query
            }
        ]
    })
    return {"result": result}

# Run FastMCP server
if __name__ == "__main__":
    mcp.run()
```

Diese Implementation integriert den LangGraph Supervisor mit FastMCP Clients, indem sie:

1. FastMCP für die Definition und Bereitstellung von Tools verwendet.
2. Die spezialisierten Agenten mit den FastMCP-Tools erstellt.
3. Den LangGraph Supervisor-Workflow mit diesen Agenten aufbaut.
4. Eine FastMCP-Route definiert, die den Workflow aufruft und Ergebnisse zurückgibt.

Um diesen Server zu nutzen, können Sie einen FastMCP Client verwenden:

```python
from fastmcp import MCPClient

async def main():
    client = MCPClient("http://localhost:8000")
    response = await client.invoke("/invoke", {"query": "what's the combined headcount of the FAANG companies in 2024?"})
    print(response["result"])

import asyncio
asyncio.run(main())
```

Diese Struktur ermöglicht es Ihnen, die Vorteile von LangGraph Supervisor für komplexe Workflows zu nutzen, während Sie gleichzeitig die Effizienz und Skalierbarkeit von FastMCP für die Bereitstellung und den Zugriff auf die Funktionalität nutzen[^1][^2][^3].

<div style="text-align: center">⁂</div>

[^1]: https://langchain-ai.github.io/langgraph/tutorials/multi_agent/agent_supervisor/

[^2]: https://engineering.ustwo.com/articles/empower-your-application-with-langchain-langgraph-and-bedrock-part-2/

[^3]: https://www.digitalocean.com/community/tutorials/local-ai-agents-with-langgraph-and-ollama

[^4]: https://python.langchain.com/docs/langserve/

[^5]: https://github.com/langchain-ai/langgraph-supervisor

[^6]: https://www.linkedin.com/posts/langchain_top-5-langgraph-agents-in-production-2024-activity-7278807039521239040-TMbV

[^7]: https://news.ycombinator.com/item?id=40739982

[^8]: https://www.youtube.com/watch?v=lQ5r2AvlP0Q

