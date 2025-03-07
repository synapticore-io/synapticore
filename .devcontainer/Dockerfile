FROM python:3.13-slim

# Avoid warnings
ENV DEBIAN_FRONTEND=noninteractive

# Set up locale first (rarely changes)
RUN apt-get update && apt-get install -y locales \
    && sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=de_DE.UTF-8 \
    LANGUAGE=de_DE:de \
    LC_ALL=de_DE.UTF-8

# Install base system packages (rarely changes)
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    ca-certificates \
    python3-venv \
    apt-transport-https \
    gnupg \
    lsb-release \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI (rarely changes)
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && curl -L "https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Install Git LFS (rarely changes)
RUN apt-get update && apt-get install -y git-lfs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && git lfs install --system

# Install Node.js and Bun (may change periodically)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest yarn pnpm vite@latest create-vite@latest typescript \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL https://bun.sh/install | bash \
    && mv ~/.bun/bin/bun /usr/local/bin/bun

# Set up environment common for all users (rarely changes)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH}"

# Create user (rarely changes)
RUN groupadd -g 1000 vscode \
    && useradd -u 1000 -g vscode -m -s /bin/zsh vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && groupadd -g 999 docker || true \
    && usermod -aG docker vscode \
    && for gid in 998 997 996 995; do \
       groupadd -g $gid docker$gid || true; \
       usermod -aG docker$gid vscode || true; \
    done

# Copy scripts (more likely to change, so keep later in build)
COPY ./entrypoint.sh /usr/local/bin/
COPY ./setup.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/entrypoint.sh \
    && chmod 755 /usr/local/bin/setup.sh \
    && chown vscode:vscode /usr/local/bin/entrypoint.sh \
    && chown vscode:vscode /usr/local/bin/setup.sh

# Create copies of scripts in standard location and make them executable
RUN mkdir -p /opt/devcontainer/scripts/ \
    && cp /usr/local/bin/entrypoint.sh /opt/devcontainer/scripts/ \
    && cp /usr/local/bin/setup.sh /opt/devcontainer/scripts/ \
    && chmod 755 /opt/devcontainer/scripts/*.sh \
    && chown -R vscode:vscode /opt/devcontainer/scripts/

# Switch to user for remaining operations
USER vscode
WORKDIR /home/vscode

# Configure npm for user (rarely changes)
RUN mkdir -p ~/.npm-global \
    && npm config set prefix '~/.npm-global' \
    && echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc

# Set up Oh-My-ZSH (rarely changes)
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="bira"/' ~/.zshrc \
    && echo 'export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"' >> ~/.zshrc \
    && echo 'export BUN_INSTALL="$HOME/.bun"' >> ~/.zshrc \
    && echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> ~/.zshrc

# Install UV for Python package management
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/astral-sh/uv/releases/download/0.5.24/uv-installer.sh | sh

# Add .local/bin to PATH
ENV PATH="/home/vscode/.local/bin:$PATH"

# Set working directory
WORKDIR /workspaces

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["zsh"]
