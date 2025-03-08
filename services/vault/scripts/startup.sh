#!/bin/bash
set -e

# TLS-Zertifikate generieren
/vault/generate-tls.sh

# Vault-Daten zurücksetzen, falls erforderlich
/vault/reset-vault.sh

# Vault-Server im Hintergrund starten
echo "Starting Vault server..."
/bin/vault server -config=/vault/config/config.hcl > /vault/logs/vault.log 2>&1 &
VAULT_PID=$!

# Warten, bis Vault bereit ist
echo "Waiting for Vault to start..."
MAX_RETRIES=30
RETRY_COUNT=0

while ! curl -s -k https://127.0.0.1:8200/v1/sys/health > /dev/null 2>&1; do
  echo "Waiting for Vault to become available... (Attempt $((RETRY_COUNT+1))/$MAX_RETRIES)"
  sleep 2
  
  # Überprüfen, ob der Vault-Prozess noch läuft
  if ! ps -p $VAULT_PID > /dev/null; then
    echo "Vault server process died. Checking logs:"
    tail -n 20 /vault/logs/vault.log || true
    
    # Wenn wir das maximale Limit erreicht haben, beenden wir mit einem Fehler
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
      echo "Maximum retry attempts reached. Vault server failed to start."
      exit 1
    fi
    
    echo "Restarting Vault server..."
    /bin/vault server -config=/vault/config/config.hcl > /vault/logs/vault.log 2>&1 &
    VAULT_PID=$!
  fi
  
  RETRY_COUNT=$((RETRY_COUNT+1))
  
  # Wenn wir das maximale Limit erreicht haben, beenden wir mit einem Fehler
  if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "Maximum retry attempts reached. Vault server failed to start."
    exit 1
  fi
done

# Vault initialisieren und entsperren
echo "Vault server is running. Initializing and unsealing..."
/vault/init-vault.sh

# Auf den Vault-Prozess warten
echo "Vault setup completed. Waiting for Vault server process..."
wait $VAULT_PID 