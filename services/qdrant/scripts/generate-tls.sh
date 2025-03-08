#!/bin/bash
set -e

# Check if certificates already exist
if [ -f "/qdrant/tls/qdrant.crt" ] && [ -f "/qdrant/tls/qdrant.key" ]; then
  echo "TLS certificates already exist, skipping generation"
  exit 0
fi

echo "Generating self-signed TLS certificates for Qdrant..."

# Create directory for certificates if it doesn't exist
mkdir -p /qdrant/tls

# Generate a private key
openssl genrsa -out /qdrant/tls/qdrant.key 2048
chmod 600 /qdrant/tls/qdrant.key

# Create a configuration file for the certificate
cat > /qdrant/tls/openssl.cnf << EOF
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
CN = qdrant.local

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = qdrant
DNS.2 = localhost
IP.1 = 127.0.0.1
EOF

# Generate a certificate signing request
openssl req -new -key /qdrant/tls/qdrant.key -out /qdrant/tls/qdrant.csr -config /qdrant/tls/openssl.cnf

# Generate a self-signed certificate
openssl x509 -req -in /qdrant/tls/qdrant.csr -signkey /qdrant/tls/qdrant.key -out /qdrant/tls/qdrant.crt -days 3650 -extensions v3_req -extfile /qdrant/tls/openssl.cnf

# Clean up
rm -f /qdrant/tls/qdrant.csr /qdrant/tls/openssl.cnf

echo "TLS certificate generation completed"
