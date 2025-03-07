#!/bin/bash
set -e

# Warten auf Vault
until curl -s -k https://127.0.0.1:8200/v1/sys/health || curl -s http://127.0.0.1:8200/v1/sys/health; do
  echo "Warte auf Vault..."
  sleep 1
done

# Prüfe, ob Vault initialisiert ist
INITIALIZED=$(curl -s -k https://127.0.0.1:8200/v1/sys/init | grep -c '"initialized":true' || curl -s http://127.0.0.1:8200/v1/sys/init | grep -c '"initialized":true')

if [ "$INITIALIZED" -eq 0 ]; then
  echo "Initialisiere Vault..."
  
  # Bei Auto-Unseal werden weniger Unseal-Keys benötigt
  # Wenn kein Auto-Unseal konfiguriert ist, nutzt Shamir mit 5 Keys
  INIT_RESPONSE=$(curl -s -k https://127.0.0.1:8200/v1/sys/init -X PUT -d '{"secret_shares": 5, "secret_threshold": 3}' || curl -s http://127.0.0.1:8200/v1/sys/init -X PUT -d '{"secret_shares": 5, "secret_threshold": 3}')
  
  # Speichere Root-Token und Unseal-Keys sicher
  echo "$INIT_RESPONSE" > /vault/data/init_data.json
  chmod 600 /vault/data/init_data.json
  
  echo "Vault initialisiert. Root-Token und Unseal-Keys in /vault/data/init_data.json gespeichert."
  echo "WICHTIG: Sichern Sie diese Daten an einem sicheren Ort!"
else
  echo "Vault ist bereits initialisiert."
fi

# Konfiguriere Vault für Production
echo "Konfiguriere Vault für Production-Umgebung..."

# Extrahiere Root-Token aus init_data.json (wenn vorhanden)
if [ -f /vault/data/init_data.json ]; then
  ROOT_TOKEN=$(grep -o '"root_token":"[^"]*' /vault/data/init_data.json | cut -d'"' -f4)
  if [ ! -z "$ROOT_TOKEN" ]; then
    # Exportiere Root-Token für Vault-CLI
    export VAULT_TOKEN="$ROOT_TOKEN"
    
    # Aktiviere Audit Logging
    vault audit enable file file_path=/vault/logs/audit.log
    
    # Aktiviere wichtige Secret Engines für typische Anwendungsfälle
    vault secrets enable -path=secret kv-v2
    vault secrets enable -path=pki pki
    vault secrets enable -path=transit transit
    
    # Konfiguriere PKI für interne CAs
    vault secrets tune -max-lease-ttl=87600h pki
    
    echo "Vault ist produktionsbereit konfiguriert."
  fi
fi
