#!/bin/bash
set -e

# Konfiguration
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ENCRYPTION_KEY=$(cat $ENCRYPTION_KEY_FILE)
CHECK_DIR="/backup-data/check_$TIMESTAMP"
LATEST_BACKUP=$(find /backup -type d -name "20*_*" | sort | tail -n 1)

echo "[$TIMESTAMP] Performing integrity check on latest backup: $LATEST_BACKUP"

# Erstelle temporäres Verzeichnis für die Überprüfung
mkdir -p "$CHECK_DIR"

# Prüfe, ob Manifest existiert und korrekt entschlüsselt werden kann
if [ -f "$LATEST_BACKUP/manifest.txt.enc" ]; then
  echo "[$TIMESTAMP] Verifying manifest file..."
  
  # Versuche das Manifest zu entschlüsseln
  if openssl enc -aes-256-cbc -d -salt -in "$LATEST_BACKUP/manifest.txt.enc" -out "$CHECK_DIR/manifest.txt" -k "$ENCRYPTION_KEY" -md sha256 2>/dev/null; then
    echo "[$TIMESTAMP] Manifest successfully decrypted."
    
    # Prüfe Checksummen
    grep -A 100 "Checksums:" "$CHECK_DIR/manifest.txt" | grep -v "Checksums:" | while read line; do
      if [ ! -z "$line" ]; then
        FILENAME=$(echo "$line" | cut -d':' -f1)
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

# Aufräumen
rm -rf "$CHECK_DIR"
echo "[$TIMESTAMP] Integrity check completed!"
