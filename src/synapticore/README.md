# Hierarchical Agent Manager

A framework for creating and managing hierarchical structures of LLM-based agents. This framework allows you to:

- Register and use different LLM models (OpenAI, Anthropic, etc.)
- Create individual agents with specialized skills and tools
- Organize agents into hierarchical structures with supervisors
- Visualize and manage complex agent hierarchies

## Installation

```bash
# Basic installation
pip install -e .

# With development tools
pip install -e '.[dev]'

# With OpenAI support
pip install -e '.[openai]'

# With Anthropic support
pip install -e '.[anthropic]'

# With all features
pip install -e '.[all]'
```

## Usage Example

```python
from synapticore import AgentManager, LLMRegistry

# Initialize LLM Registry
llm_registry = LLMRegistry()
llm_registry.register_openai("gpt-4", model="gpt-4")

# Create Agent Manager
manager = AgentManager(llm_registry=llm_registry)

# Create specialized agents
research_agent_id = manager.create_agent(
    name="research_expert",
    tools=[web_search],
    prompt="You are a world-class researcher."
)

writing_agent_id = manager.create_agent(
    name="writing_expert",
    tools=[write_report],
    prompt="You are an expert report writer."
)

# Create a supervisor
supervisor_id = manager.create_supervisor(
    name="project_manager",
    agent_ids=[research_agent_id, writing_agent_id],
    prompt="You are a project manager."
)

# Compile the workflow
manager.compile(supervisor_id)

# Execute a query
result = manager.invoke(supervisor_id, "Research and write a report on AI trends.")
```

## License

MIT
