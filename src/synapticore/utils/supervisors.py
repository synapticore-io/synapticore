"""Utilities for creating and managing supervisors."""

from typing import List, Optional

from langchain.agents import create_openai_tools_agent
from langchain.agents.output_parsers.openai_tools import OpenAIToolsAgentOutputParser
from langchain.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain.tools.render import format_tool_to_openai_tool
from langchain_core.language_models import BaseLLM
from langchain_core.messages import BaseMessage, FunctionMessage, SystemMessage
from langchain_core.prompts import MessagesPlaceholder
from langchain_core.tools import BaseTool

from synapticore.utils.workflow import create_pregel_workflow


def create_supervisor(
    agents: List,
    model: BaseLLM,
    tools: Optional[List[BaseTool]] = None,
    prompt: Optional[str] = None,
    state_schema: Optional[dict] = None,
    config_schema: Optional[dict] = None,
    output_mode: str = "append",
    add_handoff_back_messages: bool = True,
    supervisor_name: str = "supervisor",
    include_agent_name: str = "inline",
) -> object:
    """
    Create a supervisor agent that coordinates other agents.

    Args:
        agents: List of agent objects to be managed by the supervisor.
        model: LLM to use for the supervisor.
        tools: Additional tools available to the supervisor.
        prompt: The prompt instructions for the supervisor.
        state_schema: Schema for the state object.
        config_schema: Schema for the configuration object.
        output_mode: Mode for adding agent outputs to the message history.
        add_handoff_back_messages: Whether to add handoff messages.
        supervisor_name: Name of the supervisor for identification.
        include_agent_name: How to include agent names in messages.

    Returns:
        A supervisor object that can manage the provided agents.
    """
    # Default supervisor prompt if none provided
    if prompt is None:
        prompt = f"""You are a supervisor coordinating multiple expert agents to solve complex tasks.
You have access to the following agents:

{', '.join([getattr(agent, 'name', f'Agent_{i}') for i, agent in enumerate(agents)])}

When a task comes in, determine which agent is best suited to handle it based on their expertise.
You can delegate tasks by using the 'delegate_to_agent' function and specifying the agent's name.
"""

    # Create tool objects for each agent
    agent_tools = []
    for i, agent in enumerate(agents):
        agent_name = getattr(agent, 'name', f'Agent_{i}')
        agent_tools.append({
            "type": "function",
            "function": {
                "name": f"delegate_to_{agent_name}",
                "description": f"Delegate a task to the {agent_name}.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "task": {
                            "type": "string",
                            "description": "The task to delegate to the agent."
                        }
                    },
                    "required": ["task"]
                }
            }
        })

    # Add additional tools if provided
    all_tools = tools or []

    # Create the prompt
    supervisor_prompt = ChatPromptTemplate.from_messages([
        SystemMessage(content=prompt),
        MessagesPlaceholder(variable_name="messages"),
        MessagesPlaceholder(variable_name="agent_outputs")
    ])

    # Create the agent
    supervisor_agent = create_openai_tools_agent(
        llm=model,
        tools=all_tools,
        prompt=supervisor_prompt
    )

    # Create the workflow
    workflow = create_pregel_workflow(
        supervisor_agent=supervisor_agent,
        agents=agents,
        agent_tools=agent_tools,
        name=supervisor_name,
        include_agent_name=include_agent_name
    )

    return workflow
