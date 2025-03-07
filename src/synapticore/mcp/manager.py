"""Manager for Message Control Protocol (MCP) connections with external services."""

import asyncio
import json
import logging
import subprocess
from asyncio import Queue
from typing import Any, Dict, List, Optional, Protocol, TypedDict, Union

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class StdioConnection(TypedDict):
    """Type definition for stdio connection parameters."""
    
    transport: str  # Must be "stdio"
    command: str
    args: List[str]
    env: Optional[Dict[str, str]]
    encoding: Optional[str]
    encoding_error_handler: Optional[str]


class SSEConnection(TypedDict):
    """Type definition for SSE connection parameters."""
    
    transport: str  # Must be "sse"
    url: str


class MCPServerProtocol(Protocol):
    """Protocol defining the interface for an MCP server."""
    
    def send_message(self, message: Dict[str, Any]) -> None:
        """Send a message to the server."""
        ...
    
    async def start(self) -> None:
        """Start the server connection."""
        ...
    
    async def stop(self) -> None:
        """Stop the server connection."""
        ...


class StdioMCPServer:
    """MCP server implementation using stdio for communication."""
    
    def __init__(
        self,
        command: str,
        args: List[str],
        env: Optional[Dict[str, str]] = None,
        encoding: str = "utf-8",
        encoding_error_handler: str = "strict",
    ):
        """Initialize a stdio MCP server.
        
        Args:
            command: The command to run.
            args: Arguments for the command.
            env: Environment variables to set.
            encoding: Character encoding for stdin/stdout.
            encoding_error_handler: Error handler for encoding/decoding.
        """
        self.command = command
        self.args = args
        self.env = env
        self.encoding = encoding
        self.encoding_error_handler = encoding_error_handler
        self.process: Optional[subprocess.Popen] = None
        self.message_queue: Queue = Queue()
        self._message_loop_task: Optional[asyncio.Task] = None
    
    def send_message(self, message: Dict[str, Any]) -> None:
        """Queue a message to be sent to the server.
        
        Args:
            message: The message to send.
        """
        self.message_queue.put_nowait(message)
    
    async def _message_loop(self) -> None:
        """Background task for processing messages."""
        if not self.process:
            logger.error("Process not initialized")
            return
        
        try:
            while True:
                message = await self.message_queue.get()
                
                if message is None:  # Sentinel to stop the loop
                    break
                
                # Serialize and send the message
                message_json = json.dumps(message) + "\n"
                if self.process.stdin:
                    self.process.stdin.write(message_json.encode(self.encoding, self.encoding_error_handler))
                    self.process.stdin.flush()
                
                self.message_queue.task_done()
        except Exception as e:
            logger.error(f"Error in message loop: {e}")
    
    async def start(self) -> None:
        """Start the server process."""
        try:
            # Start the process
            self.process = subprocess.Popen(
                [self.command] + self.args,
                env=self.env,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=False,  # We'll handle encoding ourselves
            )
            
            # Start the message processing loop
            self._message_loop_task = asyncio.create_task(self._message_loop())
            
            logger.info(f"Started stdio MCP server with command: {self.command}")
        except Exception as e:
            logger.error(f"Failed to start stdio MCP server: {e}")
            raise
    
    async def stop(self) -> None:
        """Stop the server process."""
        # Signal the message loop to stop
        if self._message_loop_task:
            self.message_queue.put_nowait(None)  # Sentinel value
            await self._message_loop_task
        
        # Terminate the process
        if self.process:
            self.process.terminate()
            await asyncio.sleep(0.1)  # Give it a moment to terminate
            
            # Force kill if still running
            if self.process.poll() is None:
                self.process.kill()
            
            logger.info("Stopped stdio MCP server")


