#!/bin/bash
set -e

# Farben für die Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Keine Farbe

echo -e "${BLUE}Synapticore Services Patcher${NC}"
echo -e "Dieses Script korrigiert Konfigurationen und behebt Probleme in den Service-Definitionen.\n"

# Überprüfen ob docker und docker-compose installiert sind
echo -e "${BLUE}Prüfe Voraussetzungen...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker ist nicht installiert. Bitte zuerst Docker installieren.${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}docker-compose nicht gefunden, prüfe auf Docker Compose Plugin...${NC}"
    if ! docker compose version &> /dev/null; then
        echo -e "${RED}Docker Compose nicht gefunden. Bitte zuerst Docker Compose installieren.${NC}"
        exit 1
    else
        DOCKER_COMPOSE="docker compose"
    fi
else
    DOCKER_COMPOSE="docker-compose"
fi

# Prüfe ob wir im richtigen Verzeichnis sind
if [ ! -d "services" ]; then
    echo -e "${YELLOW}Das services Verzeichnis wurde nicht gefunden.${NC}"
    
    if [ -d "../services" ]; then
        echo -e "Wechsle zum übergeordneten Verzeichnis..."
        cd ..
    fi
    
    if [ ! -d "services" ]; then
        echo -e "${RED}Das services Verzeichnis wurde nicht gefunden. Bitte führe das Script im richtigen Verzeichnis aus.${NC}"
        exit 1
    fi
fi

# Erstelle docker-compose.yml falls noch nicht vorhanden
echo -e "${BLUE}Erstelle docker-compose.yml...${NC}"
cat > docker-compose.yml << 'EOF'
version: '3.8'

networks:
  synapticore-network:
    driver: bridge

volumes:
  vault_data:
  vault_logs:
  vault_tls:
  vault_transit_data:
  vault_transit_logs:
  vault_transit_tls:
  redis_data:
  mongodb_data:
  mongodb_configdb:
  mongodb_logs:
  qdrant_storage:
  qdrant_tls:
  prometheus_data:
  backup_data:
  backup_storage:

