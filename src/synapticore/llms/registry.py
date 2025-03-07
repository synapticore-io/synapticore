"""Registry for managing and accessing language models."""

from typing import Any, Dict, Optional, Union

from langchain_core.language_models import BaseLLM


class LLMRegistry:
    """Registry for storing and retrieving language models.
    
    This class provides a central registry for managing different LLM instances.
    It supports direct registration of LLM instances and convenience methods
    for common providers like OpenAI and Anthropic.
    """
    
    def __init__(self):
        """Initialize an empty LLM registry."""
        self._llms: Dict[str, BaseLLM] = {}
    
    def register(self, llm_id: str, llm: BaseLLM) -> None:
        """Register an LLM instance with the specified ID.
        
        Args:
            llm_id: The ID to register the LLM under.
            llm: The LLM instance to register.
            
        Raises:
            ValueError: If an LLM with the given ID is already registered.
        """
        if llm_id in self._llms:
            raise ValueError(f"An LLM with ID '{llm_id}' is already registered.")
        
        self._llms[llm_id] = llm
    
    def register_openai(
        self, 
        llm_id: str, 
        model: str = "gpt-4",
        **kwargs: Any
    ) -> None:
        """Register an OpenAI LLM with the specified ID.
        
        Args:
            llm_id: The ID to register the LLM under.
            model: The OpenAI model name.
            **kwargs: Additional arguments to pass to the OpenAI LLM constructor.
            
        Raises:
            ImportError: If the OpenAI integration is not installed.
            ValueError: If an LLM with the given ID is already registered.
        """
        try:
            from langchain_openai import ChatOpenAI
        except ImportError:
            raise ImportError(
                "OpenAI integration not found. "
                "Please install it with 'pip install -e .[openai]'."
            )
        
        llm = ChatOpenAI(model=model, **kwargs)
        self.register(llm_id, llm)
    
    def register_anthropic(
        self, 
        llm_id: str, 
        model: str = "claude-3-sonnet-20240229",
        **kwargs: Any
    ) -> None:
        """Register an Anthropic LLM with the specified ID.
        
        Args:
            llm_id: The ID to register the LLM under.
            model: The Anthropic model name.
            **kwargs: Additional arguments to pass to the Anthropic LLM constructor.
            
        Raises:
            ImportError: If the Anthropic integration is not installed.
            ValueError: If an LLM with the given ID is already registered.
        """
        try:
            from langchain_anthropic import ChatAnthropic
        except ImportError:
            raise ImportError(
                "Anthropic integration not found. "
                "Please install it with 'pip install -e .[anthropic]'."
            )
        
        llm = ChatAnthropic(model=model, **kwargs)
        self.register(llm_id, llm)
    
    def get(self, llm_id: str) -> BaseLLM:
        """Get the LLM with the specified ID.
        
        Args:
            llm_id: The ID of the LLM to retrieve.
            
        Returns:
            The LLM instance.
            
        Raises:
            ValueError: If no LLM with the given ID is registered.
        """
        if llm_id not in self._llms:
            raise ValueError(f"No LLM with ID '{llm_id}' is registered.")
        
        return self._llms[llm_id]
    
    def list_models(self) -> Dict[str, BaseLLM]:
        """Get a dictionary of all registered LLMs.
        
        Returns:
            A dictionary mapping IDs to LLM instances.
        """
        return self._llms.copy()
