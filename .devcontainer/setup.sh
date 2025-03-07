#!/bin/bash
set -e

# Get project name from workspace folder
PROJECT_NAME=$(basename "$PWD")
echo "Setting up development environment for $PROJECT_NAME..."

# Create necessary directories
mkdir -p "/workspaces/${PROJECT_NAME}/.cache" "/workspaces/${PROJECT_NAME}/logs" "/workspaces/${PROJECT_NAME}/data"
sudo chown -R $(whoami):$(id -gn) "/workspaces/${PROJECT_NAME}/.cache" "/workspaces/${PROJECT_NAME}/logs" "/workspaces/${PROJECT_NAME}/data"

# Fix SSH directory permissions if it exists
if [ -d "$HOME/.ssh" ]; then
    echo "Setting up SSH directory permissions..."
    
    # Ensure SSH client is installed
    if ! command -v ssh &> /dev/null; then
        echo "Installing SSH client..."
        sudo apt-get update && sudo apt-get install -y openssh-client
    fi
    
    sudo chown -R $(whoami):$(id -gn) "$HOME/.ssh"
    sudo chmod 700 "$HOME/.ssh"
    sudo find "$HOME/.ssh" -type f -exec chmod 600 {} \;
    sudo find "$HOME/.ssh" -name "*.pub" -exec chmod 644 {} \;
    
    # Add GitHub to known hosts if not already present
    if ! grep -q "github.com" "$HOME/.ssh/known_hosts" 2>/dev/null; then
        ssh-keyscan -t rsa github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
    fi
    
    # Start SSH agent
    eval "$(ssh-agent -s)" > /dev/null 2>&1
    
    # Configure Git to use SSH with proper options
    git config --global core.sshCommand "ssh -o StrictHostKeyChecking=accept-new"
fi

# Fix Docker socket permissions
[ -e "/var/run/docker.sock" ] && sudo chmod 666 /var/run/docker.sock 2>/dev/null || true

# Ensure git is configured
if ! git config --global --get user.email >/dev/null 2>&1; then
    git config --global user.email "user@example.com"
    git config --global user.name "Dev Container User"
    echo "⚠️ Git user is not set. Using default values. Please update with your info."
fi

echo "Setup completed successfully!"
