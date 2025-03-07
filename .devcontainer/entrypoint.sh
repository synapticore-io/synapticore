#!/bin/bash
set -e

echo "Initialisiere Python-Entwicklungsumgebung..."

# Stelle sicher, dass der PATH korrekt ist
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Verzeichnisse erstellen, falls sie nicht existieren
mkdir -p /workspaces/.venv
mkdir -p /workspaces/.cache/uv
mkdir -p /workspaces/logs
mkdir -p /workspaces/data

# Überprüfe, ob die Docker-Gruppe existiert und füge den Benutzer hinzu
DOCKER_GID=$(stat -c '%g' /var/run/docker.sock 2>/dev/null || echo "")
if [ -n "$DOCKER_GID" ]; then
    if ! getent group $DOCKER_GID > /dev/null 2>&1; then
        sudo groupadd -g $DOCKER_GID docker_host
    fi
    sudo usermod -aG $DOCKER_GID $(whoami)
    echo "Benutzer $(whoami) zur Docker-Gruppe hinzugefügt (GID: $DOCKER_GID)"
fi

# UV-Version prüfen
if ! command -v uv &> /dev/null; then
    echo "Installiere UV..."
    curl --proto '=https' --tlsv1.2 -LsSf https://github.com/astral-sh/uv/releases/download/0.5.24/uv-installer.sh | sh
    if [ $? -ne 0 ]; then
        echo "Fehler bei der Installation von UV. Bitte manuell installieren."
    fi
fi

echo "UV Version: $(uv --version)"

# Python venv erstellen und aktivieren
if [ ! -d "$VIRTUAL_ENV" ]; then
    echo "Erstelle virtuelle Umgebung..."
    python -m venv $VIRTUAL_ENV --without-pip
    if [ $? -ne 0 ]; then
        echo "Fehler beim Erstellen der virtuellen Umgebung."
        exit 1
    fi

    # Pip manuell installieren
    curl -sS https://bootstrap.pypa.io/get-pip.py | $VIRTUAL_ENV/bin/python

    # Upgrade pip in der virtuellen Umgebung
    $VIRTUAL_ENV/bin/pip install --upgrade pip
    if [ $? -ne 0 ]; then
        echo "Warnung: Konnte pip nicht aktualisieren."
    fi
fi

# Prüfe, ob Python in der virtuellen Umgebung existiert
if [ ! -f "$VIRTUAL_ENV/bin/python" ]; then
    echo "Fehler: Python-Interpreter nicht in der virtuellen Umgebung gefunden."
    echo "Versuche, die virtuelle Umgebung neu zu erstellen..."
    rm -rf $VIRTUAL_ENV
    python -m venv $VIRTUAL_ENV --without-pip
    if [ $? -ne 0 ]; then
        echo "Fehler beim Neuerstellen der virtuellen Umgebung."
        exit 1
    fi
    curl -sS https://bootstrap.pypa.io/get-pip.py | $VIRTUAL_ENV/bin/python
    $VIRTUAL_ENV/bin/pip install --upgrade pip
fi

# Aktiviere die virtuelle Umgebung
export PATH="$VIRTUAL_ENV/bin:$PATH"
echo "Virtuelle Umgebung aktiviert: $VIRTUAL_ENV"

# Basis-Pakete installieren
echo "Installiere Basis-Pakete..."
$VIRTUAL_ENV/bin/pip install black pylint
if [ $? -ne 0 ]; then
    echo "Warnung: Konnte Basis-Pakete nicht installieren."
fi

# Projekt mit pyproject.toml installieren falls vorhanden
if [ -f "/workspaces/pyproject.toml" ]; then
    echo "Installiere Projekt mit pyproject.toml..."
    cd /workspaces/omniverse

    # Versuche das Projekt zu installieren
    $VIRTUAL_ENV/bin/pip install -e .
    if [ $? -ne 0 ]; then
        echo "Warnung: Konnte das Projekt nicht installieren. Versuche es später manuell mit 'pip install -e .'."
    else
        echo "Projekt erfolgreich installiert."
    fi
fi

# Berechtigungen für Synapticore-Benutzer einrichten
if id "synapticore-dev" &>/dev/null; then
    echo "Richte Berechtigungen ein..."
    mkdir -p /workspaces/{data,logs}

    # Nur wenn wir root-Rechte haben
    if [ $(id -u) -eq 0 ]; then
        chown -R synapticore-dev:synapticore /workspaces/{data,logs}
        chmod -R 775 /workspaces/{data,logs}
    fi
fi

# Stelle sicher, dass der PATH in ZSH korrekt ist
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "export PATH=\"/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:\$PATH\"" $HOME/.zshrc; then
        echo "export PATH=\"/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:\$PATH\"" >> $HOME/.zshrc
    fi

    if ! grep -q "export PATH=\"$VIRTUAL_ENV/bin:\$PATH\"" $HOME/.zshrc; then
        echo "export PATH=\"$VIRTUAL_ENV/bin:\$PATH\"" >> $HOME/.zshrc
    fi

    # Füge nützliche Aliase hinzu
    if ! grep -q "# Nützliche Aliase" $HOME/.zshrc; then
        cat >> $HOME/.zshrc << EOF

# Nützliche Aliase
alias ll='ls -la'
alias py='python'
alias uvpip='uv pip'
alias pip='$VIRTUAL_ENV/bin/pip'
alias python='$VIRTUAL_ENV/bin/python'

EOF
    fi
fi

echo "Python-Entwicklungsumgebung ist bereit."
echo "UV Cache: $UV_CACHE_DIR"
echo "Virtual ENV: $VIRTUAL_ENV"

exec "$@"