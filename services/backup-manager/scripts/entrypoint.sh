#!/bin/bash
set -e

# Set up directories
mkdir -p /backup
mkdir -p /backup-data

# Configuration for scripts
export VAULT_ADDR="${VAULT_ADDR:-https://vault:8200}"
export VAULT_SKIP_VERIFY="${VAULT_SKIP_VERIFY:-true}"

# Get encryption key from Vault if configured, or generate locally
if [ -n "$VAULT_ADDR" ]; then
  echo "Using Vault for secret management at $VAULT_ADDR"
  
  # Will try to fetch from Vault during backup operations
  export USE_VAULT_SECRETS="true"
else
  echo "Vault not configured, generating local encryption key"
  
  if [ ! -f /backup-data/backup_encryption_key.txt ]; then
    echo "Generating new backup encryption key..."
    openssl rand -base64 32 > /backup-data/backup_encryption_key.txt
    chmod 600 /backup-data/backup_encryption_key.txt
  fi
  
  export ENCRYPTION_KEY_FILE="/backup-data/backup_encryption_key.txt"
  export USE_VAULT_SECRETS="false"
fi

# Set up the cron jobs for regular backups
echo "Setting up backup cron job..."
echo "0 2 * * * /scripts/backup.sh > /backup-data/backup_\$(date +\%Y\%m\%d).log 2>&1" > /etc/crontabs/root
echo "0 3 * * * /scripts/cleanup.sh > /backup-data/cleanup_\$(date +\%Y\%m\%d).log 2>&1" >> /etc/crontabs/root
echo "0 4 * * 0 /scripts/backup_check.sh > /backup-data/backup_check_\$(date +\%Y\%m\%d).log 2>&1" >> /etc/crontabs/root

# Run an initial backup if requested
if [ "${RUN_INITIAL_BACKUP:-false}" = "true" ]; then
  echo "Running initial backup..."
  /scripts/backup.sh > /backup-data/initial_backup_$(date +%Y%m%d).log 2>&1
fi

# Start the cron daemon and keep the container alive
echo "Starting crond..."
crond -f -l 8