services:
  # Vault für Secret Management
  vault:
    build:
      context: ./services/vault
    container_name: vault
    ports:
      - "8200:8200"
      - "8201:8201"
    volumes:
      - vault_data:/vault/data
      - vault_logs:/vault/logs
      - vault_tls:/vault/tls
    cap_add:
      - IPC_LOCK
    environment:
      - VAULT_ADDR=https://127.0.0.1:8200
      - VAULT_API_ADDR=https://0.0.0.0:8200
    networks:
      - synapticore-network
    healthcheck:
      test: ["CMD", "curl", "-f", "-k", "https://127.0.0.1:8200/v1/sys/health"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  # Vault Transit für Verschlüsselungsoperationen
  vault-transit:
    build:
      context: ./services/vault
    container_name: vault-transit
    ports:
      - "8210:8200"
    volumes:
      - vault_transit_data:/vault/data
      - vault_transit_logs:/vault/logs
      - vault_transit_tls:/vault/tls
    cap_add:
      - IPC_LOCK
    environment:
      - VAULT_ADDR=https://127.0.0.1:8200
      - VAULT_API_ADDR=https://0.0.0.0:8200
      - VAULT_TRANSIT_SERVER=true
    networks:
      - synapticore-network
    healthcheck:
      test: ["CMD", "curl", "-f", "-k", "https://127.0.0.1:8200/v1/sys/health"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  # Redis für Caching
  redis:
    build:
      context: ./services/redis
    container_name: redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    environment:
      - VAULT_ADDR=https://vault:8200
      - VAULT_SKIP_VERIFY=true
    networks:
      - synapticore-network
    depends_on:
      - vault
    restart: unless-stopped

  # MongoDB für persistente Daten
  mongodb:
    build:
      context: ./services/mongodb
    container_name: mongodb
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db
      - mongodb_configdb:/data/configdb
      - mongodb_logs:/var/log/mongodb
    networks:
      - synapticore-network
    restart: unless-stopped

  # Qdrant für Vektorsuche
  qdrant:
    build:
      context: ./services/qdrant
    container_name: qdrant
    ports:
      - "6333:6333"
      - "6334:6334"
    volumes:
      - qdrant_storage:/qdrant/storage
      - qdrant_tls:/qdrant/tls
    environment:
      - QDRANT_ALLOW_RECOVERY_MODE=true
    networks:
      - synapticore-network
    restart: unless-stopped

  # Prometheus für Monitoring
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./services/prometheus/config:/etc/prometheus
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'
    networks:
      - synapticore-network
    restart: unless-stopped

  # Backup Manager für automatisierte Backups
  backup-manager:
    build:
      context: ./services/backup-manager
    container_name: backup-manager
    volumes:
      - backup_data:/backup-data
      - backup_storage:/backup
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - VAULT_ADDR=https://vault:8200
      - VAULT_SKIP_VERIFY=true
      - BACKUP_RETENTION_DAYS=14
      - RUN_INITIAL_BACKUP=false
      - REMOTE_BACKUP=false
    networks:
      - synapticore-network
    depends_on:
      - vault
      - redis
      - mongodb
      - qdrant
    restart: unless-stopped
EOF

# Erstelle notwendige Verzeichnisse
echo -e "${BLUE}Erstelle notwendige Verzeichnisse...${NC}"
mkdir -p logs

# Korrigiere Qdrant config.yaml
echo -e "${BLUE}Korrigiere Qdrant Konfiguration...${NC}"
cat > services/qdrant/config/config.yaml << 'EOF'
storage:
  # Storage persistence path
  storage_path: /qdrant/storage

service:
  # Host to bind the REST and gRPC APIs
  host: 0.0.0.0
  # Port to bind the REST API
  http_port: 6333
  # Port to bind the gRPC API
  grpc_port: 6334
  
  # Enable HTTPS mode for REST API (deaktiviert für einfachere Tests)
  enable_tls: false
  # Path to TLS certificate file
  tls_cert_path: /qdrant/tls/qdrant.crt
  # Path to TLS private key file
  tls_key_path: /qdrant/tls/qdrant.key
  
  # Enable TLS for gRPC API
  grpc_enable_tls: false
  # Path to TLS certificate file for gRPC
  grpc_tls_cert_path: /qdrant/tls/qdrant.crt
  # Path to TLS private key file for gRPC
  grpc_tls_key_path: /qdrant/tls/qdrant.key

optimizers:
  # Default optimization settings for the vector index building
  default_segment_number: 2
  memmap_threshold: 10000
  indexing_threshold: 20000
  max_segment_size: 100000

# Default performance settings
performance:
  # Performance optimization params
  max_search_threads: 0
  parallel_indices_creation: true

telemetry:
  # Whether to report anonymous telemetry to Qdrant team
  enabled: false
EOF

# Patch für den Vault init-vault.sh script, um sicherzustellen, dass er auch in Docker läuft
echo -e "${BLUE}Patche Vault init-script...${NC}"
cat > patch-vault-init.tmp << 'EOF'
#!/bin/bash
set -e

export VAULT_ADDR="https://127.0.0.1:8200"
export VAULT_SKIP_VERIFY="true"

# Warten, bis Vault bereit ist
echo "Waiting for Vault to start..."
until curl -s -k $VAULT_ADDR/v1/sys/health > /dev/null 2>&1; do
  echo "Waiting for Vault to become available..."
  sleep 1
done

# Check if Vault is initialized
initialized=$(curl -s -k $VAULT_ADDR/v1/sys/init | jq -r '.initialized')

if [ "$initialized" = "false" ]; then
  echo "Initializing Vault..."
  
  # Initialize Vault with 1 key share and 1 key threshold (for development/testing)
  INIT_RESPONSE=$(curl -s -k -X PUT -d '{"secret_shares": 1, "secret_threshold": 1}' $VAULT_ADDR/v1/sys/init)
  
  # Extract keys and token
  UNSEAL_KEY=$(echo $INIT_RESPONSE | jq -r .keys[0])
  ROOT_TOKEN=$(echo $INIT_RESPONSE | jq -r .root_token)
  
  # Save keys and token to files for later use
  echo $UNSEAL_KEY > /vault/data/unseal_key.txt
  echo $ROOT_TOKEN > /vault/data/root_token.txt
  
  # Set permissions
  chmod 600 /vault/data/unseal_key.txt /vault/data/root_token.txt
  
  echo "Vault initialized!"
else
  echo "Vault already initialized"
  
  # Ensure we have the root token file
  if [ ! -f /vault/data/root_token.txt ] && [ ! -f /vault/data/unseal_key.txt ]; then
    echo "Warning: Vault is initialized but no token files found. This may be a problem."
  fi
fi

# Check if Vault is sealed
sealed=$(curl -s -k $VAULT_ADDR/v1/sys/seal-status | jq -r '.sealed')

if [ "$sealed" = "true" ]; then
  echo "Unsealing Vault..."
  
  # Get unseal key
  if [ -f /vault/data/unseal_key.txt ]; then
    UNSEAL_KEY=$(cat /vault/data/unseal_key.txt)
    curl -s -k -X PUT -d "{\"key\": \"$UNSEAL_KEY\"}" $VAULT_ADDR/v1/sys/unseal
    echo "Vault unsealed!"
  else
    echo "Unseal key not found"
    exit 1
  fi
else
  echo "Vault already unsealed"
fi

# Get root token
if [ ! -f /vault/data/root_token.txt ]; then
  echo "Root token not found. Cannot setup secrets."
  exit 1
fi

ROOT_TOKEN=$(cat /vault/data/root_token.txt)
export VAULT_TOKEN="$ROOT_TOKEN"

echo "Setting up initial secrets..."

# Enable KV secrets engine version 2 if not already enabled
SECRETS_ENABLED=$(curl -s -k -H "X-Vault-Token: $ROOT_TOKEN" $VAULT_ADDR/v1/sys/mounts | grep -c '"secret/"' || echo "0")
if [ "$SECRETS_ENABLED" = "0" ]; then
  echo "Enabling KV secrets engine..."
  curl -s -k -X POST -H "X-Vault-Token: $ROOT_TOKEN" -d '{"type":"kv","options":{"version":"2"}}' $VAULT_ADDR/v1/sys/mounts/secret
fi

# Enable Transit Secret Engine for encryption operations if not already enabled
TRANSIT_ENABLED=$(curl -s -k -H "X-Vault-Token: $ROOT_TOKEN" $VAULT_ADDR/v1/sys/mounts | grep -c '"transit/"' || echo "0")
if [ "$TRANSIT_ENABLED" = "0" ]; then
  echo "Enabling Transit Secret Engine..."
  curl -s -k -X POST -H "X-Vault-Token: $ROOT_TOKEN" -d '{"type":"transit"}' $VAULT_ADDR/v1/sys/mounts/transit
  
  # Create encryption key for general use
  curl -s -k -X POST -H "X-Vault-Token: $ROOT_TOKEN" -d '{}' $VAULT_ADDR/v1/transit/keys/synapticore-key
  
  echo "Transit Secret Engine enabled!"
fi

# Initialize secrets with vault cli
# Note: We use the HTTP API directly for the initial checks above, but switch to the vault CLI 
# for convenience when creating secrets

# Generate random passwords if they don't exist in Vault
if ! vault kv get -format=json secret/mongodb &>/dev/null; then
  echo "Creating MongoDB credentials in Vault..."
  MONGO_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16)
  vault kv put secret/mongodb username=admin password="$MONGO_PASSWORD"
fi

if ! vault kv get -format=json secret/redis &>/dev/null; then
  echo "Creating Redis password in Vault..."
  REDIS_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16)
  vault kv put secret/redis password="$REDIS_PASSWORD"
