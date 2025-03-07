#!/bin/bash
set -e

echo "Initializing Python development environment..."

# Ensure path is correct
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Ensure directories exist with proper permissions
mkdir -p /workspaces/.venv
mkdir -p /workspaces/.cache/uv
mkdir -p /workspaces/logs
mkdir -p /workspaces/data

# Check if the Docker group exists and add the user
DOCKER_GID=$(stat -c '%g' /var/run/docker.sock 2>/dev/null || echo "")
if [ -n "$DOCKER_GID" ]; then
    if ! getent group $DOCKER_GID > /dev/null 2>&1; then
        sudo groupadd -g $DOCKER_GID docker_host
    fi
    sudo usermod -aG $DOCKER_GID $(whoami)
    echo "User $(whoami) added to Docker group (GID: $DOCKER_GID)"
fi

# Check UV version
if ! command -v uv &> /dev/null; then
    echo "Installing UV..."
    curl --proto '=https' --tlsv1.2 -LsSf https://github.com/astral-sh/uv/releases/download/0.5.24/uv-installer.sh | sh
    if [ $? -ne 0 ]; then
        echo "Error installing UV. Please install manually."
    fi
fi

echo "UV Version: $(uv --version)"

# Set VIRTUAL_ENV explicitly
export VIRTUAL_ENV="/workspaces/.venv"

# Create and activate Python venv if it doesn't exist
if [ ! -d "$VIRTUAL_ENV" ] || [ ! -f "$VIRTUAL_ENV/bin/python" ]; then
    echo "Creating new virtual environment..."
    rm -rf $VIRTUAL_ENV
    python -m venv $VIRTUAL_ENV
    
    if [ $? -ne 0 ]; then
        echo "Error creating virtual environment. Trying alternative method..."
        python -m venv $VIRTUAL_ENV --without-pip
        
        if [ $? -ne 0 ]; then
            echo "Error creating virtual environment using both methods."
            exit 1
        fi
        
        # Install pip manually
        curl -sS https://bootstrap.pypa.io/get-pip.py | $VIRTUAL_ENV/bin/python
    fi
    
    # Upgrade pip in the virtual environment
    $VIRTUAL_ENV/bin/pip install --upgrade pip
    if [ $? -ne 0 ]; then
        echo "Warning: Could not upgrade pip."
    fi
fi

# Activate the virtual environment
export PATH="$VIRTUAL_ENV/bin:$PATH"
echo "Virtual environment activated: $VIRTUAL_ENV"

# Install base packages
echo "Installing base packages..."
$VIRTUAL_ENV/bin/pip install -U pip black pylint mcp pydantic
if [ $? -ne 0 ]; then
    echo "Warning: Could not install base packages."
fi

# Check if git-lfs is properly installed
if ! command -v git-lfs &> /dev/null; then
    echo "Git LFS not found, installing..."
    sudo apt-get update && sudo apt-get install -y git-lfs && git lfs install
else
    echo "Git LFS is installed: $(git-lfs --version)"
    git lfs install
fi

# Check if bun is properly installed
if ! command -v bun &> /dev/null; then
    echo "Bun not found, installing..."
    curl -fsSL https://bun.sh/install | bash
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
else
    echo "Bun is installed: $(bun --version)"
fi

# Install project with pyproject.toml if available
if [ -f "/workspaces/omniverse/pyproject.toml" ]; then
    echo "Installing project with pyproject.toml..."
    cd /workspaces/omniverse

    # Try to install the project
    $VIRTUAL_ENV/bin/pip install -e .
    if [ $? -ne 0 ]; then
        echo "Warning: Could not install the project. Try again manually with 'pip install -e .' later."
    else
        echo "Project successfully installed."
    fi
fi

# Set up permissions for Synapticore user
if id "synapticore-dev" &>/dev/null; then
    echo "Setting up permissions..."
    for dir in /workspaces/.venv /workspaces/.cache /workspaces/data /workspaces/logs; do
        if [ -d "$dir" ]; then
            sudo chown -R $(whoami):$(id -gn) "$dir" 2>/dev/null || true
            chmod -R 775 "$dir" 2>/dev/null || true
        fi
    done
fi

# Ensure path is correct in ZSH
if [ -f "$HOME/.zshrc" ]; then
    # Define a function to safely add lines to zshrc if they don't exist
    add_to_zshrc() {
        if ! grep -q "$1" "$HOME/.zshrc"; then
            echo "$1" >> "$HOME/.zshrc"
        fi
    }

    add_to_zshrc 'export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"'
    add_to_zshrc "export VIRTUAL_ENV=\"$VIRTUAL_ENV\""
    add_to_zshrc 'export PATH="$VIRTUAL_ENV/bin:$PATH"'
    add_to_zshrc 'export BUN_INSTALL="$HOME/.bun"'
    add_to_zshrc 'export PATH="$BUN_INSTALL/bin:$PATH"'
    
    # Add useful aliases
    if ! grep -q "# Useful aliases" "$HOME/.zshrc"; then
        cat >> "$HOME/.zshrc" << EOF

# Useful aliases
alias ll='ls -la'
alias py='python'
alias uvpip='uv pip'
alias python='$VIRTUAL_ENV/bin/python'
alias pip='$VIRTUAL_ENV/bin/pip'

EOF
    fi
fi

echo "Python development environment is ready."
echo "UV Cache: $UV_CACHE_DIR"
echo "Virtual ENV: $VIRTUAL_ENV"
echo "Git LFS: $(git-lfs --version 2>/dev/null || echo 'Not installed')"
echo "Bun: $(bun --version 2>/dev/null || echo 'Not installed')"

exec "$@"
