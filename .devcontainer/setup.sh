#!/bin/bash
set -e

# Get project name from workspace folder
PROJECT_NAME=$(basename "$PWD")
echo "Setting up development environment for $PROJECT_NAME..."

# Create necessary directories with proper permissions
sudo mkdir -p "/workspaces/${PROJECT_NAME}/.cache"
sudo mkdir -p "/workspaces/${PROJECT_NAME}/logs"
sudo mkdir -p "/workspaces/${PROJECT_NAME}/data"

# Set proper ownership
sudo chown -R $(whoami):$(id -gn) "/workspaces/${PROJECT_NAME}/.cache"
sudo chown -R $(whoami):$(id -gn) "/workspaces/${PROJECT_NAME}/logs"
sudo chown -R $(whoami):$(id -gn) "/workspaces/${PROJECT_NAME}/data"

# Fix SSH directory permissions if it exists
if [ -d "$HOME/.ssh" ]; then
    echo "Setting up SSH directory permissions..."
    
    # Create a backup of the SSH directory
    BACKUP_DIR="/tmp/ssh-backup-$(date +%s)"
    mkdir -p "$BACKUP_DIR"
    cp -r "$HOME/.ssh/"* "$BACKUP_DIR/" 2>/dev/null || true
    
    # Fix ownership and permissions
    sudo chown -R $(whoami):$(id -gn) "$HOME/.ssh"
    sudo chmod 700 "$HOME/.ssh"
    
    # Create and set permissions for known_hosts if it doesn't exist
    if [ ! -f "$HOME/.ssh/known_hosts" ]; then
        touch "$HOME/.ssh/known_hosts"
    fi
    sudo chmod 644 "$HOME/.ssh/known_hosts"
    
    # Fix permissions for all files in .ssh
    sudo find "$HOME/.ssh" -type f -exec chmod 600 {} \;
    
    # Make public keys readable
    sudo find "$HOME/.ssh" -name "*.pub" -exec chmod 644 {} \;
    
    # Ensure known_hosts is always writable
    sudo chmod 644 "$HOME/.ssh/known_hosts" 2>/dev/null || true
    
    # Fix CRLF issues in SSH keys (Windows specific)
    echo "Checking SSH keys for CRLF issues..."
    for key_file in ~/.ssh/id_rsa ~/.ssh/id_ed25519 ~/.ssh/id_dsa ~/.ssh/id_ecdsa; do
        if [ -f "$key_file" ]; then
            # Check if file has CRLF line endings
            if file "$key_file" | grep -q "CRLF"; then
                echo "Converting CRLF to LF in $key_file"
                tr -d '\r' < "$key_file" > "$key_file.tmp" && mv "$key_file.tmp" "$key_file"
                chmod 600 "$key_file"
            fi
        fi
    done
    
    # Create a writable copy of known_hosts in home directory
    cp "$HOME/.ssh/known_hosts" "$HOME/known_hosts.container" 2>/dev/null || touch "$HOME/known_hosts.container"
    chmod 644 "$HOME/known_hosts.container"
    
    # Set Git SSH configuration to use the writable known_hosts file
    mkdir -p "$HOME/.ssh/config.d"
    cat > "$HOME/.ssh/config.d/github-known-hosts" << EOF
Host github.com
    UserKnownHostsFile ~/.ssh/known_hosts $HOME/known_hosts.container
    StrictHostKeyChecking no
EOF
    chmod 644 "$HOME/.ssh/config.d/github-known-hosts"
    
    # Create or update SSH config to include the above
    if [ ! -f "$HOME/.ssh/config" ]; then
        echo "Include ~/.ssh/config.d/*" > "$HOME/.ssh/config"
        chmod 644 "$HOME/.ssh/config"
    else
        if ! grep -q "Include ~/.ssh/config.d/\*" "$HOME/.ssh/config"; then
            echo "Include ~/.ssh/config.d/*" > "$HOME/.ssh/config.new"
            cat "$HOME/.ssh/config" >> "$HOME/.ssh/config.new"
            mv "$HOME/.ssh/config.new" "$HOME/.ssh/config"
            chmod 644 "$HOME/.ssh/config"
        fi
    fi
fi

# Fix Docker socket permissions if it exists
if [ -e "/var/run/docker.sock" ]; then
    echo "Setting Docker socket permissions..."
    sudo chmod 666 /var/run/docker.sock 2>/dev/null || true
fi

# Ensure Git is properly configured
echo "Checking Git configuration..."
if ! git config --global --get user.email >/dev/null 2>&1; then
    echo "⚠️ Git user.email is not set. Please set it with:"
    echo "    git config --global user.email \"your.email@example.com\""
fi

if ! git config --global --get user.name >/dev/null 2>&1; then
    echo "⚠️ Git user.name is not set. Please set it with:"
    echo "    git config --global user.name \"Your Name\""
fi

# Configure Git to use SSH
git config --global core.sshCommand "ssh -o UserKnownHostsFile=~/.ssh/known_hosts -o UserKnownHostsFile2=~/known_hosts.container -o StrictHostKeyChecking=no"

# Install additional tools if needed
if ! command -v file >/dev/null 2>&1; then
    echo "Installing 'file' utility for checking file types..."
    sudo apt-get update && sudo apt-get install -y file
fi

# Run the entrypoint script for further setup
./.devcontainer/entrypoint.sh

echo "Setup completed successfully!"
