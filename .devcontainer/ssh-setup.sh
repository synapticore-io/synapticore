#!/bin/bash
# ssh-setup.sh - Hilft bei der Konfiguration von SSH im DevContainer

# Prüfen, ob SSH-Client installiert ist
if ! command -v ssh &> /dev/null; then
    echo "SSH-Client ist nicht installiert. Installiere..."
    sudo apt-get update && sudo apt-get install -y openssh-client
    if [ $? -ne 0 ]; then
        echo "Fehler beim Installieren von SSH. Bitte manuell installieren mit:"
        echo "sudo apt-get update && sudo apt-get install -y openssh-client"
        exit 1
    fi
fi

# SSH-Verzeichnis einrichten
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Known_hosts für GitHub einrichten
if ! grep -q "github.com" ~/.ssh/known_hosts 2>/dev/null; then
    echo "Füge GitHub zu known_hosts hinzu..."
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts 2>/dev/null
fi

# SSH-Agent starten
eval "$(ssh-agent -s)"

# Private SSH-Schlüssel suchen und laden
echo "Suche nach SSH-Schlüsseln..."
for key in ~/.ssh/id_ed25519 ~/.ssh/id_rsa ~/.ssh/id_ecdsa; do
    if [ -f "$key" ]; then
        echo "Gefunden: $key"
        ssh-add "$key" 2>/dev/null && echo "Schlüssel hinzugefügt: $key"
    fi
done

# Git-Konfiguration für SSH anpassen
git config --global core.sshCommand "ssh -o StrictHostKeyChecking=accept-new"

# Teste Verbindung zu GitHub
echo "Teste Verbindung zu GitHub..."
ssh -T git@github.com -o StrictHostKeyChecking=accept-new || true

echo "SSH-Setup abgeschlossen."
echo "Um einen neuen SSH-Schlüssel zu generieren, verwende: ssh-keygen -t ed25519 -C \"deine.email@example.com\""
