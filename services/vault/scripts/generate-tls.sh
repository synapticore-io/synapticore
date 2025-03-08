#!/bin/bash
set -e

# Überprüfen, ob Zertifikate bereits existieren
if [ -f "/vault/tls/vault.crt" ] && [ -f "/vault/tls/vault.key" ]; then
  echo "TLS certificates already exist, skipping generation"
  exit 0
fi

# Verzeichnis für TLS-Zertifikate erstellen
mkdir -p /vault/tls

# Generiere selbstsigniertes Zertifikat für Vault
echo "Generating self-signed TLS certificate for Vault..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /vault/tls/vault.key -out /vault/tls/vault.crt \
  -subj "/CN=vault.local" \
  -addext "subjectAltName = DNS:vault.local,DNS:localhost,IP:127.0.0.1"

# Berechtigungen setzen
chmod 600 /vault/tls/vault.key
chmod 644 /vault/tls/vault.crt

echo "TLS certificate generation completed"
