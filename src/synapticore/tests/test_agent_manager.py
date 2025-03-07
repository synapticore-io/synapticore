"""Tests for the Agent Manager."""

import unittest
from unittest.mock import MagicMock, patch

from synapticore.agents import AgentManager
from synapticore.llms import LLMRegistry


class TestAgentManager(unittest.TestCase):
    """Tests for the AgentManager class."""

    def setUp(self):
        """Initialize before each test."""
        # Mock for LLMRegistry
        self.llm_registry = MagicMock(spec=LLMRegistry)
        self.mock_llm = MagicMock()
        self.llm_registry.get.return_value = self.mock_llm

        # Create AgentManager with the mock
        self.manager = AgentManager(llm_registry=self.llm_registry, default_llm_id="default_llm")

    @patch("synapticore.agents.manager.create_react_agent")
    def test_create_agent(self, mock_create_agent):
        """Test creating an agent."""
        # Mock for create_react_agent
        mock_agent = MagicMock()
        mock_create_agent.return_value = mock_agent

        # Create an agent
        agent_id = self.manager.create_agent(
            name="test_agent",
            llm_id="test_llm",
            tools=[],
            prompt="Test instructions"
        )

        # Checks
        self.assertEqual(agent_id, "test_agent")
        self.llm_registry.get.assert_called_once_with("test_llm")
        mock_create_agent.assert_called_once()
        self.assertIn(agent_id, self.manager._agents)
        self.assertIn(agent_id, self.manager._hierarchy)
        self.assertEqual(self.manager._hierarchy[agent_id]["type"], "agent")
        self.assertEqual(self.manager._hierarchy[agent_id]["name"], "test_agent")
        self.assertEqual(self.manager._hierarchy[agent_id]["llm_id"], "test_llm")
