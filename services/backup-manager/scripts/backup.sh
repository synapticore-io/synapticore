#!/bin/bash
set -e

# Configuration
BACKUP_DIR="/backup/$(date +%Y%m%d_%H%M%S)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Get secrets either from Vault or local files
get_secrets() {
  if [ "${USE_VAULT_SECRETS:-false}" = "true" ]; then
    echo "Getting secrets from Vault..."
    
    # Try to get Vault token
    if [ -z "$VAULT_TOKEN" ]; then
      ROOT_TOKEN=$(docker exec vault cat /vault/data/root_token.txt 2>/dev/null || echo "")
      if [ -n "$ROOT_TOKEN" ]; then
        export VAULT_TOKEN="$ROOT_TOKEN"
      fi
    fi
    
    # Get MongoDB password
    MONGO_SECRET=$(curl -s -k -H "X-Vault-Token: ${VAULT_TOKEN:-root}" \
      "${VAULT_ADDR}/v1/secret/data/mongodb" || echo '{"data":{"data":{}}}')
    MONGO_PASSWORD=$(echo $MONGO_SECRET | grep -o '"password":"[^"]*"' | cut -d':' -f2 | tr -d '"')
    
    # Get Redis password
    REDIS_SECRET=$(curl -s -k -H "X-Vault-Token: ${VAULT_TOKEN:-root}" \
      "${VAULT_ADDR}/v1/secret/data/redis" || echo '{"data":{"data":{}}}')
    REDIS_PASSWORD=$(echo $REDIS_SECRET | grep -o '"password":"[^"]*"' | cut -d':' -f2 | tr -d '"')
    
    # Get backup encryption key
    BACKUP_SECRET=$(curl -s -k -H "X-Vault-Token: ${VAULT_TOKEN:-root}" \
      "${VAULT_ADDR}/v1/secret/data/backup" || echo '{"data":{"data":{}}}')
    ENCRYPTION_KEY=$(echo $BACKUP_SECRET | grep -o '"encryption_key":"[^"]*"' | cut -d':' -f2 | tr -d '"')
    
    # Fallback if empty
    MONGO_PASSWORD=${MONGO_PASSWORD:-admin}
    REDIS_PASSWORD=${REDIS_PASSWORD:-changeme}
    ENCRYPTION_KEY=${ENCRYPTION_KEY:-"backup-encryption-key"}
  else
    echo "Using local secrets..."
    
    # Use environment variables or fallback to defaults
    ENCRYPTION_KEY=$(cat "${ENCRYPTION_KEY_FILE:-/backup-data/backup_encryption_key.txt}" 2>/dev/null || echo "defaultkey")
    MONGO_PASSWORD="admin"  # Default if not found
    REDIS_PASSWORD=""       # Default if not found
  fi
}

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Get secrets
get_secrets

# Function to encrypt backup files
encrypt_backup() {
  local src_file=$1
  local dest_file="${src_file}.enc"
  
  openssl enc -aes-256-cbc -salt -in "$src_file" -out "$dest_file" -k "$ENCRYPTION_KEY" -md sha256
  rm "$src_file"
  echo "Encrypted: $src_file -> $dest_file"
}

# Check if container exists
container_exists() {
  docker ps -q -f name="^/$1$" | grep -q .
}

# Backup MongoDB if it exists
echo "[$TIMESTAMP] Backing up MongoDB..."
if container_exists "mongodb"; then
  mkdir -p "$BACKUP_DIR/mongodb"
  
  # Check if authentication is needed
  if docker exec mongodb mongo --eval "db.stats()" &>/dev/null; then
    docker exec mongodb mongodump --out /tmp/backup
  else
    docker exec mongodb mongodump --username admin --password "$MONGO_PASSWORD" --out /tmp/backup
  fi
  
  docker cp mongodb:/tmp/backup "$BACKUP_DIR/mongodb"
  docker exec mongodb rm -rf /tmp/backup
  tar -czf "$BACKUP_DIR/mongodb_$TIMESTAMP.tar.gz" -C "$BACKUP_DIR" mongodb
  rm -rf "$BACKUP_DIR/mongodb"
  encrypt_backup "$BACKUP_DIR/mongodb_$TIMESTAMP.tar.gz"
