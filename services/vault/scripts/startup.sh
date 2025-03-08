#!/bin/bash
set -e

# Transit-Server Konfiguration überschreiben falls aktiviert
if [ "${VAULT_TRANSIT_SERVER:-false}" = "true" ]; then
  echo "Konfiguriere als Transit-Server..."
  cat > /vault/config/config.hcl << 'EOT'
ui = true
disable_mlock = true

storage "raft" {
  path = "/vault/data"
  node_id = "vault_transit_1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

api_addr = "http://0.0.0.0:8200"
cluster_addr = "http://0.0.0.0:8201"

default_lease_ttl = "768h"
max_lease_ttl = "768h"

telemetry {
  prometheus_retention_time = "24h"
  disable_hostname = true
}

log_level = "info"
log_format = "json"
EOT
fi

# TLS-Zertifikate generieren wenn benötigt
if grep -q "tls_disable = 0" /vault/config/config.hcl; then
  echo "TLS aktiviert, generiere Zertifikate..."
  /vault/generate-tls.sh
fi

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

while ! curl -s -k ${VAULT_ADDR:-http://127.0.0.1:8200}/v1/sys/health > /dev/null 2>&1; do
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