fi

if ! vault kv get -format=json secret/backup &>/dev/null; then
  echo "Creating backup encryption key in Vault..."
  BACKUP_KEY=$(openssl rand -base64 32)
  vault kv put secret/backup encryption_key="$BACKUP_KEY"
fi

echo "Initial secrets setup completed!"
EOF

mv patch-vault-init.tmp services/vault/scripts/init-vault.sh
chmod +x services/vault/scripts/init-vault.sh

# Aktualisiere die Vault config.hcl, um TLS zunächst zu deaktivieren
echo -e "${BLUE}Aktualisiere Vault config.hcl für einfachere Tests...${NC}"
cat > services/vault/config/config.hcl << 'EOF'
ui = true
disable_mlock = true

# Storage-Konfiguration
storage "raft" {
  path = "/vault/data"
  node_id = "vault_1"
}

# Listener-Konfiguration, TLS für einfachere Tests zunächst deaktiviert
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

api_addr = "http://0.0.0.0:8200"
cluster_addr = "http://0.0.0.0:8201"

# Performance und Stabilität
default_lease_ttl = "768h"
max_lease_ttl = "768h"

# Telemetrie
telemetry {
  prometheus_retention_time = "24h"
  disable_hostname = true
}

# Log Konfiguration
log_level = "info"
log_format = "json"
EOF

