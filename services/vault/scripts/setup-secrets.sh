#!/bin/bash
set -e

# This script sets up initial secrets in Vault for other services to use

# Check if Vault is unsealed
SEALED=$(curl -s -k https://127.0.0.1:8200/v1/sys/seal-status | grep -c '"sealed":true')
if [ "$SEALED" -eq 1 ]; then
  echo "Vault is still sealed. Cannot setup secrets."
  exit 1
fi

# Check if root token exists
if [ ! -f /vault/data/root_token.txt ]; then
  echo "Root token not found. Cannot setup secrets."
  exit 1
fi

# Get root token
ROOT_TOKEN=$(cat /vault/data/root_token.txt)
export VAULT_TOKEN="$ROOT_TOKEN"
export VAULT_ADDR="https://127.0.0.1:8200"
export VAULT_SKIP_VERIFY="true"

echo "Setting up initial secrets..."

# Generate random passwords if they don't exist in Vault
MONGO_SECRET_EXISTS=$(vault kv get -format=json secret/mongodb 2>/dev/null || echo '{"data":{"data":{}}}')
MONGO_USERNAME=$(echo $MONGO_SECRET_EXISTS | jq -r '.data.data.username // empty')

if [ -z "$MONGO_USERNAME" ]; then
  echo "Creating MongoDB credentials in Vault..."
  MONGO_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16)
  vault kv put secret/mongodb username=admin password="$MONGO_PASSWORD"
fi

REDIS_SECRET_EXISTS=$(vault kv get -format=json secret/redis 2>/dev/null || echo '{"data":{"data":{}}}')
REDIS_PASSWORD=$(echo $REDIS_SECRET_EXISTS | jq -r '.data.data.password // empty')

if [ -z "$REDIS_PASSWORD" ]; then
  echo "Creating Redis password in Vault..."
  REDIS_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16)
  vault kv put secret/redis password="$REDIS_PASSWORD"
fi

GRAFANA_SECRET_EXISTS=$(vault kv get -format=json secret/grafana 2>/dev/null || echo '{"data":{"data":{}}}')
GRAFANA_PASSWORD=$(echo $GRAFANA_SECRET_EXISTS | jq -r '.data.data.password // empty')

if [ -z "$GRAFANA_PASSWORD" ]; then
  echo "Creating Grafana credentials in Vault..."
  GRAFANA_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16)
  vault kv put secret/grafana username=admin password="$GRAFANA_PASSWORD"
fi

BACKUP_SECRET_EXISTS=$(vault kv get -format=json secret/backup 2>/dev/null || echo '{"data":{"data":{}}}')
BACKUP_KEY=$(echo $BACKUP_SECRET_EXISTS | jq -r '.data.data.encryption_key // empty')

if [ -z "$BACKUP_KEY" ]; then
  echo "Creating backup encryption key in Vault..."
  BACKUP_KEY=$(openssl rand -base64 32)
  vault kv put secret/backup encryption_key="$BACKUP_KEY"
fi

echo "Initial secrets setup completed!"
