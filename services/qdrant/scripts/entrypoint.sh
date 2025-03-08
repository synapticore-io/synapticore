#!/bin/bash
set -e

# Generate TLS certificates if needed
/qdrant/generate-tls.sh

# Start Qdrant with the specified config
exec ./qdrant --config-path /qdrant/config/config.yaml
