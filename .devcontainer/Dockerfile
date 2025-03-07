FROM python:3.10-slim

# Vermeiden von Warnungen bei apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Grundlegende Entwicklungstools und Dienstprogramme installieren
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

# Docker CLI installieren
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Docker Compose installieren
RUN curl -L "https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Locale einrichten
RUN sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG=de_DE.UTF-8 \
    LANGUAGE=de_DE:de \
    LC_ALL=de_DE.UTF-8

# Arbeitsverzeichnis und UV-Cache
WORKDIR /workspaces/omniverse
ENV UV_CACHE_DIR=/workspaces/.cache/uv \
    UV_PROJECT_ENVIRONMENT=/workspaces/.venv \
    UV_SYSTEM_PYTHON=0 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/workspaces/.venv \
    PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/workspaces/.venv/bin:${PATH}"

# Benutzerkonfiguration für Synapticore
RUN groupadd -g 2000 synapticore && \
    useradd -u 2000 -g synapticore -m -s /bin/zsh synapticore-dev && \
    echo "synapticore-dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /workspaces/omniverse && \
    mkdir -p ${UV_CACHE_DIR} && \
    chown -R synapticore-dev:synapticore /workspaces/omniverse

# Erstelle eine Docker-Gruppe für den Fall, dass der Host eine andere GID verwendet
RUN groupadd -g 999 docker || true && \
    usermod -aG docker synapticore-dev

# Kopiere entrypoint.sh
COPY ./entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/entrypoint.sh && \
    chown synapticore-dev:synapticore /usr/local/bin/entrypoint.sh

# Wechsle zum Benutzer
USER synapticore-dev
WORKDIR /home/synapticore-dev

# Oh-My-ZSH installieren und konfigurieren
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="bira"/' ~/.zshrc && \
    echo 'export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"' >> ~/.zshrc

# Zurück zum Arbeitsverzeichnis
WORKDIR /workspaces/omniverse

# UV für den Benutzer installieren
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/astral-sh/uv/releases/download/0.5.24/uv-installer.sh | sh

# Füge .local/bin zum PATH hinzu
ENV PATH="/home/synapticore-dev/.local/bin:$PATH"

# Erstelle eine virtuelle Umgebung mit dem --without-pip Flag, um Probleme zu vermeiden
RUN python -m venv ${VIRTUAL_ENV} --without-pip && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | ${VIRTUAL_ENV}/bin/python && \
    ${VIRTUAL_ENV}/bin/pip install --upgrade pip

# Virtuelle Umgebung in ZSH aktivieren
RUN echo "export PATH=\"${VIRTUAL_ENV}/bin:\$PATH\"" >> ~/.zshrc && \
    echo "alias pip='${VIRTUAL_ENV}/bin/pip'" >> ~/.zshrc && \
    echo "alias python='${VIRTUAL_ENV}/bin/python'" >> ~/.zshrc && \
    echo "plugins=(git)" >> ~/.zshrc

# Setze den Entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["zsh"]