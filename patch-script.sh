#!/bin/bash
# 
# workflow_engine_patch.sh
#
# This script patches the SynaptiCore Workflow Engine with an
# improved implementation.
#

set -e  # Exit on error

# Color codes for output
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}SynaptiCore Workflow Engine Patch${NC}"
echo "-----------------------------------"

# Check if the working directory is the SynaptiCore project directory
if [ ! -d "src/synapticore" ]; then
    echo -e "${RED}Error: This script must be run from the SynaptiCore project directory.${NC}"
    echo "Please change to the main directory of the SynaptiCore project."
    exit 1
fi

# Create backup of the current workflow.py
echo "Creating backup of the current workflow.py..."
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp src/synapticore/utils/workflow.py "$BACKUP_DIR/workflow.py"
echo -e "${GREEN}Backup created at $BACKUP_DIR/workflow.py${NC}"

# Apply the new workflow implementation
cat > src/synapticore/utils/workflow.py << 'EOF'
"""Utilities for creating and managing pregel workflows."""

import asyncio
import logging
from typing import Any, Dict, List, Optional, Union, Callable
from uuid import uuid4

from langchain.agents import AgentExecutor
from langchain_core.messages import (
    AIMessage, 
    BaseMessage, 
    FunctionMessage, 
    HumanMessage, 
    SystemMessage
)
from langchain_core.tools import BaseTool

logger = logging.getLogger(__name__)

