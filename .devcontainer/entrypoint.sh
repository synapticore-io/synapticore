#!/bin/bash
set -e

# Get project name from workspace folder if not set
if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME="synapticore"
fi

echo "Initializing development environment for $PROJECT_NAME..."

# Set project-specific paths
export PROJECT_ROOT="/workspaces/${PROJECT_NAME}"
export VIRTUAL_ENV="${PROJECT_ROOT}/.venv"
export UV_CACHE_DIR="${PROJECT_ROOT}/.cache/uv"
export NODE_MODULES="${PROJECT_ROOT}/node_modules"

# Ensure path is correct
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Ensure directories exist with proper permissions
mkdir -p "${PROJECT_ROOT}/.cache"
mkdir -p "${PROJECT_ROOT}/logs"
mkdir -p "${PROJECT_ROOT}/data"

# Detect project type
HAS_PYTHON=false
HAS_NODE=false
HAS_VITE=false

if [ -f "${PROJECT_ROOT}/pyproject.toml" ] || [ -f "${PROJECT_ROOT}/requirements.txt" ] || [ -f "${PROJECT_ROOT}/setup.py" ]; then
    HAS_PYTHON=true
    echo "📦 Python project detected"
fi

if [ -f "${PROJECT_ROOT}/package.json" ]; then
    HAS_NODE=true
    echo "📦 Node.js project detected"
    
    # Check if it's a Vite project
    if grep -q "\"vite\"" "${PROJECT_ROOT}/package.json"; then
        HAS_VITE=true
        echo "📦 Vite project detected"
    fi
fi

# Set up SSH directory and permissions
if [ -d ~/.ssh ]; then
    echo "Setting up SSH directory permissions..."
    
    # Use alternative known_hosts file that is writable
    if [ -f "$HOME/known_hosts.container" ]; then
        export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=$HOME/known_hosts.container -o StrictHostKeyChecking=no"
    fi
    
    # Start SSH agent inside the container
    echo "Starting SSH agent..."
    eval "$(ssh-agent -s)"
    echo "SSH agent started with PID $SSH_AGENT_PID"

    # Try to add keys
    echo "Adding SSH keys to agent..."
    for key in ~/.ssh/id_ed25519 ~/.ssh/id_rsa ~/.ssh/id_ecdsa ~/.ssh/id_dsa; do
        if [ -f "$key" ]; then
            ssh-add "$key" 2>/dev/null && echo "Added SSH key: $key"
        fi
    done

    # Test GitHub connection
    echo "Testing connection to GitHub..."
    GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=$HOME/known_hosts.container -o StrictHostKeyChecking=no" ssh -T git@github.com || true
else
    echo "No SSH directory found. SSH functionality may be limited."
fi

# Fix Docker socket permissions
if [ -e "/var/run/docker.sock" ]; then
    echo "Setting up Docker socket permissions..."
    
    # Set permissions for the Docker socket
    echo "Setting Docker socket permissions..."
    sudo chmod 666 /var/run/docker.sock 2>/dev/null || true
    
    # Create docker group if needed
    DOCKER_GID=$(stat -c '%g' /var/run/docker.sock 2>/dev/null || echo "")
    
    if [ -n "$DOCKER_GID" ]; then
        # Check if a group with this GID already exists
        if getent group $DOCKER_GID >/dev/null 2>&1; then
            # Get the name of the group with this GID
            DOCKER_GROUP=$(getent group $DOCKER_GID | cut -d: -f1)
            echo "Group with GID $DOCKER_GID already exists: $DOCKER_GROUP"
        else
            # Create a new group with the correct GID
            echo "Creating docker-host group with GID $DOCKER_GID..."
            sudo groupadd -g $DOCKER_GID docker-host 2>/dev/null || true
            DOCKER_GROUP="docker-host"
        fi
        
        # Add user to the group
        echo "Adding user $(whoami) to group $DOCKER_GROUP..."
        sudo usermod -aG $DOCKER_GROUP $(whoami) 2>/dev/null || true
    fi
    
    # Verify permissions
    SOCK_PERM=$(stat -c "%a" /var/run/docker.sock 2>/dev/null || echo "unknown")
    echo "Docker socket permissions: $SOCK_PERM"
    
    # Verify we can use Docker
    echo "Testing Docker connection..."
    docker info >/dev/null 2>&1 && echo "✅ Docker connection successful!" || echo "❌ Docker connection failed. Try restarting the container."
