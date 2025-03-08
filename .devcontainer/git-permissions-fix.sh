#!/bin/bash

# Diese Datei als git-fix.sh im Projektordner speichern und ausführbar machen

# 1. Stellen Sie sicher, dass das Skript als Root läuft
if [ "$(id -u)" != "0" ]; then
   echo "Dieses Skript muss als root ausgeführt werden" 
   exec sudo "$0" "$@"
   exit
fi

# 2. Setzen Sie Besitz und Berechtigungen für das Projektverzeichnis
PROJECT_DIR="/workspaces/synapticore"
USER=$(stat -c '%U' $PROJECT_DIR)
GROUP=$(stat -c '%G' $PROJECT_DIR)

echo "Setze Berechtigungen für $PROJECT_DIR"
echo "Benutzer: $USER, Gruppe: $GROUP"

# Ändern Sie den Besitzer des gesamten Projektverzeichnisses
chown -R $USER:$GROUP $PROJECT_DIR
chmod -R u+rw $PROJECT_DIR

# 3. Git-Konfiguration für Windows/Container-Umgebungen
su - $USER -c "git config --global core.fileMode false"
su - $USER -c "git config --global core.longpaths true"
su - $USER -c "git config --global core.autocrlf input"
su - $USER -c "git config --global core.symlinks true"
su - $USER -c "git config --global safe.directory '*'"

# 4. Für bestehende Git-Repositories Indizes neu erstellen
if [ -d "$PROJECT_DIR/.git" ]; then
    echo "Git-Repository gefunden, setze Berechtigungen..."
    chown -R $USER:$GROUP $PROJECT_DIR/.git
    chmod -R u+rw $PROJECT_DIR/.git
    
    # Versuche, den Git-Index zu reparieren
    su - $USER -c "cd $PROJECT_DIR && git update-index --really-refresh || true"
    su - $USER -c "cd $PROJECT_DIR && rm -f .git/index.lock || true"
    
    echo "Git-Repository-Berechtigungen aktualisiert"
fi

# 5. Git sicher machen, damit es in Containern besser funktioniert
git config --system --add safe.directory "/workspaces/synapticore"

echo "Berechtigungen wurden gesetzt, Git sollte jetzt funktionieren"
