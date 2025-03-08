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

# Enable Transit Secret Engine for Auto-Unseal
TRANSIT_ENABLED=$(curl -s -k -H "X-Vault-Token: $ROOT_TOKEN" $VAULT_ADDR/v1/sys/mounts | grep -c '"transit/"' || echo "0")
if [ "$TRANSIT_ENABLED" = "0" ]; then
  echo "Enabling Transit Secret Engine for Auto-Unseal..."
  curl -s -k -X POST -H "X-Vault-Token: $ROOT_TOKEN" -d '{"type":"transit"}' $VAULT_ADDR/v1/sys/mounts/transit
  
  # Create encryption key for Auto-Unseal
  curl -s -k -X POST -H "X-Vault-Token: $ROOT_TOKEN" -d '{}' $VAULT_ADDR/v1/transit/keys/autounseal
  
  # Create policy for Auto-Unseal
  curl -s -k -X PUT -H "X-Vault-Token: $ROOT_TOKEN" -d '{
    "policy": "path \"transit/encrypt/autounseal\" { capabilities = [ \"update\" ] }\npath \"transit/decrypt/autounseal\" { capabilities = [ \"update\" ] }"
  }' $VAULT_ADDR/v1/sys/policies/acl/autounseal
  
  # Create token for Auto-Unseal
  TRANSIT_TOKEN_RESPONSE=$(curl -s -k -X POST -H "X-Vault-Token: $ROOT_TOKEN" -d '{
    "policies": ["autounseal"],
    "ttl": "24h",
    "renewable": true
  }' $VAULT_ADDR/v1/auth/token/create)
  
  TRANSIT_TOKEN=$(echo $TRANSIT_TOKEN_RESPONSE | jq -r .auth.client_token)
  echo $TRANSIT_TOKEN > /vault/data/transit-token.txt
  chmod 600 /vault/data/transit-token.txt
  
  echo "Transit Secret Engine configured for Auto-Unseal!"
fi

# Enable KV secrets engine version 2 if not already enabled
SECRETS_ENABLED=$(curl -s -k -H "X-Vault-Token: $ROOT_TOKEN" $VAULT_ADDR/v1/sys/mounts | grep -c '"secret/"' || echo "0")
if [ "$SECRETS_ENABLED" = "0" ]; then
  echo "Enabling KV secrets engine..."
  curl -s -k -X POST -H "X-Vault-Token: $ROOT_TOKEN" -d '{"type":"kv","options":{"version":"2"}}' $VAULT_ADDR/v1/sys/mounts/secret
fi

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