else
    echo "⚠️ Docker socket not found at /var/run/docker.sock"
fi

# Setup Python environment if needed
if [ "$HAS_PYTHON" = true ]; then
    echo "Setting up Python environment..."
    
    # Check UV version
    if ! command -v uv &> /dev/null; then
        echo "Installing UV..."
        curl --proto '=https' --tlsv1.2 -LsSf https://github.com/astral-sh/uv/releases/download/0.5.24/uv-installer.sh | sh
        if [ $? -ne 0 ]; then
            echo "Error installing UV. Please install manually."
        fi
    fi

    echo "UV Version: $(uv --version)"

    # Create and activate Python venv if it doesn't exist
    if [ ! -d "$VIRTUAL_ENV" ] || [ ! -f "$VIRTUAL_ENV/bin/python" ]; then
        echo "Creating new virtual environment at $VIRTUAL_ENV..."
        mkdir -p "$VIRTUAL_ENV"
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
    $VIRTUAL_ENV/bin/pip install -U pip black pylint
    if [ $? -ne 0 ]; then
        echo "Warning: Could not install base packages."
    fi

    # Install project with pyproject.toml if available
    if [ -f "${PROJECT_ROOT}/pyproject.toml" ]; then
        echo "Installing project with pyproject.toml..."
        cd "${PROJECT_ROOT}"

        # Try to install the project
        $VIRTUAL_ENV/bin/pip install -e .
        if [ $? -ne 0 ]; then
            echo "Warning: Could not install the project. Try again manually with 'pip install -e .' later."
        else
            echo "Project successfully installed."
        fi
    elif [ -f "${PROJECT_ROOT}/requirements.txt" ]; then
        echo "Installing dependencies from requirements.txt..."
        cd "${PROJECT_ROOT}"
        
        # Try to install dependencies
        $VIRTUAL_ENV/bin/pip install -r requirements.txt
        if [ $? -ne 0 ]; then
            echo "Warning: Could not install dependencies. Try again manually with 'pip install -r requirements.txt' later."
        else
            echo "Dependencies successfully installed."
        fi
    fi
fi

# Setup Node.js environment if needed
if [ "$HAS_NODE" = true ]; then
    echo "Setting up Node.js environment..."
    
    # Check if bun is properly installed
    if ! command -v bun &> /dev/null; then
        echo "Bun not found, installing..."
        curl -fsSL https://bun.sh/install | bash
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
    else
        echo "Bun is installed: $(bun --version)"
    fi
    
    # Install Node.js dependencies
    if [ -f "${PROJECT_ROOT}/package.json" ]; then
        echo "Installing Node.js dependencies..."
        cd "${PROJECT_ROOT}"
        
        if [ -f "${PROJECT_ROOT}/bun.lockb" ]; then
            echo "Using Bun to install dependencies..."
            bun install
        elif [ -f "${PROJECT_ROOT}/yarn.lock" ]; then
            echo "Using Yarn to install dependencies..."
            yarn install
        elif [ -f "${PROJECT_ROOT}/pnpm-lock.yaml" ]; then
            echo "Using PNPM to install dependencies..."
            if ! command -v pnpm &> /dev/null; then
                echo "Installing PNPM..."
                npm install -g pnpm
            fi
            pnpm install
        else
            echo "Using NPM to install dependencies..."
            npm install
        fi
        
        if [ $? -ne 0 ]; then
            echo "Warning: Could not install Node.js dependencies."
        else
            echo "Node.js dependencies successfully installed."
        fi
    fi
    
    # Setup Vite-specific configuration if needed
    if [ "$HAS_VITE" = true ]; then
        echo "Setting up Vite development environment..."
        
        # Add Vite-specific configuration to .zshrc
        if [ -f "$HOME/.zshrc" ]; then
            if ! grep -q "# Vite configuration" "$HOME/.zshrc"; then
                cat >> "$HOME/.zshrc" << EOF

# Vite configuration
export VITE_PROJECT_ROOT="${PROJECT_ROOT}"
alias vite-dev="cd ${PROJECT_ROOT} && npm run dev"
alias vite-build="cd ${PROJECT_ROOT} && npm run build"
alias vite-preview="cd ${PROJECT_ROOT} && npm run preview"

