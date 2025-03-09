#!/bin/sh
set -e

# Default password (will be overridden if we can get from Vault)
REDIS_PASSWORD="synapticore-redis"

# Try to get password from Vault
if [ -n "$VAULT_ADDR" ]; then
  echo "Attempting to retrieve Redis password from Vault..."
  
  # Wait for Vault to be ready
  RETRY_COUNT=0
  MAX_RETRIES=30
  
  while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    HEALTH_CHECK=$(curl -s $VAULT_ADDR/v1/sys/health || echo '{"sealed":true}')
    IS_SEALED=$(echo $HEALTH_CHECK | grep -c '"sealed":false' || echo "0")
    IS_INIT=$(echo $HEALTH_CHECK | grep -c '"initialized":true' || echo "0")
    
    if [ "$IS_SEALED" = "1" ] && [ "$IS_INIT" = "1" ]; then
      echo "Vault is unsealed and ready"
      break
    fi
    
    echo "Waiting for Vault to be unsealed... Attempt $((RETRY_COUNT+1)) of $MAX_RETRIES"
    RETRY_COUNT=$((RETRY_COUNT+1))
    sleep 2
  done
  
  if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
    # Try to get Vault token
    ROOT_TOKEN=""
    
    # Versuche, das Token von einem gemounteten Volume zu lesen
    if [ -f "/tmp/vault_token.txt" ]; then
      ROOT_TOKEN=$(cat /tmp/vault_token.txt 2>/dev/null || echo "")
    fi
    
    # Versuche, das Token über curl von Vault zu bekommen
    if [ -z "$ROOT_TOKEN" ]; then
      # Warte etwas länger auf Vault
      sleep 5
      # Verwende curl ohne -k da wir HTTP verwenden
      VAULT_RESPONSE=$(curl -s $VAULT_ADDR/v1/secret/data/redis || echo '{"data":{"data":{"password":""}}}')
      PASSWORD=$(echo $VAULT_RESPONSE | grep -o '"password":"[^"]*"' | sed 's/"password":"//;s/"//')
      
      if [ -n "$PASSWORD" ]; then
        echo "Got password via anonymous request - this should not happen in production!"
        REDIS_PASSWORD="$PASSWORD"
      else
        echo "Failed to retrieve password anonymously"
        
        # Versuche, das Root-Token direkt vom Vault-Container zu bekommen
        ROOT_TOKEN=$(curl -s --unix-socket /var/run/docker.sock http:/v1.40/containers/vault/exec -H "Content-Type: application/json" -d '{"AttachStdin":false,"AttachStdout":true,"AttachStderr":true,"Cmd":["cat","/vault/data/root_token.txt"]}' | grep -o '"Id":"[^"]*"' | cut -d'"' -f4)
        
        if [ -n "$ROOT_TOKEN" ]; then
          echo "Got root token from Vault container"
        fi
      fi
    fi
    
    # Wenn wir jetzt ein Token haben, versuche nochmal
    if [ -n "$ROOT_TOKEN" ]; then
      # Verwende curl ohne -k da wir HTTP verwenden
      VAULT_RESPONSE=$(curl -s -H "X-Vault-Token: ${ROOT_TOKEN}" \
        "${VAULT_ADDR}/v1/secret/data/redis" || echo '{"data":{"data":{"password":""}}}')
      
      PASSWORD=$(echo $VAULT_RESPONSE | grep -o '"password":"[^"]*"' | sed 's/"password":"//;s/"//')
      
      if [ -n "$PASSWORD" ]; then
        echo "Successfully retrieved Redis password from Vault"
        REDIS_PASSWORD="$PASSWORD"
      else
        echo "Failed to retrieve password from Vault, using default"
      fi
    else
      echo "No Vault token available, using default password"
    fi
  else
    echo "Vault not ready after $MAX_RETRIES attempts, using default password"
  fi
else
  echo "VAULT_ADDR not set, using default password"
fi

echo "Using Redis password: $REDIS_PASSWORD"

# Create Redis configuration
sed "s/REDIS_PASSWORD_PLACEHOLDER/$REDIS_PASSWORD/g" /usr/local/etc/redis/redis.conf.template > /usr/local/etc/redis/redis.conf

# Start Redis server
exec redis-server /usr/local/etc/redis/redis.conf
