"""Minimal session manager for MCP client sessions."""

import asyncio
import logging
from contextlib import asynccontextmanager
from enum import Enum
from typing import Any, Dict, List, Optional, Callable, AsyncIterator

from mcp.client.session import ClientSession
from mcp.client.stdio import StdioServerParameters, stdio_client
from mcp.client.sse import sse_client

logger = logging.getLogger(__name__)

class ConnectionType(Enum):
    """Connection types supported by MCP."""
    STDIO = "stdio"
    SSE = "sse"

class MCPSessionManager:
    """Simple manager for MCP client sessions."""
    
    def __init__(self):
        self._sessions: Dict[str, ClientSession] = {}
        self._tasks: Dict[str, asyncio.Task] = {}
    
    @asynccontextmanager
    async def managed_session(
        self,
        session_id: str,
        connection_type: ConnectionType,
        command_or_url: str,
        args: List[str] = None,
        env: Dict[str, str] = None,
        sampling_callback: Optional[Callable] = None
    ) -> AsyncIterator[ClientSession]:
        """Creates a session and automatically closes it when done."""
        # Create streams based on connection type
        if connection_type == ConnectionType.STDIO:
            params = StdioServerParameters(
                command=command_or_url,
                args=args or [],
                env=env
            )
            streams = await stdio_client(params).__aenter__()
        elif connection_type == ConnectionType.SSE:
            streams = await sse_client(command_or_url).__aenter__()
        else:
            raise ValueError(f"Unsupported connection type: {connection_type}")
        
        # Create and initialize the session
        session = ClientSession(*streams, sampling_callback=sampling_callback)
        await session.__aenter__()
        await session.initialize()
        
        # Store the session
        self._sessions[session_id] = session
        
        # Start message receiver
        self._tasks[session_id] = asyncio.create_task(self._receive_messages(session))
        
        try:
            yield session
        finally:
            # Clean up
            if session_id in self._tasks:
                self._tasks[session_id].cancel()
                try:
                    await self._tasks[session_id]
                except asyncio.CancelledError:
                    pass
                del self._tasks[session_id]
            
            # Close session
            await session.__aexit__(None, None, None)
            if session_id in self._sessions:
                del self._sessions[session_id]
    
    async def _receive_messages(self, session: ClientSession) -> None:
        """Minimal message receiver for logging purposes."""
        try:
            async for message in session.incoming_messages:
                if isinstance(message, Exception):
                    logger.error(f"MCP session error: {message}")
                else:
                    logger.debug(f"MCP message: {message}")
        except asyncio.CancelledError:
            pass
        except Exception as e:
            logger.error(f"Error receiving MCP messages: {e}")
