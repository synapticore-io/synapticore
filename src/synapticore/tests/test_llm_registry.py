"""Tests for the LLM Registry."""

import unittest
from unittest.mock import MagicMock, patch

from synapticore.llms import LLMRegistry


class TestLLMRegistry(unittest.TestCase):
    """Tests for the LLMRegistry class."""

    def setUp(self):
        """Initialize before each test."""
        self.registry = LLMRegistry()

    def test_register_and_get(self):
        """Test registering and retrieving a model."""
        mock_model = MagicMock()

        # Register a model
        self.registry.register("test_model", mock_model)

        # Get the model back
        retrieved_model = self.registry.get("test_model")

        # Check if it's the same model
        self.assertEqual(retrieved_model, mock_model)

    def test_list_models(self):
        """Test listing all models."""
        mock_model1 = MagicMock()
        mock_model2 = MagicMock()

        # Register two models
        self.registry.register("model1", mock_model1)
        self.registry.register("model2", mock_model2)

        # Get the list of all models
        models = self.registry.list_models()

        # Check if both models are in the list
        self.assertEqual(len(models), 2)
        self.assertIn("model1", models)
        self.assertIn("model2", models)
        self.assertEqual(models["model1"], mock_model1)
        self.assertEqual(models["model2"], mock_model2)

    def test_register_duplicate(self):
        """Test registering a model with an already used ID."""
        mock_model = MagicMock()

        # Register a model
        self.registry.register("test_model", mock_model)

        # Try to register a model with the same ID
        with self.assertRaises(ValueError):
            self.registry.register("test_model", mock_model)

    def test_get_nonexistent(self):
        """Test retrieving a non-registered model."""
        # Try to get a non-registered model
        with self.assertRaises(ValueError):
            self.registry.get("nonexistent_model")