else
  echo "[$TIMESTAMP] MongoDB container not found, skipping backup."
fi

# Backup Redis if it exists
echo "[$TIMESTAMP] Backing up Redis..."
if container_exists "redis"; then
  mkdir -p "$BACKUP_DIR/redis"
  # Ensure Redis SAVE is executed
  if [ -n "$REDIS_PASSWORD" ]; then
    docker exec redis redis-cli -a "$REDIS_PASSWORD" SAVE
  else
    docker exec redis redis-cli SAVE
  fi
  docker cp redis:/data "$BACKUP_DIR/redis"
  tar -czf "$BACKUP_DIR/redis_$TIMESTAMP.tar.gz" -C "$BACKUP_DIR" redis
  rm -rf "$BACKUP_DIR/redis"
  encrypt_backup "$BACKUP_DIR/redis_$TIMESTAMP.tar.gz"
else
  echo "[$TIMESTAMP] Redis container not found, skipping backup."
fi

# Backup Vault if it exists
echo "[$TIMESTAMP] Backing up Vault..."
if container_exists "vault"; then
  mkdir -p "$BACKUP_DIR/vault"
  docker cp vault:/vault/data "$BACKUP_DIR/vault"
  tar -czf "$BACKUP_DIR/vault_$TIMESTAMP.tar.gz" -C "$BACKUP_DIR" vault
  rm -rf "$BACKUP_DIR/vault"
  encrypt_backup "$BACKUP_DIR/vault_$TIMESTAMP.tar.gz"
else
  echo "[$TIMESTAMP] Vault container not found, skipping backup."
fi

# Backup Qdrant if it exists
echo "[$TIMESTAMP] Backing up Qdrant..."
if container_exists "qdrant"; then
  mkdir -p "$BACKUP_DIR/qdrant"
  docker cp qdrant:/qdrant/storage "$BACKUP_DIR/qdrant"
  tar -czf "$BACKUP_DIR/qdrant_$TIMESTAMP.tar.gz" -C "$BACKUP_DIR" qdrant
  rm -rf "$BACKUP_DIR/qdrant"
  encrypt_backup "$BACKUP_DIR/qdrant_$TIMESTAMP.tar.gz"
else
  echo "[$TIMESTAMP] Qdrant container not found, skipping backup."
fi

# Create backup manifest with SHA256 checksums
echo "[$TIMESTAMP] Creating backup manifest..."
echo "Backup created on $(date)" > "$BACKUP_DIR/manifest.txt"
echo "Services: MongoDB, Redis, Vault, Qdrant" >> "$BACKUP_DIR/manifest.txt"
echo "" >> "$BACKUP_DIR/manifest.txt"
echo "Checksums:" >> "$BACKUP_DIR/manifest.txt"
for file in "$BACKUP_DIR"/*.enc; do
  if [ -f "$file" ]; then
    CHECKSUM=$(sha256sum "$file" | cut -d' ' -f1)
    echo "$(basename "$file"): $CHECKSUM" >> "$BACKUP_DIR/manifest.txt"
  fi
done

# Encrypt the manifest itself
encrypt_backup "$BACKUP_DIR/manifest.txt"

echo "[$TIMESTAMP] Backup completed successfully! Files stored in $BACKUP_DIR"

# Remote Backup to S3 (if configured)
if [ "$REMOTE_BACKUP" = "true" ] && [ -n "$S3_BUCKET" ]; then
  echo "[$TIMESTAMP] Uploading backup to S3 bucket $S3_BUCKET..."
  aws s3 sync "$BACKUP_DIR" "s3://$S3_BUCKET/$(basename "$BACKUP_DIR")/"
  echo "[$TIMESTAMP] S3 upload completed!"
fi
