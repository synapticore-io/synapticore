#!/bin/bash
set -e

# Encryption key generation if not exists
if [ ! -f /secrets/backup_encryption_key.txt ]; then
  echo "Generating new backup encryption key..."
  openssl rand -base64 32 > /secrets/backup_encryption_key.txt
  chmod 600 /secrets/backup_encryption_key.txt
fi

# Einrichten des Cron-Jobs für regelmäßige Backups
echo "Setting up backup cron job..."
echo "0 2 * * * /scripts/backup.sh > /backup-data/backup_$(date +\%Y\%m\%d).log 2>&1" > /etc/crontabs/root
echo "0 3 * * * /scripts/cleanup.sh > /backup-data/cleanup_$(date +\%Y\%m\%d).log 2>&1" >> /etc/crontabs/root
echo "0 4 * * 0 /scripts/backup_check.sh > /backup-data/backup_check_$(date +\%Y\%m\%d).log 2>&1" >> /etc/crontabs/root

# Starte den Cron-Daemon und halte den Container am Leben
echo "Starting crond..."
crond -f -l 8
