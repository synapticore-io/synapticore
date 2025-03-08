#!/bin/bash
set -e

# TLS-Zertifikate generieren
/vault/generate-tls.sh

# Vault-Daten zurücksetzen, falls erforderlich
/vault/reset-vault.sh

# Vault-Server im Hintergrund starten
echo "Starting Vault server..."
/bin/vault server -config=/vault/config/config.hcl &
VAULT_PID=$!

# Warten, bis Vault bereit ist
echo "Waiting for Vault to start..."
until curl -s -k https://127.0.0.1:8200/v1/sys/health > /dev/null 2>&1; do
  echo "Waiting for Vault to become available..."
  sleep 1
  
  # Überprüfen, ob der Vault-Prozess noch läuft
  if ! ps -p $VAULT_PID > /dev/null; then
    echo "Vault server process died. Checking logs:"
    cat /vault/logs/vault.log || true
    echo "Restarting Vault server..."
    /bin/vault server -config=/vault/config/config.hcl &
    VAULT_PID=$!
  fi
done

# Vault initialisieren und entsperren
echo "Vault server is running. Initializing and unsealing..."
/vault/init-vault.sh

# Auf den Vault-Prozess warten
echo "Vault setup completed. Waiting for Vault server process..."
wait $VAULT_PID 