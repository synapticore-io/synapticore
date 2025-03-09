#!/bin/bash
set -e

# Kein automatisches Reset, wenn eine .keep Datei existiert
if [ -f "/vault/data/.keep" ]; then
  echo "Reset wurde manuell deaktiviert (.keep Datei gefunden)."
  exit 0
fi

# Überprüfen, ob ein Reset-Lock existiert
if [ -f "/vault/data/.reset_lock" ]; then
  echo "Reset lock exists, skipping reset."
  exit 0
fi

# Überprüfen, ob wir beim ersten Start sind - für den ersten Start keine Reset-Bedingung prüfen
if [ ! -f "/vault/data/vault.db" ] && [ ! -f "/vault/data/unseal_key.txt" ]; then
  echo "First-time initialization, no reset needed."
  touch /vault/data/.reset_lock
  exit 0
fi

# Überprüfen, ob Vault-Daten existieren, aber der Unseal-Schlüssel fehlt - nur dann zurücksetzen
if [ -d "/vault/data" ] && [ -f "/vault/data/vault.db" ] && [ ! -f "/vault/data/unseal_key.txt" ]; then
  echo "Vault data exists but unseal key is missing. Performing complete reset..."
  
  # Sicherstellen, dass Vault nicht läuft
  pkill vault || true
  
  # Warten, bis Vault vollständig beendet ist
  sleep 2
  
  # Vollständiges Löschen aller Daten - WICHTIG: Spezifisch nur die DB-Dateien löschen!
  rm -f /vault/data/vault.db*
  rm -f /vault/data/raft/*
  
  # Erstellen einer .keep-Datei, um sicherzustellen, dass das Verzeichnis existiert
  touch /vault/data/.keep
  
  # Erstellen eines Reset-Locks, um zu verhindern, dass das Skript erneut ausgeführt wird
  touch /vault/data/.reset_lock
  
  echo "Vault data reset completed. Vault will be reinitialized."
else
  echo "Vault data check passed, no reset needed."
  # Erstellen eines Reset-Locks, um zu verhindern, dass das Skript erneut ausgeführt wird
  touch /vault/data/.reset_lock
fi
