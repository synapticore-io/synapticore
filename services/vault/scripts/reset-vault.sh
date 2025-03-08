#!/bin/bash
set -e

# Überprüfen, ob ein Reset-Lock existiert
if [ -f "/vault/data/.reset_lock" ]; then
  echo "Reset lock exists, skipping reset."
  exit 0
fi

# Überprüfen, ob Vault-Daten existieren, aber der Unseal-Schlüssel fehlt
if [ -d "/vault/data" ] && [ ! -f "/vault/data/unseal_key.txt" ]; then
  echo "Vault data exists but unseal key is missing. Performing complete reset..."
  
  # Sicherstellen, dass Vault nicht läuft
  pkill vault || true
  
  # Warten, bis Vault vollständig beendet ist
  sleep 2
  
  # Vollständiges Löschen aller Daten
  rm -rf /vault/data/*
  
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