class PregelWorkflow:
    """
    Implementation of a Pregel-style workflow for agent coordination.
    
    This workflow manages the execution of a supervisor agent that delegates tasks
    to specialized sub-agents. It handles message passing, state management, and
    task delegation between agents.
    """
    
    def __init__(
        self,
        supervisor_agent: Any,
        agents: List[Any],
        agent_tools: List[Dict[str, Any]],
        name: str = "supervisor",
        include_agent_name: str = "inline",
        max_iterations: int = 10,
        state_schema: Optional[Dict[str, Any]] = None,
        config_schema: Optional[Dict[str, Any]] = None,
    ):
        """
        Initialize the PregelWorkflow.
        
        Args:
            supervisor_agent: The agent that coordinates tasks.
            agents: List of specialized agents.
            agent_tools: Tool definitions for agent delegation.
            name: Name of the workflow.
            include_agent_name: How to include agent names in messages.
            max_iterations: Maximum iterations for the workflow.
            state_schema: Schema for state objects.
            config_schema: Schema for configuration objects.
        """
        self.name = name
        self.supervisor_agent = supervisor_agent
        self.agents = {getattr(agent, 'name', f'Agent_{i}'): agent 
                     for i, agent in enumerate(agents)}
        self.agent_tools = agent_tools
        self.include_agent_name = include_agent_name
        self.max_iterations = max_iterations
        self.state_schema = state_schema or {}
        self.config_schema = config_schema or {}
        
        # Set up lookup for agent delegation
        self.delegation_tools = {}
        for tool in agent_tools:
            if tool["type"] == "function":
                func_name = tool["function"]["name"]
                if func_name.startswith("delegate_to_"):
                    agent_name = func_name[len("delegate_to_"):]
                    self.delegation_tools[func_name] = agent_name
    
    def compile(self, name: Optional[str] = None, checkpointer=None, store=None):
        """
        Compile the workflow for execution.
        
        Args:
            name: Optional name for the compiled workflow.
            checkpointer: Optional component for state persistence.
            store: Optional store for persistence.
            
        Returns:
            The compiled workflow (self).
        """
        self.compiled_name = name or self.name
        self.checkpointer = checkpointer
        self.store = store
        return self
    
    def _format_agent_message(self, content: str, agent_name: str) -> str:
        """
        Format a message to include the agent's name based on preferences.
        
        Args:
            content: The message content.
            agent_name: The name of the agent.
            
        Returns:
            Formatted message content.
        """
        if self.include_agent_name == "none":
            return content
        elif self.include_agent_name == "prefix":
            return f"[{agent_name}]: {content}"
        elif self.include_agent_name == "inline":
            return f"{content} (from {agent_name})"
        elif self.include_agent_name == "suffix":
            return f"{content} - {agent_name}"
        else:
            return content
    
    async def _checkpoint_state(self, state: Dict[str, Any], step: str) -> None:
        """
        Save the current state if a checkpointer is configured.
        
        Args:
            state: The current state.
            step: Description of the current step.
        """
        if self.checkpointer:
            checkpoint_id = f"{self.compiled_name}_{uuid4()}"
            try:
                await self.checkpointer.save(checkpoint_id, {
                    "state": state,
                    "step": step,
                    "timestamp": asyncio.get_event_loop().time()
                })
                logger.debug(f"Checkpointed state at step '{step}' with ID {checkpoint_id}")
            except Exception as e:
                logger.error(f"Failed to checkpoint state: {e}")
    
    def _validate_state(self, state: Dict[str, Any]) -> Dict[str, Any]:
        """
        Validate and normalize state according to schema.
        
        Args:
            state: The state to validate.
            
        Returns:
            Validated and normalized state.
            
        Raises:
            ValueError: If required fields are missing.
        """
        # Ensure messages exists
        if "messages" not in state:
            state["messages"] = []
        
        # Ensure other required fields from schema
        for key, schema in self.state_schema.items():
            if key not in state and schema.get("required", False):
                if "default" in schema:
                    state[key] = schema["default"]
                else:
                    raise ValueError(f"Required state field '{key}' is missing")
        
        return state
    
    def invoke(self, state: Dict[str, Any]) -> Dict[str, Any]:
        """
        Execute the workflow synchronously.
        
        Args:
            state: The initial state.
            
        Returns:
            The final state after workflow execution.
        """
        return asyncio.run(self.ainvoke(state))
    
    async def ainvoke(self, state: Dict[str, Any]) -> Dict[str, Any]:
        """
        Execute the workflow asynchronously.
        
        Args:
            state: The initial state.
            
        Returns:
            The final state after workflow execution.
        """
        # Validate the initial state
        state = self._validate_state(state)
        await self._checkpoint_state(state, "workflow_start")
        
        # Initialize working state
        working_state = state.copy()
        if "agent_outputs" not in working_state:
            working_state["agent_outputs"] = []
        
        iteration = 0
        while iteration < self.max_iterations:
            iteration += 1
            logger.info(f"Starting workflow iteration {iteration}/{self.max_iterations}")
            
            # Run the supervisor agent
            supervisor_input = {
                "messages": working_state["messages"],
                "agent_outputs": working_state.get("agent_outputs", [])
            }
            
            try:
                # Execute the supervisor agent
                supervisor_output = await self.supervisor_agent.ainvoke(supervisor_input)
                supervisor_message = supervisor_output.get("output")
                
                await self._checkpoint_state(
                    {**working_state, "supervisor_message": supervisor_message},
                    f"supervisor_iteration_{iteration}"
                )
                
                # Check for delegation calls
                delegation = None
                if hasattr(supervisor_message, "tool_calls") and supervisor_message.tool_calls:
                    for tool_call in supervisor_message.tool_calls:
                        tool_name = tool_call.get("name", "")
                        if tool_name in self.delegation_tools:
                            agent_name = self.delegation_tools[tool_name]
                            task = tool_call.get("args", {}).get("task", "")
                            delegation = (agent_name, task)
                            break
                
                if delegation:
                    # Process the delegation
                    agent_name, task = delegation
                    logger.info(f"Delegating task to {agent_name}: {task}")
                    
                    if agent_name in self.agents:
                        agent = self.agents[agent_name]
                        
                        # Create input for the agent
                        agent_input = {
                            "messages": working_state["messages"] + [HumanMessage(content=task)]
                        }
                        
                        # Execute the agent
                        agent_output = await agent.ainvoke(agent_input)
                        agent_message = agent_output.get("output", "No response from agent")
                        
                        # Format the agent's response
                        if isinstance(agent_message, str):
                            formatted_content = self._format_agent_message(agent_message, agent_name)
                            agent_response = AIMessage(content=formatted_content)
                        else:
                            agent_response = agent_message
                            if hasattr(agent_response, "content"):
                                agent_response.content = self._format_agent_message(
                                    agent_response.content, agent_name
                                )
                        
                        # Add to agent outputs
                        working_state["agent_outputs"].append(agent_response)
                        
                        await self._checkpoint_state(
                            {**working_state, "agent_response": agent_response},
                            f"agent_{agent_name}_iteration_{iteration}"
                        )
                    else:
                        # Agent not found
                        error_message = f"Agent '{agent_name}' not found"
                        working_state["agent_outputs"].append(
                            FunctionMessage(content=error_message, name="error")
                        )
                        logger.error(error_message)
                else:
                    # No delegation, add supervisor message to history
                    if supervisor_message:
                        if isinstance(supervisor_message, str):
                            working_state["messages"].append(AIMessage(content=supervisor_message))
                        else:
                            working_state["messages"].append(supervisor_message)
                    
                    # If no delegation and we got a final answer, we're done
                    if not any(tool_name in self.delegation_tools 
                              for tool_name in getattr(supervisor_message, "tool_names", [])):
                        logger.info(f"Workflow completed in {iteration} iterations")
                        break
            
            except Exception as e:
                error_message = f"Error in workflow iteration {iteration}: {str(e)}"
                logger.error(error_message)
                working_state["messages"].append(
                    FunctionMessage(content=error_message, name="error")
                )
                break
        
        # Finalize state
        final_state = {
            "messages": working_state["messages"],
            "iterations": iteration,
            "completed": iteration < self.max_iterations
        }
        
        # Include any additional fields from the original state
        for key, value in state.items():
            if key not in final_state and key != "messages":
                final_state[key] = value
        
        await self._checkpoint_state(final_state, "workflow_complete")
        return final_state