# Korrigiere Vault startup.sh
echo -e "${BLUE}Korrigiere Vault startup.sh...${NC}"
cat > services/vault/scripts/startup.sh << 'EOF'
#!/bin/bash
set -e

# Transit-Server Konfiguration überschreiben falls aktiviert
if [ "${VAULT_TRANSIT_SERVER:-false}" = "true" ]; then
  echo "Konfiguriere als Transit-Server..."
  cat > /vault/config/config.hcl << 'EOT'
ui = true
disable_mlock = true

storage "raft" {
  path = "/vault/data"
  node_id = "vault_transit_1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

api_addr = "http://0.0.0.0:8200"
cluster_addr = "http://0.0.0.0:8201"

default_lease_ttl = "768h"
max_lease_ttl = "768h"

telemetry {
  prometheus_retention_time = "24h"
  disable_hostname = true
}

log_level = "info"
log_format = "json"
EOT
fi

# TLS-Zertifikate generieren wenn benötigt
if grep -q "tls_disable = 0" /vault/config/config.hcl; then
  echo "TLS aktiviert, generiere Zertifikate..."
  /vault/generate-tls.sh
fi

# Vault-Daten zurücksetzen, falls erforderlich
/vault/reset-vault.sh

# Vault-Server im Hintergrund starten
echo "Starting Vault server..."
/bin/vault server -config=/vault/config/config.hcl > /vault/logs/vault.log 2>&1 &
VAULT_PID=$!

# Warten, bis Vault bereit ist
echo "Waiting for Vault to start..."
MAX_RETRIES=30
RETRY_COUNT=0

while ! curl -s -k ${VAULT_ADDR:-http://127.0.0.1:8200}/v1/sys/health > /dev/null 2>&1; do
  echo "Waiting for Vault to become available... (Attempt $((RETRY_COUNT+1))/$MAX_RETRIES)"
  sleep 2
  
  # Überprüfen, ob der Vault-Prozess noch läuft
  if ! ps -p $VAULT_PID > /dev/null; then
    echo "Vault server process died. Checking logs:"
    tail -n 20 /vault/logs/vault.log || true
    
    # Wenn wir das maximale Limit erreicht haben, beenden wir mit einem Fehler
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
      echo "Maximum retry attempts reached. Vault server failed to start."
      exit 1
    fi
    
    echo "Restarting Vault server..."
    /bin/vault server -config=/vault/config/config.hcl > /vault/logs/vault.log 2>&1 &
    VAULT_PID=$!
  fi
  
  RETRY_COUNT=$((RETRY_COUNT+1))
  
  # Wenn wir das maximale Limit erreicht haben, beenden wir mit einem Fehler
  if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "Maximum retry attempts reached. Vault server failed to start."
    exit 1
  fi
done

# Vault initialisieren und entsperren
echo "Vault server is running. Initializing and unsealing..."
/vault/init-vault.sh

# Auf den Vault-Prozess warten
echo "Vault setup completed. Waiting for Vault server process..."
wait $VAULT_PID
EOF

chmod +x services/vault/scripts/startup.sh

# Korrigiere Redis startup.sh
echo -e "${BLUE}Korrigiere Redis startup.sh...${NC}"
cat > services/redis/scripts/startup.sh << 'EOF'
#!/bin/sh
set -e

# Default password (will be overridden if we can get from Vault)
REDIS_PASSWORD="synapticore-redis"

# Try to get password from Vault
if [ -n "$VAULT_ADDR" ]; then
  echo "Attempting to retrieve Redis password from Vault..."
  
  # Wait for Vault to be ready
  RETRY_COUNT=0
  MAX_RETRIES=30
  
  while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    HEALTH_CHECK=$(curl -s -k "${VAULT_ADDR}/v1/sys/health" || echo '{"sealed":true}')
    IS_SEALED=$(echo $HEALTH_CHECK | grep -c '"sealed":false' || echo "0")
    IS_INIT=$(echo $HEALTH_CHECK | grep -c '"initialized":true' || echo "0")
    
    if [ "$IS_SEALED" = "1" ] && [ "$IS_INIT" = "1" ]; then
      echo "Vault is unsealed and ready"
      break
    fi
    
    echo "Waiting for Vault to be unsealed... Attempt $((RETRY_COUNT+1)) of $MAX_RETRIES"
    RETRY_COUNT=$((RETRY_COUNT+1))
    sleep 2
  done
  
  if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
    # Try to get Vault token
    ROOT_TOKEN=$(cat /tmp/vault_token.txt 2>/dev/null || docker exec vault cat /vault/data/root_token.txt 2>/dev/null || echo "")
    
    if [ -n "$ROOT_TOKEN" ]; then
      echo "Using root token to access Vault"
      
      # Get password from Vault
      VAULT_RESPONSE=$(curl -s -k -H "X-Vault-Token: ${ROOT_TOKEN}" \
        "${VAULT_ADDR}/v1/secret/data/redis" || echo '{"data":{"data":{"password":""}}}')
      
      PASSWORD=$(echo $VAULT_RESPONSE | grep -o '"password":"[^"]*"' | sed 's/"password":"//;s/"//')
      
      if [ -n "$PASSWORD" ]; then
        echo "Successfully retrieved Redis password from Vault"
        REDIS_PASSWORD="$PASSWORD"
      else
        echo "Failed to retrieve password from Vault, using default"
      fi
    else
      echo "No Vault token available, using default password"
    fi
  else
    echo "Vault not ready after $MAX_RETRIES attempts, using default password"
  fi
else
  echo "VAULT_ADDR not set, using default password"
fi

# Create Redis configuration
sed "s/REDIS_PASSWORD_PLACEHOLDER/$REDIS_PASSWORD/g" /usr/local/etc/redis/redis.conf.template > /usr/local/etc/redis/redis.conf

# Start Redis server
exec redis-server /usr/local/etc/redis/redis.conf
EOF

chmod +x services/redis/scripts/startup.sh

# Erstelle einen MongoDB init script
echo -e "${BLUE}Erstelle MongoDB init script...${NC}"
mkdir -p services/mongodb/scripts

cat > services/mongodb/scripts/init-mongodb.sh << 'EOF'
#!/bin/bash
set -e

echo "Initializing MongoDB with admin user..."

# Check if MongoDB is already initialized
if [ -f /data/db/.mongodb_initialized ]; then
  echo "MongoDB already initialized. Skipping setup."
  exit 0
fi

# Wait for MongoDB to start
until mongo --eval "db.stats()" &>/dev/null; do
  echo "Waiting for MongoDB to start..."
  sleep 2
done

# Default admin password
MONGO_ADMIN_PASSWORD="admin"

# Try to get password from Vault if environment variable is set
if [ -n "$VAULT_ADDR" ]; then
  echo "Attempting to retrieve MongoDB password from Vault..."
  
  # Get root token from Vault container
  ROOT_TOKEN=$(curl -s -k ${VAULT_ADDR}/v1/sys/health >/dev/null && \
    docker exec vault cat /vault/data/root_token.txt 2>/dev/null || echo "")
  
  if [ -n "$ROOT_TOKEN" ]; then
    # Get MongoDB password from Vault
    VAULT_RESPONSE=$(curl -s -k -H "X-Vault-Token: ${ROOT_TOKEN}" \
      "${VAULT_ADDR}/v1/secret/data/mongodb" || echo '{"data":{"data":{}}}')
    
    PASSWORD=$(echo $VAULT_RESPONSE | grep -o '"password":"[^"]*"' | cut -d':' -f2 | tr -d '"')
    
    if [ -n "$PASSWORD" ]; then
      echo "Successfully retrieved MongoDB password from Vault"
      MONGO_ADMIN_PASSWORD="$PASSWORD"
    else
      echo "Failed to retrieve password from Vault, using default"
    fi
  else
    echo "Could not retrieve Vault token, using default password"
  fi
else
  echo "VAULT_ADDR not set, using default password"
fi

# Create admin user
mongo admin --eval "db.createUser({user: 'admin', pwd: '$MONGO_ADMIN_PASSWORD', roles: [{role: 'root', db: 'admin'}]})"

# Create initialization flag
touch /data/db/.mongodb_initialized

echo "MongoDB initialization completed!"
EOF

chmod +x services/mongodb/scripts/init-mongodb.sh

# Aktualisiere MongoDB Dockerfile
echo -e "${BLUE}Aktualisiere MongoDB Dockerfile...${NC}"
cat > services/mongodb/Dockerfile << 'EOF'
FROM mongo:6.0

VOLUME /data/db
VOLUME /data/configdb
VOLUME /var/log/mongodb

EXPOSE 27017

COPY config/mongod.conf /etc/mongod.conf
COPY scripts/init-mongodb.sh /docker-entrypoint-initdb.d/

CMD ["mongod", "--config", "/etc/mongod.conf"]
EOF

# Aktualisiere den Backup-Manager script
echo -e "${BLUE}Korrigiere Backup-Manager Skripte...${NC}"
cat > services/backup-manager/scripts/backup.sh << 'EOF'
#!/bin/bash
set -e

# Configuration
BACKUP_DIR="/backup/$(date +%Y%m%d_%H%M%S)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Get secrets either from Vault or local files
get_secrets() {
  if [ "${USE_VAULT_SECRETS:-false}" = "true" ]; then
    echo "Getting secrets from Vault..."
    
    # Try to get Vault token
    if [ -z "$VAULT_TOKEN" ]; then
      ROOT_TOKEN=$(docker exec vault cat /vault/data/root_token.txt 2>/dev/null || echo "")
      if [ -n "$ROOT_TOKEN" ]; then
        export VAULT_TOKEN="$ROOT_TOKEN"
      fi
    fi
    
    # Get MongoDB password
    MONGO_SECRET=$(curl -s -k -H "X-Vault-Token: ${VAULT_TOKEN:-root}" \
      "${VAULT_ADDR}/v1/secret/data/mongodb" || echo '{"data":{"data":{}}}')
    MONGO_PASSWORD=$(echo $MONGO_SECRET | grep -o '"password":"[^"]*"' | cut -d':' -f2 | tr -d '"')
    
    # Get Redis password
    REDIS_SECRET=$(curl -s -k -H "X-Vault-Token: ${VAULT_TOKEN:-root}" \
      "${VAULT_ADDR}/v1/secret/data/redis" || echo '{"data":{"data":{}}}')
    REDIS_PASSWORD=$(echo $REDIS_SECRET | grep -o '"password":"[^"]*"' | cut -d':' -f2 | tr -d '"')
    
    # Get backup encryption key
    BACKUP_SECRET=$(curl -s -k -H "X-Vault-Token: ${VAULT_TOKEN:-root}" \
      "${VAULT_ADDR}/v1/secret/data/backup" || echo '{"data":{"data":{}}}')
    ENCRYPTION_KEY=$(echo $BACKUP_SECRET | grep -o '"encryption_key":"[^"]*"' | cut -d':' -f2 | tr -d '"')
    
    # Fallback if empty
    MONGO_PASSWORD=${MONGO_PASSWORD:-admin}
    REDIS_PASSWORD=${REDIS_PASSWORD:-changeme}
    ENCRYPTION_KEY=${ENCRYPTION_KEY:-"backup-encryption-key"}
  else
    echo "Using local secrets..."
    
    # Use environment variables or fallback to defaults
    ENCRYPTION_KEY=$(cat "${ENCRYPTION_KEY_FILE:-/backup-data/backup_encryption_key.txt}" 2>/dev/null || echo "defaultkey")
    MONGO_PASSWORD="admin"  # Default if not found
    REDIS_PASSWORD=""       # Default if not found
  fi
}

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Get secrets
get_secrets

# Function to encrypt backup files
encrypt_backup() {
  local src_file=$1
  local dest_file="${src_file}.enc"
  
  openssl enc -aes-256-cbc -salt -in "$src_file" -out "$dest_file" -k "$ENCRYPTION_KEY" -md sha256
  rm "$src_file"
  echo "Encrypted: $src_file -> $dest_file"
}

# Check if container exists
container_exists() {
  docker ps -q -f name="^/$1$" | grep -q .
}

# Backup MongoDB if it exists
echo "[$TIMESTAMP] Backing up MongoDB..."
if container_exists "mongodb"; then
  mkdir -p "$BACKUP_DIR/mongodb"
  
  # Check if authentication is needed
  if docker exec mongodb mongo --eval "db.stats()" &>/dev/null; then
    docker exec mongodb mongodump --out /tmp/backup
  else
    docker exec mongodb mongodump --username admin --password "$MONGO_PASSWORD" --out /tmp/backup
  fi
  
  docker cp mongodb:/tmp/backup "$BACKUP_DIR/mongodb"
  docker exec mongodb rm -rf /tmp/backup
  tar -czf "$BACKUP_DIR/mongodb_$TIMESTAMP.tar.gz" -C "$BACKUP_DIR" mongodb
  rm -rf "$BACKUP_DIR/mongodb"
  encrypt_backup "$BACKUP_DIR/mongodb_$TIMESTAMP.tar.gz"
else
  echo "[$TIMESTAMP] MongoDB container not found, skipping backup."
fi

# Backup Redis if it exists
echo "[$TIMESTAMP] Backing up Redis..."
if container_exists "redis"; then
  mkdir -p "$BACKUP_DIR/redis"
  # Ensure Redis SAVE is executed
  if [ -n "$REDIS_PASSWORD" ]; then
    docker exec redis redis-cli -a "$REDIS_PASSWORD" SAVE
  else
    docker exec redis redis-cli SAVE
  fi
  docker cp redis:/data "$BACKUP_DIR/redis"
  tar -czf "$BACKUP_DIR/redis_$TIMESTAMP.tar.gz" -C "$BACKUP_DIR" redis
  rm -rf "$BACKUP_DIR/redis"
  encrypt_backup "$BACKUP_DIR/redis_$TIMESTAMP.tar.gz"
else
  echo "[$TIMESTAMP] Redis container not found, skipping backup."
fi

# Backup Vault if it exists
echo "[$TIMESTAMP] Backing up Vault..."
if container_exists "vault"; then
  mkdir -p "$BACKUP_DIR/vault"
  docker cp vault:/vault/data "$BACKUP_DIR/vault"
  tar -czf "$BACKUP_DIR/vault_$TIMESTAMP.tar.gz" -C "$BACKUP_DIR" vault
  rm -rf "$BACKUP_DIR/vault"
  encrypt_backup "$BACKUP_DIR/vault_$TIMESTAMP.tar.gz"
else
  echo "[$TIMESTAMP] Vault container not found, skipping backup."
fi

# Backup Qdrant if it exists
echo "[$TIMESTAMP] Backing up Qdrant..."
if container_exists "qdrant"; then
  mkdir -p "$BACKUP_DIR/qdrant"
  docker cp qdrant:/qdrant/storage "$BACKUP_DIR/qdrant"
  tar -czf "$BACKUP_DIR/qdrant_$TIMESTAMP.tar.gz" -C "$BACKUP_DIR" qdrant
  rm -rf "$BACKUP_DIR/qdrant"
  encrypt_backup "$BACKUP_DIR/qdrant_$TIMESTAMP.tar.gz"
else
  echo "[$TIMESTAMP] Qdrant container not found, skipping backup."
fi

# Create backup manifest with SHA256 checksums
echo "[$TIMESTAMP] Creating backup manifest..."
echo "Backup created on $(date)" > "$BACKUP_DIR/manifest.txt"
echo "Services: MongoDB, Redis, Vault, Qdrant" >> "$BACKUP_DIR/manifest.txt"
echo "" >> "$BACKUP_DIR/manifest.txt"
echo "Checksums:" >> "$BACKUP_DIR/manifest.txt"
for file in "$BACKUP_DIR"/*.enc; do
  if [ -f "$file" ]; then
    CHECKSUM=$(sha256sum "$file" | cut -d' ' -f1)
    echo "$(basename "$file"): $CHECKSUM" >> "$BACKUP_DIR/manifest.txt"
  fi
done

# Encrypt the manifest itself
encrypt_backup "$BACKUP_DIR/manifest.txt"

echo "[$TIMESTAMP] Backup completed successfully! Files stored in $BACKUP_DIR"

# Remote Backup to S3 (if configured)
if [ "$REMOTE_BACKUP" = "true" ] && [ -n "$S3_BUCKET" ]; then
  echo "[$TIMESTAMP] Uploading backup to S3 bucket $S3_BUCKET..."
  aws s3 sync "$BACKUP_DIR" "s3://$S3_BUCKET/$(basename "$BACKUP_DIR")/"
  echo "[$TIMESTAMP] S3 upload completed!"
fi