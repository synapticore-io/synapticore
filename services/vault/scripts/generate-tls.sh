#!/bin/bash
set -e

# Generate TLS certificates for Vault if they don't exist
if [ ! -f "/vault/tls/vault.crt" ] || [ ! -f "/vault/tls/vault.key" ]; then
  echo "Generating self-signed TLS certificate for Vault..."
  
  # Generate private key
  openssl genrsa -out "/vault/tls/vault.key" 2048
  chmod 600 "/vault/tls/vault.key"
  
  # Create configuration for the certificate
  cat > "/vault/tls/openssl.cnf" << EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req

[dn]
C = DE
ST = Berlin
L = Berlin
O = SynaptiCore
OU = Development
CN = vault.local

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = vault
DNS.2 = localhost
IP.1 = 127.0.0.1
EOF

  # Generate certificate
  openssl req -new -key "/vault/tls/vault.key" -out "/vault/tls/vault.csr" -config "/vault/tls/openssl.cnf"
  openssl x509 -req -in "/vault/tls/vault.csr" -signkey "/vault/tls/vault.key" -out "/vault/tls/vault.crt" -days 3650 -extensions v3_req -extfile "/vault/tls/openssl.cnf"
  
  # Cleanup
  rm -f "/vault/tls/vault.csr" "/vault/tls/openssl.cnf"
  
  echo "TLS certificate generation completed"
else
  echo "TLS certificates already exist, skipping generation"
fi