def create_pregel_workflow(
    supervisor_agent: Any,
    agents: List[Any],
    agent_tools: List[Dict[str, Any]],
    name: str = "supervisor",
    include_agent_name: str = "inline",
    max_iterations: int = 10,
    state_schema: Optional[Dict[str, Any]] = None,
    config_schema: Optional[Dict[str, Any]] = None,
) -> PregelWorkflow:
    """
    Create a pregel workflow for the supervisor and agents.
    
    Args:
        supervisor_agent: The supervisor agent.
        agents: List of agent objects to be managed by the supervisor.
        agent_tools: Tool definitions for agent delegation.
        name: Name of the workflow for identification.
        include_agent_name: How to include agent names in messages.
        max_iterations: Maximum number of iterations for the workflow.
        state_schema: Schema for state objects.
        config_schema: Schema for configuration objects.
        
    Returns:
        A pregel workflow object.
    """
    return PregelWorkflow(
        supervisor_agent=supervisor_agent,
        agents=agents,
        agent_tools=agent_tools,
        name=name,
        include_agent_name=include_agent_name,
        max_iterations=max_iterations,
        state_schema=state_schema,
        config_schema=config_schema,
    )
EOF

# Check installation
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Workflow Engine has been successfully updated!${NC}"
else
    echo -e "${RED}An error occurred while updating the Workflow Engine.${NC}"
    echo "The original file was backed up at $BACKUP_DIR/workflow.py"
    exit 1
fi

# Update supervisors.py file to support new parameters
echo "Updating supervisors.py to support new parameters..."

cat > src/synapticore/utils/supervisors.py.new << 'EOF'
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
    max_iterations: int = 10,
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
        max_iterations: Maximum number of workflow iterations.

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
        include_agent_name=include_agent_name,
        max_iterations=max_iterations,
        state_schema=state_schema,
        config_schema=config_schema,
    )

    return workflow
EOF

# Check if the file has changed
if cmp -s src/synapticore/utils/supervisors.py src/synapticore/utils/supervisors.py.new; then
    echo "supervisors.py does not need updating."
    rm src/synapticore/utils/supervisors.py.new
else
    echo "Updating supervisors.py..."
    cp src/synapticore/utils/supervisors.py "$BACKUP_DIR/supervisors.py"
    mv src/synapticore/utils/supervisors.py.new src/synapticore/utils/supervisors.py
    echo -e "${GREEN}supervisors.py has been successfully updated.${NC}"
fi

# Create test file for the workflow engine
echo "Creating test file for the Workflow Engine..."

mkdir -p tests/synapticore/utils

