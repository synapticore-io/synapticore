#!/bin/bash
set -e

export VAULT_ADDR="https://127.0.0.1:8200"
export VAULT_SKIP_VERIFY="true"

# Warten, bis Vault bereit ist
echo "Waiting for Vault to start..."
until curl -s -k $VAULT_ADDR/v1/sys/health > /dev/null 2>&1; do
  echo "Waiting for Vault to become available..."
  sleep 1
done

# Check if Vault is initialized
initialized=$(curl -s -k $VAULT_ADDR/v1/sys/init | jq -r '.initialized')

if [ "$initialized" = "false" ]; then
  echo "Initializing Vault..."
  
  # Initialize Vault with 1 key share and 1 key threshold (for development/testing)
  INIT_RESPONSE=$(curl -s -k -X PUT -d '{"secret_shares": 1, "secret_threshold": 1}' $VAULT_ADDR/v1/sys/init)
  
  # Extract keys and token
  UNSEAL_KEY=$(echo $INIT_RESPONSE | jq -r .keys[0])
  ROOT_TOKEN=$(echo $INIT_RESPONSE | jq -r .root_token)
  
  # Save keys and token to files for later use
  echo $UNSEAL_KEY > /vault/data/unseal_key.txt
  echo $ROOT_TOKEN > /vault/data/root_token.txt
  
  # Set permissions
  chmod 600 /vault/data/unseal_key.txt /vault/data/root_token.txt
  
  echo "Vault initialized!"
else
  echo "Vault already initialized"
  
  # Ensure we have the root token file
  if [ ! -f /vault/data/root_token.txt ] && [ ! -f /vault/data/unseal_key.txt ]; then
    echo "Warning: Vault is initialized but no token files found. This may be a problem."
  fi
fi

# Check if Vault is sealed
sealed=$(curl -s -k $VAULT_ADDR/v1/sys/seal-status | jq -r '.sealed')

if [ "$sealed" = "true" ]; then
  echo "Unsealing Vault..."
  
  # Get unseal key
  if [ -f /vault/data/unseal_key.txt ]; then
    UNSEAL_KEY=$(cat /vault/data/unseal_key.txt)
    curl -s -k -X PUT -d "{\"key\": \"$UNSEAL_KEY\"}" $VAULT_ADDR/v1/sys/unseal
    echo "Vault unsealed!"
  else
    echo "Unseal key not found"
    exit 1
  fi
else
  echo "Vault already unsealed"
fi

# Get root token
if [ ! -f /vault/data/root_token.txt ]; then
  echo "Root token not found. Cannot setup secrets."
  exit 1
fi

ROOT_TOKEN=$(cat /vault/data/root_token.txt)
export VAULT_TOKEN="$ROOT_TOKEN"

echo "Setting up initial secrets..."

# Enable KV secrets engine version 2 if not already enabled
SECRETS_ENABLED=$(curl -s -k -H "X-Vault-Token: $ROOT_TOKEN" $VAULT_ADDR/v1/sys/mounts | grep -c '"secret/"' || echo "0")
if [ "$SECRETS_ENABLED" = "0" ]; then
  echo "Enabling KV secrets engine..."
  curl -s -k -X POST -H "X-Vault-Token: $ROOT_TOKEN" -d '{"type":"kv","options":{"version":"2"}}' $VAULT_ADDR/v1/sys/mounts/secret
fi

# Enable Transit Secret Engine for encryption operations if not already enabled
TRANSIT_ENABLED=$(curl -s -k -H "X-Vault-Token: $ROOT_TOKEN" $VAULT_ADDR/v1/sys/mounts | grep -c '"transit/"' || echo "0")
if [ "$TRANSIT_ENABLED" = "0" ]; then
  echo "Enabling Transit Secret Engine..."
  curl -s -k -X POST -H "X-Vault-Token: $ROOT_TOKEN" -d '{"type":"transit"}' $VAULT_ADDR/v1/sys/mounts/transit
  
  # Create encryption key for general use
  curl -s -k -X POST -H "X-Vault-Token: $ROOT_TOKEN" -d '{}' $VAULT_ADDR/v1/transit/keys/synapticore-key
  
  echo "Transit Secret Engine enabled!"
fi

# Initialize secrets with vault cli
# Note: We use the HTTP API directly for the initial checks above, but switch to the vault CLI 
# for convenience when creating secrets

# Generate random passwords if they don't exist in Vault
if ! vault kv get -format=json secret/mongodb &>/dev/null; then
  echo "Creating MongoDB credentials in Vault..."
  MONGO_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16)
  vault kv put secret/mongodb username=admin password="$MONGO_PASSWORD"
fi

if ! vault kv get -format=json secret/redis &>/dev/null; then
  echo "Creating Redis password in Vault..."
  REDIS_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16)
  vault kv put secret/redis password="$REDIS_PASSWORD"
fi

if ! vault kv get -format=json secret/backup &>/dev/null; then
  echo "Creating backup encryption key in Vault..."
  BACKUP_KEY=$(openssl rand -base64 32)
  vault kv put secret/backup encryption_key="$BACKUP_KEY"
fi

echo "Initial secrets setup completed!"
