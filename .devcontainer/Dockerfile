FROM python:3.13-slim

# Avoid apt-get warnings
ENV DEBIAN_FRONTEND=noninteractive

# Install basic development tools and utilities
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    procps \
    vim \
    less \
    unzip \
    which \
    coreutils \
    sudo \
    bash \
    zsh \
    locales \
    findutils \
    python3-venv \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Install Git LFS
RUN apt-get update && apt-get install -y git-lfs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    git lfs install --system

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    npm install -g npm@latest

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash && \
    mv ~/.bun/bin/bun /usr/local/bin/bun

# Set up locale
RUN sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG=de_DE.UTF-8 \
    LANGUAGE=de_DE:de \
    LC_ALL=de_DE.UTF-8

# Set up working directory
WORKDIR /workspaces
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH}"

# Create standard user
RUN groupadd -g 1000 vscode && \
    useradd -u 1000 -g vscode -m -s /bin/zsh vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chown -R vscode:vscode /workspaces

# Create a Docker group for use when the host has a different GID
RUN groupadd -g 999 docker || true && \
    usermod -aG docker vscode && \
    # Create additional groups for Docker socket access
    for gid in 998 997 996 995 994 993 992 991 990; do \
    groupadd -g $gid docker$gid || true; \
    usermod -aG docker$gid vscode || true; \
    done

# Copy entrypoint and setup scripts
COPY ./entrypoint.sh /usr/local/bin/
COPY ./setup.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/entrypoint.sh && \
    chmod 755 /usr/local/bin/setup.sh && \
    chown vscode:vscode /usr/local/bin/entrypoint.sh && \
    chown vscode:vscode /usr/local/bin/setup.sh

# Install global Node.js packages
RUN npm install -g yarn pnpm vite@latest create-vite@latest typescript

# Switch to user
USER vscode
WORKDIR /home/vscode

# Configure npm for user-level global installs
RUN mkdir -p ~/.npm-global && \
    npm config set prefix '~/.npm-global' && \
    echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc

# Install Oh-My-ZSH and configure
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="bira"/' ~/.zshrc && \
    echo 'export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"' >> ~/.zshrc && \
    echo 'export BUN_INSTALL="$HOME/.bun"' >> ~/.zshrc && \
    echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> ~/.zshrc

# Return to workspace
WORKDIR /workspaces

# Install UV for the user
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/astral-sh/uv/releases/download/0.5.24/uv-installer.sh | sh

# Add .local/bin to PATH
ENV PATH="/home/vscode/.local/bin:$PATH"

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["zsh"]
