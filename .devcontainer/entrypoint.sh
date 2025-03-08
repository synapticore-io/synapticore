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
mkdir -p "${PROJECT_ROOT}/.cache" "${PROJECT_ROOT}/logs" "${PROJECT_ROOT}/data"

# Quick project type detection
HAS_PYTHON=false
HAS_NODE=false
HAS_VITE=false

[ -f "${PROJECT_ROOT}/pyproject.toml" ] || [ -f "${PROJECT_ROOT}/requirements.txt" ] || [ -f "${PROJECT_ROOT}/setup.py" ] && HAS_PYTHON=true
[ -f "${PROJECT_ROOT}/package.json" ] && HAS_NODE=true && grep -q "\"vite\"" "${PROJECT_ROOT}/package.json" 2>/dev/null && HAS_VITE=true

# Set up Docker socket permissions if needed
if [ -e "/var/run/docker.sock" ]; then
    sudo chmod 666 /var/run/docker.sock 2>/dev/null || true
    docker info >/dev/null 2>&1 && echo "✅ Docker connection successful!" || echo "❌ Docker connection failed"
fi

# Setup Python environment if needed
if [ "$HAS_PYTHON" = true ]; then
    echo "📦 Python project detected"
    
    # Create Python venv only if it doesn't exist
    if [ ! -d "$VIRTUAL_ENV" ] || [ ! -f "$VIRTUAL_ENV/bin/python" ]; then
        mkdir -p "$VIRTUAL_ENV"
        python -m venv $VIRTUAL_ENV
        $VIRTUAL_ENV/bin/pip install --upgrade pip black pylint
    fi

    export PATH="$VIRTUAL_ENV/bin:$PATH"
    
    # Install project dependencies
    if [ -f "${PROJECT_ROOT}/pyproject.toml" ]; then
        cd "${PROJECT_ROOT}" && $VIRTUAL_ENV/bin/pip install -e . || echo "⚠️ Could not install project"
    elif [ -f "${PROJECT_ROOT}/requirements.txt" ]; then
        cd "${PROJECT_ROOT}" && $VIRTUAL_ENV/bin/pip install -r requirements.txt || echo "⚠️ Could not install dependencies"
    fi
fi

# Setup Node.js environment if needed
if [ "$HAS_NODE" = true ]; then
    echo "📦 Node.js project detected"
    
    cd "${PROJECT_ROOT}"
    
    if [ -f "${PROJECT_ROOT}/bun.lockb" ]; then
        bun install || echo "⚠️ Bun install failed"
    elif [ -f "${PROJECT_ROOT}/yarn.lock" ]; then
        yarn install || echo "⚠️ Yarn install failed"
    elif [ -f "${PROJECT_ROOT}/pnpm-lock.yaml" ]; then
        pnpm install || echo "⚠️ PNPM install failed"
    elif [ -f "${PROJECT_ROOT}/package.json" ]; then
        npm install || echo "⚠️ NPM install failed"
    fi
    
    # Add Vite aliases if needed
    if [ "$HAS_VITE" = true ] && [ -f "$HOME/.zshrc" ]; then
        echo "📦 Vite project detected"
        echo "alias vite-dev=\"cd ${PROJECT_ROOT} && npm run dev\"" >> "$HOME/.zshrc"
        echo "alias vite-build=\"cd ${PROJECT_ROOT} && npm run build\"" >> "$HOME/.zshrc"
    fi
fi

# Set up SSH if available
if [ -d "$HOME/.ssh" ]; then
    eval "$(ssh-agent -s)" > /dev/null
    find ~/.ssh -type f -name "id_*" ! -name "*.pub" | xargs -I{} ssh-add {} 2>/dev/null || true
fi

# Set up permissions
for dir in "${PROJECT_ROOT}/.venv" "${PROJECT_ROOT}/.cache" "${PROJECT_ROOT}/data" "${PROJECT_ROOT}/logs" "${PROJECT_ROOT}/node_modules"; do
    [ -d "$dir" ] && sudo chown -R $(whoami):$(id -gn) "$dir" 2>/dev/null || true
done

echo "Development environment is ready."
exec "$@"
