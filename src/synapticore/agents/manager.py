"""Manager for creating and orchestrating hierarchical agent structures."""

from typing import Any, Dict, List, Optional, Union

from langchain.agents import AgentExecutor, create_react_agent
from langchain.agents.format_scratchpad import format_to_openai_functions
from langchain.agents.output_parsers import OpenAIFunctionsAgentOutputParser
from langchain_core.language_models import BaseLLM
from langchain_core.messages import BaseMessage, HumanMessage
from langchain_core.tools import BaseTool

from synapticore.llms import LLMRegistry
from synapticore.mcp import MCPManager, SSEConnection, StdioConnection
from synapticore.utils import create_supervisor, generate_mermaid_diagram, print_hierarchy_tree


class AgentManager:
    """
    Manager for creating and orchestrating hierarchical agent structures.

    This class provides a central manager for creating agents, organizing them
    into hierarchical structures with supervisors, and executing workflows.
    """

    def __init__(
        self,
        llm_registry: LLMRegistry,
        state_schema: Optional[Dict[str, Any]] = None,
        config_schema: Optional[Dict[str, Any]] = None,
        default_llm_id: Optional[str] = None,
        default_output_mode: str = "append",
        include_agent_name: str = "inline",
    ):
        """
        Initialize the AgentManager.

        Args:
            llm_registry: Registry for LLMs.
            state_schema: Schema for state objects.
            config_schema: Schema for configuration objects.
            default_llm_id: Default LLM ID to use for agents without a specified LLM.
            default_output_mode: Default mode for adding agent outputs to the message history.
            include_agent_name: How to include agent names in messages.
        """
        self.llm_registry = llm_registry
        self.state_schema = state_schema or {}
        self.config_schema = config_schema or {}
        self.default_llm_id = default_llm_id
        self.default_output_mode = default_output_mode
        self.include_agent_name = include_agent_name

        # Initialize MCP manager
        self.mcp_manager = MCPManager()

        # Storage for agents, supervisors, and compiled workflows
        self._agents = {}
        self._supervisors = {}
        self._compiled_workflows = {}

        # Hierarchical structure information
        self._hierarchy = {}

    def create_agent(
        self,
        name: str,
        llm_id: Optional[str] = None,
        tools: Optional[List[BaseTool]] = None,
        prompt: Optional[str] = None
    ) -> str:
        """
        Create an agent with the specified configuration.

        Args:
            name: Name of the agent.
            llm_id: ID of the LLM to use, or None to use the default.
            tools: Tools available to the agent.
            prompt: The prompt instructions for the agent.

        Returns:
            The ID of the created agent.

        Raises:
            ValueError: If an agent with the name already exists.
            ValueError: If no LLM ID is provided and no default LLM is set.
        """
        if name in self._agents:
            raise ValueError(f"Agent with name '{name}' already exists.")

        used_llm_id = llm_id or self.default_llm_id
        if used_llm_id is None:
            raise ValueError(
                "No LLM ID provided and no default LLM set. "
                "Please provide an LLM ID or set a default LLM."
            )

        # Get the LLM from the registry
        try:
            llm = self.llm_registry.get(used_llm_id)
        except ValueError as e:
            raise ValueError(f"Error retrieving LLM: {str(e)}")

        # Default agent prompt if none provided
        if prompt is None:
            prompt = f"""You are an expert assistant specialized in utilizing tools to solve complex problems.
You have access to the following tools:

{', '.join([tool.name for tool in (tools or [])])}

Always think step by step about what tool to use based on the user's request.
"""

        # Create the agent
        react_agent = create_react_agent(
            llm=llm,
            tools=tools or [],
            prompt_template=prompt
        )

        agent_executor = AgentExecutor(
            agent=react_agent,
            tools=tools or [],
            verbose=True,
            handle_parsing_errors=True,
        )

        # Add agent name attribute
        agent_executor.name = name

        # Store the agent
        agent_id = name
        self._agents[agent_id] = agent_executor
        self._hierarchy[agent_id] = {
            "type": "agent",
            "name": name,
            "llm_id": used_llm_id,
            "children": [],
            "parent": None
        }

        return agent_id

    def create_supervisor(
        self,
        name: str,
        agent_ids: List[str],
        llm_id: Optional[str] = None,
        prompt: Optional[str] = None,
        tools: Optional[List[BaseTool]] = None,
        output_mode: Optional[str] = None,
        add_handoff_back_messages: bool = True,
    ) -> str:
        """
        Create a supervisor to manage multiple agents.

        Args:
            name: Name of the supervisor.
            agent_ids: IDs of the agents to be managed by the supervisor.
            llm_id: ID of the LLM to use, or None to use the default.
            prompt: The prompt for the supervisor.
            tools: Additional tools for the supervisor.
            output_mode: Mode for adding agent outputs to the message history.
            add_handoff_back_messages: Whether to add handoff messages.

        Returns:
            The ID of the created supervisor.

        Raises:
            ValueError: If a supervisor with the name already exists.
            ValueError: If no LLM ID is provided and no default LLM is set.
            ValueError: If the specified LLM is not registered.
            ValueError: If a specified agent does not exist.
        """
        if name in self._supervisors:
            raise ValueError(f"Supervisor with name '{name}' already exists.")

        used_llm_id = llm_id or self.default_llm_id
        if used_llm_id is None:
            raise ValueError(
                "No LLM ID provided and no default LLM set. "
                "Please provide an LLM ID or set a default LLM."
            )

        # Get the LLM from the registry
        try:
            llm = self.llm_registry.get(used_llm_id)
        except ValueError as e:
            raise ValueError(f"Error retrieving LLM: {str(e)}")

        agents = []
        for agent_id in agent_ids:
            if agent_id in self._agents:
                agents.append(self._agents[agent_id])
            elif agent_id in self._compiled_workflows:
                agents.append(self._compiled_workflows[agent_id])
            else:
                raise ValueError(f"Agent or workflow with ID '{agent_id}' does not exist.")

        supervisor = create_supervisor(
            agents=agents,
            model=llm,
            tools=tools,
            prompt=prompt,
            state_schema=self.state_schema,
            config_schema=self.config_schema,
            output_mode=output_mode or self.default_output_mode,
            add_handoff_back_messages=add_handoff_back_messages,
            supervisor_name=name,
            include_agent_name=self.include_agent_name,
        )

        supervisor_id = name
        self._supervisors[supervisor_id] = supervisor
        self._hierarchy[supervisor_id] = {
            "type": "supervisor",
            "name": name,
            "llm_id": used_llm_id,
            "children": agent_ids,
            "parent": None
        }

        # Update hierarchy information for children
        for agent_id in agent_ids:
            if agent_id in self._hierarchy:
                self._hierarchy[agent_id]["parent"] = supervisor_id

        return supervisor_id

    def compile(
        self,
        supervisor_id: str,
        checkpointer=None,
        store=None
    ) -> str:
        """
        Compile a supervisor workflow for execution.

        Args:
            supervisor_id: The ID of the supervisor to compile.
            checkpointer: An optional checkpointer for persistence.
            store: An optional store for persistence.

        Returns:
            The ID of the compiled workflow.

        Raises:
            ValueError: If the supervisor does not exist.
        """
        if supervisor_id not in self._supervisors:
            raise ValueError(f"Supervisor with ID '{supervisor_id}' does not exist.")

        supervisor = self._supervisors[supervisor_id]
        compiled = supervisor.compile(
            name=supervisor_id,
            checkpointer=checkpointer,
            store=store,
        )

        self._compiled_workflows[supervisor_id] = compiled
        return supervisor_id

    def invoke(self, workflow_id: str, input_data: Union[str, List[BaseMessage], Dict[str, Any]]) -> Dict[str, Any]:
        """
        Execute a compiled workflow with given input.

        Args:
            workflow_id: The ID of the workflow to execute.
            input_data: The input for the workflow. Can be a string, a list of messages,
                       or a dictionary with complete state.

        Returns:
            The result of the workflow execution.

        Raises:
            ValueError: If the workflow does not exist.
        """
        if workflow_id not in self._compiled_workflows:
            raise ValueError(f"Compiled workflow with ID '{workflow_id}' does not exist.")

        workflow = self._compiled_workflows[workflow_id]

        # Prepare input
        if isinstance(input_data, str):
            # If input is a string, convert to a HumanMessage
            messages = [HumanMessage(content=input_data)]
            state = {"messages": messages}
        elif isinstance(input_data, list) and all(isinstance(m, BaseMessage) for m in input_data):
            # If input is a list of messages
            state = {"messages": input_data}
        elif isinstance(input_data, dict):
            # If input is a complete state
            state = input_data
        else:
            raise ValueError(f"Invalid input format: {type(input_data)}. "
                            "Must be a string, a list of messages, or a state dictionary.")

        return workflow.invoke(state)

    async def ainvoke(self, workflow_id: str, input_data: Union[str, List[BaseMessage], Dict[str, Any]]) -> Dict[str, Any]:
        """
        Execute a compiled workflow asynchronously with given input.

        Args:
            workflow_id: The ID of the workflow to execute.
            input_data: The input for the workflow. Can be a string, a list of messages,
                       or a dictionary with complete state.

        Returns:
            The result of the workflow execution.

        Raises:
            ValueError: If the workflow does not exist.
        """
        if workflow_id not in self._compiled_workflows:
            raise ValueError(f"Compiled workflow with ID '{workflow_id}' does not exist.")

        workflow = self._compiled_workflows[workflow_id]

        # Prepare input
        if isinstance(input_data, str):
            # If input is a string, convert to a HumanMessage
            messages = [HumanMessage(content=input_data)]
            state = {"messages": messages}
        elif isinstance(input_data, list) and all(isinstance(m, BaseMessage) for m in input_data):
            # If input is a list of messages
            state = {"messages": input_data}
        elif isinstance(input_data, dict):
            # If input is a complete state
            state = input_data
        else:
            raise ValueError(f"Invalid input format: {type(input_data)}. "
                            "Must be a string, a list of messages, or a state dictionary.")

        return await workflow.ainvoke(state)

    def get_agent(self, agent_id: str) -> Any:
        """
        Get the agent with the specified ID.

        Args:
            agent_id: The ID of the agent.

        Returns:
            The agent.

        Raises:
            ValueError: If the agent does not exist.
        """
        if agent_id in self._agents:
            return self._agents[agent_id]
        elif agent_id in self._compiled_workflows:
            return self._compiled_workflows[agent_id]
        else:
            raise ValueError(f"Agent or workflow with ID '{agent_id}' does not exist.")

    def get_hierarchy(self, root_id: Optional[str] = None) -> Dict:
        """
        Get the hierarchy of agents, starting from the specified root.

        Args:
            root_id: The ID of the root. If None, return the entire hierarchy.

        Returns:
            The hierarchy as a nested dictionary.
        """
        if root_id is None:
            # Find all root supervisors (those without parents)
            roots = {
                id: info for id, info in self._hierarchy.items()
                if info["parent"] is None
            }

            if len(roots) == 1:
                # If there's only one root, return its hierarchy
                root_id = next(iter(roots.keys()))
                return self._build_hierarchy_tree(root_id)
            else:
                # If there are multiple roots, return the entire hierarchy
                return {
                    id: self._build_hierarchy_tree(id)
                    for id in roots.keys()
                }
        else:
            # Return the hierarchy for the specified root
            if root_id not in self._hierarchy:
                raise ValueError(f"Agent or supervisor with ID '{root_id}' does not exist.")

            return self._build_hierarchy_tree(root_id)

    def _build_hierarchy_tree(self, node_id: str) -> Dict:
        """
        Build a hierarchy tree recursively, starting from the specified node.

        Args:
            node_id: The ID of the starting node.

        Returns:
            The hierarchy tree as a nested dictionary.
        """
        node_info = self._hierarchy[node_id]
        result = {
            "type": node_info["type"],
            "name": node_info["name"],
            "llm_id": node_info.get("llm_id", ""),
        }

        if node_info["children"]:
            result["children"] = {
                child_id: self._build_hierarchy_tree(child_id)
                for child_id in node_info["children"]
            }

        return result

    def print_hierarchy(self, root_id: Optional[str] = None, indent: int = 0) -> None:
        """
        Print the hierarchy in a readable format.

        Args:
            root_id: The ID of the root. If None, print the entire hierarchy.
            indent: The indentation level for recursive output.
        """
        print_hierarchy_tree(self._hierarchy, root_id, indent)

    def visualize_hierarchy(self, root_id: Optional[str] = None, title: str = "Agent Hierarchy") -> str:
        """
        Generate a Mermaid diagram to visualize the agent structure.

        Args:
            root_id: The ID of the root. If None, visualize the entire hierarchy.
            title: The title of the diagram.

        Returns:
            A Mermaid diagram as a string.
        """
        return generate_mermaid_diagram(self._hierarchy, root_id, title)

    async def register_mcp_client(
        self,
        server_id: str,
        connection_params: Union[StdioConnection, SSEConnection],
    ) -> None:
        """
        Register and connect an MCP client.

        Args:
            server_id: A unique ID for the server.
            connection_params: Parameters for the connection.

        Raises:
            ValueError: If the server is already registered.
        """
        transport = connection_params.get("transport")
        if transport == "stdio":
            self.mcp_manager.register_stdio_server(
                server_id=server_id,
                command=connection_params["command"],
                args=connection_params["args"],
                env=connection_params.get("env"),
                encoding=connection_params.get("encoding", "utf-8"),
                encoding_error_handler=connection_params.get("encoding_error_handler", "strict"),
            )
        elif transport == "sse":
            self.mcp_manager.register_sse_server(
                server_id=server_id,
                url=connection_params["url"],
            )
        else:
            raise ValueError(f"Unknown transport type: {transport}")

        # Initialize the MCP manager if it's not already initialized
        if not self.mcp_manager.is_initialized:
            await self.mcp_manager.initialize()
