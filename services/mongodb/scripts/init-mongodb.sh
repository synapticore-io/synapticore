#!/bin/bash
set -e

echo "Initializing MongoDB with admin user..."

# Check if MongoDB is already initialized
if [ -f /data/db/.mongodb_initialized ]; then
  echo "MongoDB already initialized. Skipping setup."
  exit 0
fi

# Wait for MongoDB to start
until mongo --eval "db.stats()" &>/dev/null; do
  echo "Waiting for MongoDB to start..."
  sleep 2
done

# Default admin password
MONGO_ADMIN_PASSWORD="admin"

# Try to get password from Vault if environment variable is set
if [ -n "$VAULT_ADDR" ]; then
  echo "Attempting to retrieve MongoDB password from Vault..."
  
  # Get root token from Vault container
  ROOT_TOKEN=$(curl -s -k ${VAULT_ADDR}/v1/sys/health >/dev/null && \
    docker exec vault cat /vault/data/root_token.txt 2>/dev/null || echo "")
  
  if [ -n "$ROOT_TOKEN" ]; then
    # Get MongoDB password from Vault
    VAULT_RESPONSE=$(curl -s -k -H "X-Vault-Token: ${ROOT_TOKEN}" \
      "${VAULT_ADDR}/v1/secret/data/mongodb" || echo '{"data":{"data":{}}}')
    
    PASSWORD=$(echo $VAULT_RESPONSE | grep -o '"password":"[^"]*"' | cut -d':' -f2 | tr -d '"')
    
    if [ -n "$PASSWORD" ]; then
      echo "Successfully retrieved MongoDB password from Vault"
      MONGO_ADMIN_PASSWORD="$PASSWORD"
    else
      echo "Failed to retrieve password from Vault, using default"
    fi
  else
    echo "Could not retrieve Vault token, using default password"
  fi
else
  echo "VAULT_ADDR not set, using default password"
fi

# Create admin user
mongo admin --eval "db.createUser({user: 'admin', pwd: '$MONGO_ADMIN_PASSWORD', roles: [{role: 'root', db: 'admin'}]})"

# Create initialization flag
touch /data/db/.mongodb_initialized

echo "MongoDB initialization completed!"
