#!/bin/bash

# Backup-Skript für alle Services
backup_dir="/backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p $backup_dir

# Backup MongoDB
echo "Backing up MongoDB..."
docker exec mongodb mongodump --username admin --password $(cat services/secrets/mongo_root_password.txt) --out /tmp/backup
docker cp mongodb:/tmp/backup $backup_dir/mongodb
docker exec mongodb rm -rf /tmp/backup

# Backup Redis
echo "Backing up Redis..."
docker exec redis redis-cli save
docker cp redis:/data $backup_dir/redis

# Backup Vault
echo "Backing up Vault..."
docker cp vault:/vault/data $backup_dir/vault

# Backup Qdrant
echo "Backing up Qdrant..."
docker cp qdrant:/qdrant/storage $backup_dir/qdrant

echo "Backup completed! Files stored in $backup_dir"
