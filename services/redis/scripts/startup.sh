#!/bin/sh
set -e

# Default password (will be overridden if we can get from Vault)
REDIS_PASSWORD="changeme"

# Try to get password from Vault
if [ -n "$VAULT_ADDR" ]; then
  echo "Attempting to retrieve Redis password from Vault..."
  
  # Wait for Vault to be ready
  RETRY_COUNT=0
  MAX_RETRIES=30
  
  while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    HEALTH_CHECK=$(curl -s -k "${VAULT_ADDR}/v1/sys/health" || echo '{"sealed":true}')
    IS_SEALED=$(echo $HEALTH_CHECK | grep -c '"sealed":false' || echo "0")
    
    if [ "$IS_SEALED" = "1" ]; then
      echo "Vault is unsealed and ready"
      break
    fi
    
    echo "Waiting for Vault to be unsealed... Attempt $RETRY_COUNT of $MAX_RETRIES"
    RETRY_COUNT=$((RETRY_COUNT + 1))
    sleep 2
  done
  
  if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
    # Get Vault token
    VAULT_TOKEN="$(curl -s -k ${VAULT_ADDR}/v1/auth/token/lookup-self -H "X-Vault-Token: ${VAULT_TOKEN:-root}" | grep -c "errors" || echo "0")"
    
    if [ "$VAULT_TOKEN" = "0" ]; then
      # Get password from Vault
      VAULT_RESPONSE=$(curl -s -k -H "X-Vault-Token: ${VAULT_TOKEN:-root}" \
        "${VAULT_ADDR}/v1/secret/data/redis" || echo '{"data":{"data":{"password":""}}}')
      
      PASSWORD=$(echo $VAULT_RESPONSE | grep -o '"password":"[^"]*"' | sed 's/"password":"//;s/"//')
      
      if [ -n "$PASSWORD" ]; then
        echo "Successfully retrieved Redis password from Vault"
        REDIS_PASSWORD="$PASSWORD"
      else
        echo "Failed to retrieve password from Vault, using default"
      fi
    else
      echo "Invalid Vault token, using default password"
    fi
  else
    echo "Vault not ready after $MAX_RETRIES attempts, using default password"
  fi
else
  echo "VAULT_ADDR not set, using default password"
fi

# Create Redis configuration
sed "s/REDIS_PASSWORD_PLACEHOLDER/$REDIS_PASSWORD/g" /usr/local/etc/redis/redis.conf.template > /usr/local/etc/redis/redis.conf

# Start Redis server
exec redis-server /usr/local/etc/redis/redis.conf
