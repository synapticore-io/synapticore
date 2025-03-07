FROM python:3.11-slim

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

# Set up working directory and UV cache
WORKDIR /workspaces/synapticore
ENV UV_CACHE_DIR=/workspaces/.cache/uv \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH}"

# Create directories with proper permissions
RUN mkdir -p /workspaces/.cache/uv \
    /workspaces/.venv \
    /workspaces/logs \
    /workspaces/data

# User configuration for Synapticore
RUN groupadd -g 2000 synapticore && \
    useradd -u 2000 -g synapticore -m -s /bin/zsh synapticore-dev && \
    echo "synapticore-dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chown -R synapticore-dev:synapticore /workspaces

# Create a Docker group for use when the host has a different GID
RUN groupadd -g 999 docker || true && \
    usermod -aG docker synapticore-dev

# Copy entrypoint script
COPY ./entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/entrypoint.sh && \
    chown synapticore-dev:synapticore /usr/local/bin/entrypoint.sh

# Switch to user
USER synapticore-dev
WORKDIR /home/synapticore-dev

# Install Oh-My-ZSH and configure
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="bira"/' ~/.zshrc && \
    echo 'export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"' >> ~/.zshrc && \
    echo 'export BUN_INSTALL="$HOME/.bun"' >> ~/.zshrc && \
    echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> ~/.zshrc

# Return to workspace
WORKDIR /workspaces/synapticore

# Install UV for the user
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/astral-sh/uv/releases/download/0.5.24/uv-installer.sh | sh

# Add .local/bin to PATH
ENV PATH="/home/synapticore-dev/.local/bin:$PATH"

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["zsh"]