class SSEMCPServer:
    """MCP server implementation using Server-Sent Events (SSE) for communication."""
    
    def __init__(self, url: str):
        """Initialize an SSE MCP server.
        
        Args:
            url: The URL of the SSE endpoint.
        """
        self.url = url
        self.message_queue: Queue = Queue()
        self._message_loop_task: Optional[asyncio.Task] = None
        self._client: Any = None  # Type will be determined at runtime
    
    def send_message(self, message: Dict[str, Any]) -> None:
        """Queue a message to be sent to the server.
        
        Args:
            message: The message to send.
        """
        self.message_queue.put_nowait(message)
    
    async def _message_loop(self) -> None:
        """Background task for processing messages."""
        try:
            while True:
                message = await self.message_queue.get()
                
                if message is None:  # Sentinel to stop the loop
                    break
                
                # For simplicity, we'll just log the message
                # In a real implementation, this would send the message via HTTP POST
                logger.info(f"Would send message to {self.url}: {json.dumps(message)}")
                
                self.message_queue.task_done()
        except Exception as e:
            logger.error(f"Error in message loop: {e}")
    
    async def start(self) -> None:
        """Start the SSE client."""
        try:
            # We don't actually connect in this example
            # In a real implementation, this would connect to the SSE endpoint
            
            # Start the message processing loop
            self._message_loop_task = asyncio.create_task(self._message_loop())
            
            logger.info(f"Started SSE MCP client for URL: {self.url}")
        except ImportError:
            logger.error("SSE client dependencies not installed. Please install with 'pip install -e .[mcp]'")
            raise
        except Exception as e:
            logger.error(f"Failed to start SSE MCP client: {e}")
            raise
    
    async def stop(self) -> None:
        """Stop the SSE client."""
        # Signal the message loop to stop
        if self._message_loop_task:
            self.message_queue.put_nowait(None)  # Sentinel value
            await self._message_loop_task
        
        logger.info("Stopped SSE MCP client")


class MCPManager:
    """Manager for MCP server connections."""
    
    def __init__(self):
        """Initialize an empty MCP manager."""
        self._servers: Dict[str, MCPServerProtocol] = {}
        self.is_initialized = False
    
    def register_stdio_server(
        self,
        server_id: str,
        command: str,
        args: List[str],
        env: Optional[Dict[str, str]] = None,
        encoding: str = "utf-8",
        encoding_error_handler: str = "strict",
    ) -> None:
        """Register a stdio MCP server.
        
        Args:
            server_id: A unique ID for the server.
            command: The command to run.
            args: Arguments for the command.
            env: Environment variables to set.
            encoding: Character encoding for stdin/stdout.
            encoding_error_handler: Error handler for encoding/decoding.
            
        Raises:
            ValueError: If the server ID is already registered.
        """
        if server_id in self._servers:
            raise ValueError(f"Server with ID '{server_id}' is already registered.")
        
        server = StdioMCPServer(
            command=command,
            args=args,
            env=env,
            encoding=encoding,
            encoding_error_handler=encoding_error_handler,
        )
        
        self._servers[server_id] = server
    
    def register_sse_server(self, server_id: str, url: str) -> None:
        """Register an SSE MCP server.
        
        Args:
            server_id: A unique ID for the server.
            url: The URL of the SSE endpoint.
            
        Raises:
            ValueError: If the server ID is already registered.
        """
        if server_id in self._servers:
            raise ValueError(f"Server with ID '{server_id}' is already registered.")
        
        server = SSEMCPServer(url=url)
        self._servers[server_id] = server
    
    async def initialize(self) -> None:
        """Initialize all registered servers."""
        for server_id, server in self._servers.items():
            try:
                await server.start()
                logger.info(f"Initialized server {server_id}")
            except Exception as e:
                logger.error(f"Failed to initialize server {server_id}: {e}")
        
        self.is_initialized = True
    
    async def shutdown(self) -> None:
        """Shut down all registered servers."""
        for server_id, server in self._servers.items():
            try:
                await server.stop()
                logger.info(f"Shut down server {server_id}")
            except Exception as e:
                logger.error(f"Failed to shut down server {server_id}: {e}")
        
        self.is_initialized = False
    
    def send_message(self, server_id: str, message: Dict[str, Any]) -> None:
        """Send a message to a specific server.
        
        Args:
            server_id: The ID of the server to send the message to.
            message: The message to send.
            
        Raises:
            ValueError: If no server with the given ID is registered.
        """
        if server_id not in self._servers:
            raise ValueError(f"No server with ID '{server_id}' is registered.")
        
        self._servers[server_id].send_message(message)
