#!/bin/bash
set -e

# Configuration
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CHECK_DIR="/backup-data/check_$TIMESTAMP"
LATEST_BACKUP=$(find /backup -type d -name "20*_*" | sort | tail -n 1)

echo "[$TIMESTAMP] Performing integrity check on latest backup: $LATEST_BACKUP"

# Get encryption key from vault or file
if [ "${USE_VAULT_SECRETS:-false}" = "true" ]; then
  echo "Getting encryption key from Vault..."
  
  # Try to get Vault token from running Vault container
  if [ -z "$VAULT_TOKEN" ]; then
    ROOT_TOKEN=$(docker exec vault cat /vault/data/root_token.txt 2>/dev/null || echo "")
    if [ -n "$ROOT_TOKEN" ]; then
      export VAULT_TOKEN="$ROOT_TOKEN"
    fi
  fi
  
  # Get backup encryption key
  BACKUP_SECRET=$(curl -s -k -H "X-Vault-Token: ${VAULT_TOKEN:-root}" \
    "${VAULT_ADDR}/v1/secret/data/backup" || echo '{"data":{"data":{}}}')
  ENCRYPTION_KEY=$(echo $BACKUP_SECRET | grep -o '"encryption_key":"[^"]*"' | cut -d':' -f2 | tr -d '"')
  
  if [ -z "$ENCRYPTION_KEY" ]; then
    echo "[$TIMESTAMP] ERROR: Could not retrieve encryption key from Vault"
    exit 1
  fi
else
  ENCRYPTION_KEY=$(cat "${ENCRYPTION_KEY_FILE:-/backup-data/backup_encryption_key.txt}" 2>/dev/null)
  
  if [ -z "$ENCRYPTION_KEY" ]; then
    echo "[$TIMESTAMP] ERROR: Could not retrieve encryption key from file"
    exit 1
  fi
fi

# Create temporary directory for verification
mkdir -p "$CHECK_DIR"

# Check if manifest exists and can be decrypted correctly
if [ -f "$LATEST_BACKUP/manifest.txt.enc" ]; then
  echo "[$TIMESTAMP] Verifying manifest file..."
  
  # Try to decrypt the manifest
  if openssl enc -aes-256-cbc -d -salt -in "$LATEST_BACKUP/manifest.txt.enc" -out "$CHECK_DIR/manifest.txt" -k "$ENCRYPTION_KEY" -md sha256 2>/dev/null; then
    echo "[$TIMESTAMP] Manifest successfully decrypted."
    
    # Check checksums
    grep -A 100 "Checksums:" "$CHECK_DIR/manifest.txt" | grep -v "Checksums:" | while read line; do
      if [ -n "$line" ]; then
        FILENAME=$(echo "$line" | cut -d':' -f1 | tr -d ' ')
        EXPECTED_CHECKSUM=$(echo "$line" | cut -d':' -f2 | tr -d ' ')
        
        if [ -f "$LATEST_BACKUP/$FILENAME" ]; then
          ACTUAL_CHECKSUM=$(sha256sum "$LATEST_BACKUP/$FILENAME" | cut -d' ' -f1)
          
          if [ "$EXPECTED_CHECKSUM" = "$ACTUAL_CHECKSUM" ]; then
            echo "[$TIMESTAMP] Checksum OK: $FILENAME"
          else
            echo "[$TIMESTAMP] CHECKSUM ERROR: $FILENAME"
            echo "   Expected: $EXPECTED_CHECKSUM"
            echo "   Actual: $ACTUAL_CHECKSUM"
          fi
        else
          echo "[$TIMESTAMP] FILE MISSING: $FILENAME"
        fi
      fi
    done
  else
    echo "[$TIMESTAMP] ERROR: Failed to decrypt manifest file. Key may be incorrect."
  fi
else
  echo "[$TIMESTAMP] ERROR: Manifest file not found in backup."
fi

# Clean up
rm -rf "$CHECK_DIR"
echo "[$TIMESTAMP] Integrity check completed!"
