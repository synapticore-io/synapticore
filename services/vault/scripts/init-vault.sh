#!/bin/bash
set -e

# Warten auf Vault
until curl -s -k https://127.0.0.1:8200/v1/sys/health; do
  echo "Warte auf Vault..."
  sleep 1
done

# Prüfe, ob Vault initialisiert ist
INITIALIZED=$(curl -s -k https://127.0.0.1:8200/v1/sys/init | grep -c '"initialized":true')

if [ "$INITIALIZED" -eq 0 ]; then
  echo "Initialisiere Vault..."
  
  # Bei Auto-Unseal werden weniger Unseal-Keys benötigt
  # Wenn kein Auto-Unseal konfiguriert ist, nutzt Shamir mit 5 Keys
  INIT_RESPONSE=$(curl -s -k https://127.0.0.1:8200/v1/sys/init -X PUT -d '{"secret_shares": 5, "secret_threshold": 3}')
  
  # Speichere Root-Token und Unseal-Keys sicher
  echo "$INIT_RESPONSE" > /vault/data/init_data.json
  chmod 600 /vault/data/init_data.json
  
  # Exportiere die Keys auch in einzelne Dateien für einfachere Handhabung
  ROOT_TOKEN=$(echo "$INIT_RESPONSE" | jq -r '.root_token')
  echo "$ROOT_TOKEN" > /vault/data/root_token.txt
  chmod 600 /vault/data/root_token.txt
  
  echo "Vault initialisiert. Root-Token und Unseal-Keys in /vault/data/init_data.json gespeichert."
  echo "WICHTIG: Sichern Sie diese Daten an einem sicheren Ort!"
  
  # Extrahiere Unseal-Keys
  for i in {0..4}; do
    KEY=$(echo "$INIT_RESPONSE" | jq -r ".keys_base64[$i]")
    echo "$KEY" > /vault/data/unseal_key_$i.txt
    chmod 600 /vault/data/unseal_key_$i.txt
  done
  
  # Unseal Vault
  for i in {0..2}; do
    UNSEAL_KEY=$(cat /vault/data/unseal_key_$i.txt)
    curl -s -k https://127.0.0.1:8200/v1/sys/unseal -X PUT -d "{\"key\":\"$UNSEAL_KEY\"}"
    sleep 1
  done
else
  echo "Vault ist bereits initialisiert."
  
  # Wenn Vault versiegelt ist, entsiegeln
  SEALED=$(curl -s -k https://127.0.0.1:8200/v1/sys/seal-status | grep -c '"sealed":true')
  if [ "$SEALED" -eq 1 ] && [ -f /vault/data/unseal_key_0.txt ]; then
    echo "Vault ist versiegelt. Entsiegele..."
    
    # Unseal mit den vorhandenen Keys
    for i in {0..2}; do
      if [ -f /vault/data/unseal_key_$i.txt ]; then
        UNSEAL_KEY=$(cat /vault/data/unseal_key_$i.txt)
        curl -s -k https://127.0.0.1:8200/v1/sys/unseal -X PUT -d "{\"key\":\"$UNSEAL_KEY\"}"
        sleep 1
      fi
    done
  fi
fi

# Konfiguriere Vault für Production, wenn Root-Token vorhanden ist
if [ -f /vault/data/root_token.txt ]; then
  echo "Konfiguriere Vault für Production-Umgebung..."
  
  # Extrahiere Root-Token
  ROOT_TOKEN=$(cat /vault/data/root_token.txt)
  
  # Exportiere Root-Token für Vault-CLI
  export VAULT_TOKEN="$ROOT_TOKEN"
  export VAULT_ADDR="https://127.0.0.1:8200"
  export VAULT_SKIP_VERIFY="true"
  
  # Prüfe ob Audit-Logging aktiviert ist, wenn nicht, aktivieren
  AUDIT_ENABLED=$(vault audit list 2>/dev/null | grep -c 'file/' || echo "0")
  if [ "$AUDIT_ENABLED" -eq 0 ]; then
    vault audit enable file file_path=/vault/logs/audit.log
  fi
  
  # Aktiviere wichtige Secret Engines, falls noch nicht geschehen
  vault secrets enable -path=secret kv-v2 2>/dev/null || echo "KV-v2 bereits aktiviert"
  vault secrets enable -path=pki pki 2>/dev/null || echo "PKI bereits aktiviert"
  vault secrets enable -path=transit transit 2>/dev/null || echo "Transit bereits aktiviert"
  
  # Konfiguriere PKI für interne CAs
  vault secrets tune -max-lease-ttl=87600h pki 2>/dev/null || echo "PKI bereits konfiguriert"
  
  echo "Vault ist produktionsbereit konfiguriert."
fi
