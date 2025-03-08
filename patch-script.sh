#!/bin/bash

cat > session_manager.py << 'EOF'
import asyncio
import logging
from contextlib import asynccontextmanager
from enum import Enum
from typing import Any, Dict, List, Optional, Union, Callable, AsyncIterator, TypeVar

from mcp.client.session import ClientSession
from mcp.client.stdio import StdioServerParameters, stdio_client
from mcp.client.sse import sse_client
from mcp.shared.exceptions import McpError

logger = logging.getLogger(__name__)

# Generic type for session results
T = TypeVar('T')

class ConnectionType(Enum):
    """Connection types supported by SessionManager."""
    STDIO = "stdio"
    SSE = "sse"

class MCPSessionManager:
    """
    Manages multiple MCP ClientSessions across different transport types.
    Provides a unified interface for common MCP operations.
    """
    
    def __init__(self):
        self._sessions: Dict[str, ClientSession] = {}
        self._active_tasks: Dict[str, asyncio.Task] = {}
    
    async def create_session(
        self, 
        session_id: str,
        connection_type: ConnectionType,
        command_or_url: str,
        args: List[str] = None,
        env: Dict[str, str] = None,
        callbacks: Dict[str, Callable] = None
    ) -> ClientSession:
        """Creates a new MCP ClientSession with the specified connection type."""
        if session_id in self._sessions:
            raise ValueError(f"Session with ID {session_id} already exists")
        
        try:
            # Prepare callbacks
            callbacks = callbacks or {}
            sampling_callback = callbacks.get('sampling')
            list_roots_callback = callbacks.get('list_roots')
            
            # Create appropriate connection
            if connection_type == ConnectionType.STDIO:
                server_params = StdioServerParameters(
                    command=command_or_url,
                    args=args or [],
                    env=env
                )
                streams = await stdio_client(server_params).__aenter__()
            elif connection_type == ConnectionType.SSE:
                streams = await sse_client(command_or_url).__aenter__()
            else:
                raise ValueError(f"Unsupported connection type: {connection_type}")
            
            # Create and initialize session
            session = ClientSession(
                *streams,
                sampling_callback=sampling_callback,
                list_roots_callback=list_roots_callback
            )
            await session.__aenter__()
            await session.initialize()
            
            # Store session and start message receiver
            self._sessions[session_id] = session
            self._active_tasks[session_id] = asyncio.create_task(
                self._receive_messages(session_id, session)
            )
            
            return session
            
        except Exception as e:
            logger.error(f"Failed to create session {session_id}: {e}")
            raise
    
    async def close_session(self, session_id: str) -> None:
        """Closes and cleans up a specific session."""
        if session_id not in self._sessions:
            logger.warning(f"Attempted to close non-existent session: {session_id}")
            return
        
        # Cancel message receiver and close session
        if session_id in self._active_tasks:
            self._active_tasks[session_id].cancel()
            try:
                await self._active_tasks[session_id]
            except asyncio.CancelledError:
                pass
            del self._active_tasks[session_id]
        
        session = self._sessions[session_id]
        await session.__aexit__(None, None, None)
        del self._sessions[session_id]
        
        logger.info(f"Closed session: {session_id}")
    
    async def close_all_sessions(self) -> None:
        """Closes all active sessions."""
        for session_id in list(self._sessions.keys()):
            await self.close_session(session_id)
    
    def get_session(self, session_id: str) -> Optional[ClientSession]:
        """Gets a session by ID."""
        return self._sessions.get(session_id)
    
    def list_sessions(self) -> List[str]:
        """Lists all active session IDs."""
        return list(self._sessions.keys())
    
    async def _receive_messages(self, session_id: str, session: ClientSession) -> None:
        """Background task to receive and process messages from a session."""
        try:
            async for message in session.incoming_messages:
                if isinstance(message, Exception):
                    logger.error(f"Error in session {session_id}: {message}")
                else:
                    logger.debug(f"Received message in session {session_id}: {message}")
        except asyncio.CancelledError:
            pass  # Normal cancellation during close
        except Exception as e:
            logger.error(f"Error receiving messages for session {session_id}: {e}")
    
    async def execute_operation(
        self, 
        session_id: str, 
        operation: Callable[[ClientSession], AsyncIterator[T]], 
        *args, 
        **kwargs
    ) -> T:
        """
        Executes any session operation with proper error handling.
        Generic method to reduce code duplication.
        
        Args:
            session_id: ID of the session
            operation: Async function to execute on the session
            *args, **kwargs: Arguments to pass to the operation
            
        Returns:
            Result of the operation
        """
        session = self.get_session(session_id)
        if not session:
            raise ValueError(f"Session {session_id} not found")
        
        try:
            return await operation(session, *args, **kwargs)
        except McpError as e:
            logger.error(f"Error executing operation on session {session_id}: {e}")
            raise
    
    # Simplified session operations using the generic executor
    
    async def list_tools(self, session_id: str) -> Any:
        """Lists tools available in a session."""
        async def operation(session):
            result = await session.list_tools()
            return result.tools
        return await self.execute_operation(session_id, operation)
    
    async def call_tool(self, session_id: str, tool_name: str, arguments: Dict[str, Any] = None) -> Any:
        """Calls a tool on a session."""
        async def operation(session):
            return await session.call_tool(tool_name, arguments or {})
        return await self.execute_operation(session_id, operation)
    
    async def list_resources(self, session_id: str) -> Any:
        """Lists resources available in a session."""
        async def operation(session):
            result = await session.list_resources()
            return result.resources
        return await self.execute_operation(session_id, operation)
    
    async def read_resource(self, session_id: str, uri: str) -> Any:
        """Reads a resource from a session."""
        async def operation(session):
            return await session.read_resource(uri)
        return await self.execute_operation(session_id, operation)
    
    async def list_prompts(self, session_id: str) -> Any:
        """Lists prompts available in a session."""
        async def operation(session):
            result = await session.list_prompts()
            return result.prompts
        return await self.execute_operation(session_id, operation)
    
    async def get_prompt(self, session_id: str, name: str, arguments: Dict[str, str] = None) -> Any:
        """Gets a prompt from a session."""
        async def operation(session):
            return await session.get_prompt(name, arguments)
        return await self.execute_operation(session_id, operation)
    
    @asynccontextmanager
    async def managed_session(
        self,
        session_id: str,
        connection_type: ConnectionType,
        command_or_url: str,
        args: List[str] = None,
        env: Dict[str, str] = None,
        callbacks: Dict[str, Callable] = None
    ) -> AsyncIterator[ClientSession]:
        """Context manager for a session that automatically closes when done."""
        session = await self.create_session(
            session_id, connection_type, command_or_url, args, env, callbacks
        )
        
        try:
            yield session
        finally:
            await self.close_session(session_id)


# Example usage
async def example():
    # Create a session manager
    manager = MCPSessionManager()
    
    try:
        # Using the context manager pattern for automatic cleanup
        async with manager.managed_session(
            "example_session",
            ConnectionType.STDIO,
            "python",
            ["my_server.py"]
        ) as session:
            # List available tools
            tools = await manager.list_tools("example_session")
            print(f"Available tools: {tools}")
            
            # Call a tool
            result = await manager.call_tool(
                "example_session",
                "example_tool",
                {"param1": "value1"}
            )
            print(f"Tool result: {result}")
    
    except Exception as e:
        print(f"Error: {e}")
        # Ensure we clean up in case of error
        await manager.close_all_sessions()

if __name__ == "__main__":
    asyncio.run(example())
EOF

echo "Optimierter MCP Session Manager wurde in session_manager.py geschrieben."