EOF
            fi
        fi
    fi
fi

# Check if git-lfs is properly installed
if ! command -v git-lfs &> /dev/null; then
    echo "Git LFS not found, installing..."
    sudo apt-get update && sudo apt-get install -y git-lfs && git lfs install
else
    echo "Git LFS is installed: $(git-lfs --version)"
    git lfs install
fi

# Set up permissions properly
echo "Setting up permissions..."
for dir in "${PROJECT_ROOT}/.venv" "${PROJECT_ROOT}/.cache" "${PROJECT_ROOT}/data" "${PROJECT_ROOT}/logs" "${PROJECT_ROOT}/node_modules"; do
    if [ -d "$dir" ]; then
        sudo chown -R $(whoami):$(id -gn) "$dir" 2>/dev/null || true
        chmod -R 775 "$dir" 2>/dev/null || true
    fi
done

# Ensure path is correct in ZSH
if [ -f "$HOME/.zshrc" ]; then
    # Define a function to safely add lines to zshrc if they don't exist
    add_to_zshrc() {
        if ! grep -q "$1" "$HOME/.zshrc"; then
            echo "$1" >> "$HOME/.zshrc"
        fi
    }

    add_to_zshrc 'export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"'
    add_to_zshrc "export PROJECT_ROOT=\"${PROJECT_ROOT}\""
    
    if [ "$HAS_PYTHON" = true ]; then
        add_to_zshrc "export VIRTUAL_ENV=\"${VIRTUAL_ENV}\""
        add_to_zshrc 'export PATH="$VIRTUAL_ENV/bin:$PATH"'
    fi
    
    add_to_zshrc 'export BUN_INSTALL="$HOME/.bun"'
    add_to_zshrc 'export PATH="$BUN_INSTALL/bin:$PATH"'

    # Add Git SSH configuration for writable known_hosts
    if [ -f "$HOME/known_hosts.container" ]; then
        add_to_zshrc 'export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=~/.ssh/known_hosts -o UserKnownHostsFile2=~/known_hosts.container -o StrictHostKeyChecking=no"'
    fi

    # Add Docker permissions configuration to .zshrc for better persistence
    if ! grep -q "# Docker socket permissions" "$HOME/.zshrc"; then
        cat >> "$HOME/.zshrc" << EOF

# Docker socket permissions
if [ -e "/var/run/docker.sock" ]; then
    DOCK_PERM=\$(stat -c "%a" /var/run/docker.sock 2>/dev/null || echo "")
    if [ "\$DOCK_PERM" != "666" ] && [ "\$DOCK_PERM" != "777" ]; then
        echo "Fixing Docker socket permissions..."
        sudo chmod 666 /var/run/docker.sock 2>/dev/null || true
    fi
fi

EOF
    fi

    # Add useful aliases
    if ! grep -q "# Useful aliases" "$HOME/.zshrc"; then
        cat >> "$HOME/.zshrc" << EOF

# Useful aliases
alias ll='ls -la'
EOF

        if [ "$HAS_PYTHON" = true ]; then
            cat >> "$HOME/.zshrc" << EOF
alias py='python'
alias uvpip='uv pip'
alias python='$VIRTUAL_ENV/bin/python'
alias pip='$VIRTUAL_ENV/bin/pip'
EOF
        fi

        if [ "$HAS_NODE" = true ]; then
            cat >> "$HOME/.zshrc" << EOF
alias ni='npm install'
alias nr='npm run'
alias bi='bun install'
alias br='bun run'
EOF
        fi
    fi
fi

echo "Development environment is ready."
echo "Project Root: $PROJECT_ROOT"

if [ "$HAS_PYTHON" = true ]; then
    echo "UV Cache: $UV_CACHE_DIR"
    echo "Virtual ENV: $VIRTUAL_ENV"
fi

echo "Git LFS: $(git-lfs --version 2>/dev/null || echo 'Not installed')"
echo "Bun: $(bun --version 2>/dev/null || echo 'Not installed')"

if [ "$HAS_VITE" = true ]; then
    echo "Vite project detected. Use 'vite-dev' to start the development server."
fi

# Execute the command passed to the script
exec "$@"