cat > tests/synapticore/utils/test_workflow.py << 'EOF'
"""Tests for the PregelWorkflow implementation."""

import asyncio
import pytest
from unittest.mock import AsyncMock, MagicMock, patch

from langchain_core.messages import AIMessage, HumanMessage

from synapticore.utils.workflow import PregelWorkflow, create_pregel_workflow


class TestPregelWorkflow:
    """Test cases for the PregelWorkflow class."""
    
    def setup_method(self):
        """Set up test fixtures."""
        # Create mock agents
        self.agent1 = MagicMock()
        self.agent1.name = "researcher"
        self.agent1.ainvoke = AsyncMock(return_value={"output": "Research results"})
        
        self.agent2 = MagicMock()
        self.agent2.name = "writer"
        self.agent2.ainvoke = AsyncMock(return_value={"output": "Written report"})
        
        # Create mock supervisor
        self.supervisor = MagicMock()
        self.supervisor.ainvoke = AsyncMock(return_value={
            "output": MagicMock(
                tool_calls=[{
                    "name": "delegate_to_researcher",
                    "args": {"task": "Research AI trends"}
                }]
            )
        })
        
        # Create agent tools
        self.agent_tools = [
            {
                "type": "function",
                "function": {
                    "name": "delegate_to_researcher",
                    "description": "Delegate a task to the researcher.",
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
            },
            {
                "type": "function",
                "function": {
                    "name": "delegate_to_writer",
                    "description": "Delegate a task to the writer.",
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
            }
        ]
        
        # Create workflow
        self.workflow = PregelWorkflow(
            supervisor_agent=self.supervisor,
            agents=[self.agent1, self.agent2],
            agent_tools=self.agent_tools,
            name="test_workflow",
            include_agent_name="inline",
            max_iterations=3
        )
    
    @pytest.mark.asyncio
    async def test_workflow_initialization(self):
        """Test that the workflow initializes correctly."""
        assert self.workflow.name == "test_workflow"
        assert len(self.workflow.agents) == 2
        assert "researcher" in self.workflow.agents
        assert "writer" in self.workflow.agents
        assert len(self.workflow.delegation_tools) == 2
        assert self.workflow.delegation_tools["delegate_to_researcher"] == "researcher"
    
    @pytest.mark.asyncio
    async def test_workflow_delegation(self):
        """Test that the workflow properly delegates tasks."""
        # Set up test input
        state = {"messages": [HumanMessage(content="Tell me about AI trends")]}
        
        # Call workflow
        result = await self.workflow.ainvoke(state)
        
        # Check that supervisor was called
        self.supervisor.ainvoke.assert_called_once()
        
        # Check that the correct agent was called
        self.agent1.ainvoke.assert_called_once()
        assert not self.agent2.ainvoke.called
        
        # Check agent outputs in result
        assert "agent_outputs" in result
        assert "iterations" in result
        assert "completed" in result
    
    @pytest.mark.asyncio
    async def test_message_formatting(self):
        """Test different message formatting options."""
        # Test inline format
        workflow_inline = PregelWorkflow(
            supervisor_agent=self.supervisor,
            agents=[self.agent1],
            agent_tools=self.agent_tools,
            include_agent_name="inline"
        )
        assert workflow_inline._format_agent_message("Hello", "agent1") == "Hello (from agent1)"
        
        # Test prefix format
        workflow_prefix = PregelWorkflow(
            supervisor_agent=self.supervisor,
            agents=[self.agent1],
            agent_tools=self.agent_tools,
            include_agent_name="prefix"
        )
        assert workflow_prefix._format_agent_message("Hello", "agent1") == "[agent1]: Hello"
        
        # Test suffix format
        workflow_suffix = PregelWorkflow(
            supervisor_agent=self.supervisor,
            agents=[self.agent1],
            agent_tools=self.agent_tools,
            include_agent_name="suffix"
        )
        assert workflow_suffix._format_agent_message("Hello", "agent1") == "Hello - agent1"
        
        # Test none format
        workflow_none = PregelWorkflow(
            supervisor_agent=self.supervisor,
            agents=[self.agent1],
            agent_tools=self.agent_tools,
            include_agent_name="none"
        )
        assert workflow_none._format_agent_message("Hello", "agent1") == "Hello"
    
    @pytest.mark.asyncio
    async def test_state_validation(self):
        """Test state validation with schema."""
        workflow = PregelWorkflow(
            supervisor_agent=self.supervisor,
            agents=[self.agent1],
            agent_tools=self.agent_tools,
            state_schema={
                "context": {"required": True, "default": {}},
                "history": {"required": True}
            }
        )
        
        # Test with empty state
        state = {}
        with pytest.raises(ValueError, match="Required state field 'history' is missing"):
            workflow._validate_state(state)
        
        # Test with incomplete state
        state = {"context": {}}
        with pytest.raises(ValueError, match="Required state field 'history' is missing"):
            workflow._validate_state(state)
        
        # Test with complete state
        state = {"context": {}, "history": []}
        validated = workflow._validate_state(state)
        assert "messages" in validated
        assert validated["messages"] == []
        assert validated["context"] == {}
        assert validated["history"] == []
    
    @pytest.mark.asyncio
    async def test_factory_function(self):
        """Test the create_pregel_workflow factory function."""
        workflow = create_pregel_workflow(
            supervisor_agent=self.supervisor,
            agents=[self.agent1, self.agent2],
            agent_tools=self.agent_tools,
            name="factory_test",
            max_iterations=5
        )
        
        assert isinstance(workflow, PregelWorkflow)
        assert workflow.name == "factory_test"
        assert workflow.max_iterations == 5
        assert "researcher" in workflow.agents
        assert "writer" in workflow.agents


if __name__ == "__main__":
    pytest.main(["-xvs", "test_workflow.py"])
EOF

echo -e "${GREEN}Test file for the Workflow Engine created.${NC}"

# Create example script
echo "Creating example script for using the new Workflow Engine..."

mkdir -p examples

cat > examples/workflow_example.py << 'EOF'
"""Example usage of the SynaptiCore Workflow Engine."""

import asyncio
import logging
from typing import List

from langchain_core.tools import tool
from langchain_core.messages import HumanMessage

from synapticore import AgentManager, LLMRegistry


@tool
def web_search(query: str) -> str:
    """Search the web for information.
    
    Args:
        query: The search query
        
    Returns:
        The search results
    """
    # In a real implementation, this would connect to a web search service
    print(f"Searching the web for: {query}")
    return f"Search results for '{query}': AI trends show an increase in the areas of..."


@tool
def write_report(content: str) -> str:
    """Create a structured report.
    
    Args:
        content: The content for the report
        
    Returns:
        The formatted report
    """
    # In a real implementation, this would use a more sophisticated report generator
    print(f"Creating report with content: {content}")
    return f"""# Report
    
## Summary
{content}

## Details
...
    """


async def main():
    # Configure logger
    logging.basicConfig(level=logging.INFO)
    
    # Initialize LLM Registry
    print("Initializing LLM Registry...")
    llm_registry = LLMRegistry()
    
    # For this example, an API key must be set in the 
    # OPENAI_API_KEY environment variable
    llm_registry.register_openai("gpt-4", model="gpt-4")
    
    # Create AgentManager
    print("Creating AgentManager...")
    manager = AgentManager(llm_registry=llm_registry, default_llm_id="gpt-4")
    
    # Create specialized agents
    print("Creating specialized agents...")
    research_agent_id = manager.create_agent(
        name="research_expert",
        tools=[web_search],
        prompt="You are a world-class researcher who gathers information. " 
               "Use the web_search tool to find information."
    )
    
    writing_agent_id = manager.create_agent(
        name="writing_expert",
        tools=[write_report],
        prompt="You are an expert report writer. "
               "Use the write_report tool to create well-structured reports."
    )
    
    # Create supervisor
    print("Creating supervisor...")
    supervisor_id = manager.create_supervisor(
        name="project_manager",
        agent_ids=[research_agent_id, writing_agent_id],
        prompt="You are a project manager coordinating a team of experts. "
               "Delegate tasks to the appropriate expert and ensure that "
               "requests are fully addressed.",
        max_iterations=5
    )
    
    # Compile workflow
    print("Compiling workflow...")
    manager.compile(supervisor_id)
    
    # Execute query
    print("\nStarting workflow execution with a query...\n")
    query = "Research current AI trends and create a report."
    result = await manager.ainvoke(supervisor_id, query)
    
    # Output result
    print("\nWorkflow result:")
    for message in result["messages"]:
        print(f"{message.type}: {message.content}")
    
    print(f"\nWorkflow completed in {result.get('iterations', 0)} iterations.")


if __name__ == "__main__":
    asyncio.run(main())
EOF

echo -e "${GREEN}Example script for the Workflow Engine created.${NC}"

# Create documentation for the Workflow Engine
echo "Creating documentation for the Workflow Engine..."

mkdir -p docs

cat > docs/workflow_engine.md << 'EOF'
# SynaptiCore Workflow Engine

The SynaptiCore Workflow Engine enables the creation and management of complex hierarchical agent structures with a supervisor agent coordinating specialized sub-agents.

## How It Works

The Workflow Engine is based on the Pregel model for distributed processing and implements the following core functionalities:

1. **Iterative Execution**: The workflow runs in iterations, with the supervisor agent deciding which action to take next in each iteration.

2. **Task Delegation**: The supervisor can delegate tasks to specialized agents by calling appropriate functions.

3. **State Management**: The workflow state is managed between iterations and can optionally be persisted.

4. **Checkpointing**: Optional storage of intermediate states for robustness and traceability.

## Usage

### 2. Compiling and Executing the Workflow

```python
# Compile workflow
manager.compile(supervisor_id)

# Execute query synchronously
result = manager.invoke(supervisor_id, "Research and write a report on AI trends.")

# Or execute asynchronously
result = await manager.ainvoke(supervisor_id, "Research and write a report on AI trends.")
```

### 3. Advanced Options

The Workflow Engine supports various customization options:

- **Agent Name Formatting**: Use the `include_agent_name` parameter to specify how agent names appear in messages (inline, prefix, suffix, none).
- **State Schemas**: Use `state_schema` and `config_schema` to define requirements for the state.
- **Checkpointing**: The workflow can create checkpoints if a checkpointer is provided.

## Architecture

The Workflow Engine consists of the following main components:

1. **PregelWorkflow**: The main class that manages the workflow state and coordinates execution.
2. **AgentManager**: Creates and manages agents and supervisors.
3. **create_pregel_workflow**: Factory function for creating workflow instances.

## Extension Possibilities

The Workflow Engine can be extended in the following ways:

1. **Custom Checkpointers**: Implement checkpointers for different storage systems.
2. **Advanced State Validation**: Implement more complex validation rules for workflow states.
3. **Metrics and Monitoring**: Add instrumentation for detailed monitoring.
4. **Parallelization**: Implement parallel execution of agent tasks.

## Example

A complete example can be found in the file `examples/workflow_example.py`.
EOF

echo -e "${GREEN}Documentation for the Workflow Engine created.${NC}"

echo
echo -e "${GREEN}Installation completed successfully!${NC}"
echo
echo "The following files were created or updated:"
echo " - src/synapticore/utils/workflow.py (updated)"
echo " - src/synapticore/utils/supervisors.py (updated)"
echo " - tests/synapticore/utils/test_workflow.py (new)"
echo " - examples/workflow_example.py (new)"
echo " - docs/workflow_engine.md (new)"
echo
echo "To test the new Workflow Engine, run the following command:"
echo "  pytest tests/synapticore/utils/test_workflow.py -v"
echo
echo "To run the example (requires OpenAI API key):"
echo "  python examples/workflow_example.py"
echo
echo "The complete documentation can be found in:"
echo "  docs/workflow_engine.md" 1. Creating Agents and a Supervisor

```python
from synapticore import AgentManager, LLMRegistry

# Initialize LLM Registry
llm_registry = LLMRegistry()
llm_registry.register_openai("gpt-4", model="gpt-4")

# Create AgentManager
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

# Create supervisor
supervisor_id = manager.create_supervisor(
    name="project_manager",
    agent_ids=[research_agent_id, writing_agent_id],
    prompt="You are a project manager.",
    max_iterations=5  # Maximum number of workflow iterations
)
```

###