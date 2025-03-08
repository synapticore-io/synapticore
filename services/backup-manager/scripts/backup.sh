#!/bin/bash
set -e

# Konfiguration
BACKUP_DIR="/backup/$(date +%Y%m%d_%H%M%S)"
ENCRYPTION_KEY=$(cat $ENCRYPTION_KEY_FILE)
MONGO_PASSWORD=$(cat /secrets/mongo_root_password.txt)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Erstelle Backup-Verzeichnis
mkdir -p $BACKUP_DIR

# Funktion zum Verschlüsseln von Backup-Dateien
encrypt_backup() {
  local src_file=$1
  local dest_file="${src_file}.enc"
  
  openssl enc -aes-256-cbc -salt -in "$src_file" -out "$dest_file" -k "$ENCRYPTION_KEY" -md sha256
  rm "$src_file"
  echo "Verschlüsselt: $src_file -> $dest_file"
}

# Backup MongoDB
echo "[$TIMESTAMP] Backing up MongoDB..."
mkdir -p "$BACKUP_DIR/mongodb"
docker exec mongodb mongodump --username admin --password "$MONGO_PASSWORD" --out /tmp/backup
docker cp mongodb:/tmp/backup "$BACKUP_DIR/mongodb"
docker exec mongodb rm -rf /tmp/backup
tar -czf "$BACKUP_DIR/mongodb_$TIMESTAMP.tar.gz" -C "$BACKUP_DIR" mongodb
rm -rf "$BACKUP_DIR/mongodb"
encrypt_backup "$BACKUP_DIR/mongodb_$TIMESTAMP.tar.gz"

# Backup Redis
echo "[$TIMESTAMP] Backing up Redis..."
mkdir -p "$BACKUP_DIR/redis"
# Sicherstellen, dass Redis SAVE ausführt
docker exec redis redis-cli SAVE
docker cp redis:/data "$BACKUP_DIR/redis"
tar -czf "$BACKUP_DIR/redis_$TIMESTAMP.tar.gz" -C "$BACKUP_DIR" redis
rm -rf "$BACKUP_DIR/redis"
encrypt_backup "$BACKUP_DIR/redis_$TIMESTAMP.tar.gz"

# Backup Vault
echo "[$TIMESTAMP] Backing up Vault..."
mkdir -p "$BACKUP_DIR/vault"
docker cp vault:/vault/data "$BACKUP_DIR/vault"
tar -czf "$BACKUP_DIR/vault_$TIMESTAMP.tar.gz" -C "$BACKUP_DIR" vault
rm -rf "$BACKUP_DIR/vault"
encrypt_backup "$BACKUP_DIR/vault_$TIMESTAMP.tar.gz"

# Backup Qdrant
echo "[$TIMESTAMP] Backing up Qdrant..."
mkdir -p "$BACKUP_DIR/qdrant"
docker cp qdrant:/qdrant/storage "$BACKUP_DIR/qdrant"
tar -czf "$BACKUP_DIR/qdrant_$TIMESTAMP.tar.gz" -C "$BACKUP_DIR" qdrant
rm -rf "$BACKUP_DIR/qdrant"
encrypt_backup "$BACKUP_DIR/qdrant_$TIMESTAMP.tar.gz"

# Erstelle Backup-Manifest mit SHA256 Prüfsummen
echo "[$TIMESTAMP] Creating backup manifest..."
echo "Backup created on $(date)" > "$BACKUP_DIR/manifest.txt"
echo "Services: MongoDB, Redis, Vault, Qdrant" >> "$BACKUP_DIR/manifest.txt"
echo "" >> "$BACKUP_DIR/manifest.txt"
echo "Checksums:" >> "$BACKUP_DIR/manifest.txt"
for file in "$BACKUP_DIR"/*.enc; do
  CHECKSUM=$(sha256sum "$file" | cut -d' ' -f1)
  echo "$(basename "$file"): $CHECKSUM" >> "$BACKUP_DIR/manifest.txt"
done

# Manifest selbst verschlüsseln
encrypt_backup "$BACKUP_DIR/manifest.txt"

echo "[$TIMESTAMP] Backup completed successfully! Files stored in $BACKUP_DIR"

# Remote Backup zu S3 (falls konfiguriert)
if [ "$REMOTE_BACKUP" = "true" ] && [ ! -z "$S3_BUCKET" ]; then
  echo "[$TIMESTAMP] Uploading backup to S3 bucket $S3_BUCKET..."
  aws s3 sync "$BACKUP_DIR" "s3://$S3_BUCKET/$(basename "$BACKUP_DIR")/"
  echo "[$TIMESTAMP] S3 upload completed!"
fi
