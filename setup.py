from setuptools import setup, find_packages

setup(
    name="hierarchical-agent-system",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        "langchain>=0.2.0",
        "langchain-core>=0.1.0",
        "langchain-openai>=0.0.4",
        "langchain-community>=0.0.16",
        "langgraph>=0.0.20",
        "openai>=1.9.0",
        "hvac>=1.2.1",
        "pydantic>=2.5.0",
        "fastapi>=0.104.1",
        "uvicorn>=0.24.0",
        "python-dotenv>=1.0.0",
    ],
)
