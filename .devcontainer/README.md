# Reusable Development Container

This directory contains a reusable development container configuration that can be used across different projects. The container is designed to provide a consistent development environment with Python, Node.js, Bun.js, and NVIDIA CUDA support.

## Features

- **Python Development**:
  - Python 3.13.2 with UV as package manager for reproducible builds
  - Virtual environment created only when Python project is detected
  - Automatic dependency installation from pyproject.toml or requirements.txt

- **JavaScript/TypeScript Development**:
  - Node.js 20.x with npm, yarn, and pnpm
  - Bun.js 1.2.4 for JavaScript/TypeScript development
  - Vite support with automatic project detection
  - Global installation of common tools (typescript, create-vite)

- **Infrastructure**:
  - NVIDIA CUDA 12.8.0 with GPU acceleration for compute-intensive tasks
  - Git LFS support
  - SSH agent forwarding
  - Docker-in-Docker support
  - Consistent user permissions with standardized UIDs/GIDs

## Usage

To use this development container in your project:

1. Copy the `.devcontainer` directory to your project root
2. Customize the `Dockerfile` if needed for your specific project requirements
3. Open the project in VS Code and click "Reopen in Container" when prompted

## Project Type Detection

The container automatically detects the type of project and sets up the environment accordingly:

- **Python Projects**: Detected by the presence of `pyproject.toml`, `requirements.txt`, or `setup.py`
- **Node.js Projects**: Detected by the presence of `package.json`
- **Vite Projects**: Detected by the presence of `vite` in `package.json` dependencies

## Configuration

The container is configured to use the following directory structure:

- `/workspaces/[project-name]/.venv` - Python virtual environment (created only if needed)
- `/workspaces/[project-name]/.cache` - Cache directory for UV and other tools
- `/workspaces/[project-name]/logs` - Directory for log files
- `/workspaces/[project-name]/data` - Directory for data files
- `/workspaces/[project-name]/node_modules` - Node.js dependencies (for JavaScript/TypeScript projects)

## Environment Variables

The following environment variables are set automatically:

- `PROJECT_ROOT` - The root directory of your project
- `VIRTUAL_ENV` - The path to the Python virtual environment (set only for Python projects)
- `UV_CACHE_DIR` - The path to the UV cache directory (set only for Python projects)
- `BUN_INSTALL` - The path to the Bun installation
- `NODE_ENV` - Set to "development" for Node.js projects

## Vite Development

For Vite projects, the following aliases are available:

- `vite-dev` - Start the development server
- `vite-build` - Build the project for production
- `vite-preview` - Preview the production build

## Customization

You can customize the container by:

1. Modifying the `Dockerfile` to add additional dependencies
2. Editing the `devcontainer.json` to add or remove VS Code extensions
3. Updating the `entrypoint.sh` script to add additional setup steps

## Troubleshooting

If you encounter any issues with the container:

1. Check that the `setup.sh` and `entrypoint.sh` scripts are executable
2. Verify that the `Dockerfile` is properly configured for your system
3. Check the VS Code logs for any errors during container creation

## License

This development container configuration is provided under the MIT License.