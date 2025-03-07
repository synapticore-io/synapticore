from setuptools import setup, find_packages

setup(
    name="synapticore",
    version="0.1.0",
    package_dir={"": "src"},
    packages=find_packages(where="src"),
    install_requires=[
        "langchain>=0.1.0",
        "langchain-core>=0.1.0",
    ],
    extras_require={
        "dev": [
            "pytest>=7.0.0",
            "black>=23.0.0",
            "isort>=5.0.0",
            "mypy>=1.0.0",
        ],
        "openai": [
            "openai>=1.0.0",
        ],
        "anthropic": [
            "anthropic>=0.5.0",
        ],
        "mcp": [
            "aiohttp>=3.8.0",
            "sseclient-py>=1.7.0",
        ],
        "all": [
            "openai>=1.0.0",
            "anthropic>=0.5.0",
            "aiohttp>=3.8.0",
            "sseclient-py>=1.7.0",
        ],
    },
    python_requires=">=3.8",
    description="A hierarchical agent manager for orchestrating LLM-based agents",
    author="Your Name",
    author_email="your.email@example.com",
    url="https://github.com/yourusername/synapticore",
)
