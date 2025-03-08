#!/bin/bash
set -e

# Konfiguration
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-14}

echo "[$TIMESTAMP] Cleaning up backups older than $RETENTION_DAYS days..."

# Identifiziere alte Backups
find /backup -type d -name "20*_*" -mtime +$RETENTION_DAYS | while read backup_dir; do
  echo "[$TIMESTAMP] Removing old backup: $backup_dir"
  rm -rf "$backup_dir"
done

echo "[$TIMESTAMP] Cleanup completed!"
