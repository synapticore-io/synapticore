#!/bin/bash
# Script to fix the Docker Compose services setup
# This creates proper configuration files and updates the Docker Compose file

set -e  # Exit on any error

echo "Setting up services directory structure and configurations..."

# Create base directories for services
mkdir -p services

# ===================
# VAULT CONFIGURATION
# ===================
mkdir -p services/vault/{data,logs,config,logos}

# Create Vault configuration file
cat > services/vault/config/config.hcl << 'EOF'
ui = true
disable_mlock = true

storage "file" {
  path = "/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

api_addr = "http://0.0.0.0:8200"
cluster_addr = "http://0.0.0.0:8201"
EOF

# Create Vault Dockerfile
cat > services/vault/Dockerfile << 'EOF'
FROM alpine:3.17

ARG VAULT_VERSION=1.15.5

RUN apk add --no-cache curl unzip libcap && \
    curl -Lo /tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
    unzip /tmp/vault.zip -d /bin && \
    rm -f /tmp/vault.zip && \
    setcap cap_ipc_lock=+ep /bin/vault

VOLUME /vault/data
VOLUME /vault/config
VOLUME /vault/logs

EXPOSE 8200

COPY config/config.hcl /vault/config/config.hcl

ENTRYPOINT ["vault", "server", "-config=/vault/config/config.hcl"]
EOF

# ==================
# REDIS CONFIGURATION
# ==================
mkdir -p services/redis/{data,config,logos}

# Create Redis configuration file
cat > services/redis/config/redis.conf << 'EOF'
# Redis configuration file
bind 0.0.0.0
port 6379
protected-mode yes
dir /data
appendonly yes
EOF

# Create Redis Dockerfile
cat > services/redis/Dockerfile << 'EOF'
FROM redis:7.0.5

VOLUME /data

COPY config/redis.conf /usr/local/etc/redis/redis.conf

EXPOSE 6379

CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]
EOF

# ===================
# QDRANT CONFIGURATION
# ===================
mkdir -p services/qdrant/{data,config,logos}

# Create Qdrant configuration file
cat > services/qdrant/config/config.yaml << 'EOF'
storage:
  storage_path: /qdrant/storage

service:
  host: 0.0.0.0
  http_port: 6333
  grpc_port: 6334

telemetry:
  disabled: false
EOF

# Create Qdrant Dockerfile
cat > services/qdrant/Dockerfile << 'EOF'
FROM qdrant/qdrant:v1.1.1

VOLUME /qdrant/storage
VOLUME /qdrant/config

EXPOSE 6333
EXPOSE 6334

COPY config/config.yaml /qdrant/config/config.yaml

CMD ["./qdrant", "--config-path", "/qdrant/config/config.yaml"]
EOF

# ====================
# MONGODB CONFIGURATION
# ====================
mkdir -p services/mongodb/{data,config,logos}

# Create MongoDB configuration file
cat > services/mongodb/config/mongod.conf << 'EOF'
# MongoDB configuration file
storage:
  dbPath: /data/db
  journal:
    enabled: true

systemLog:
  destination: file
  path: /var/log/mongodb/mongod.log
  logAppend: true

net:
  port: 27017
  bindIp: 0.0.0.0

security:
  authorization: enabled
EOF

# Create MongoDB Dockerfile
cat > services/mongodb/Dockerfile << 'EOF'
FROM mongo:6.0

VOLUME /data/db
VOLUME /data/configdb

EXPOSE 27017

COPY config/mongod.conf /etc/mongod.conf

CMD ["mongod", "--config", "/etc/mongod.conf"]
EOF

# ===================
# DOCKER COMPOSE FILE
# ===================
cat > services/docker-compose.yml << 'EOF'
services:
  vault:
    build: ./vault
    container_name: vault
    ports:
      - "8200:8200"
    volumes:
      - ./vault/data:/vault/data
      - ./vault/logs:/vault/logs
    cap_add:
      - IPC_LOCK
    environment:
      - VAULT_ADDR=http://0.0.0.0:8200
    restart: unless-stopped

  redis:
    build: ./redis
    container_name: redis
    ports:
      - "6379:6379"
    volumes:
      - ./redis/data:/data
    restart: unless-stopped

  qdrant:
    build: ./qdrant
    container_name: qdrant
    ports:
      - "6333:6333"
      - "6334:6334"
    volumes:
      - ./qdrant/data:/qdrant/storage
    restart: unless-stopped

  mongodb:
    build: ./mongodb
    container_name: mongodb
    ports:
      - "27017:27017"
    volumes:
      - ./mongodb/data:/data/db
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=password
    restart: unless-stopped
EOF

# Set proper permissions
chmod -R 755 services

echo "Setup complete!"
echo "To start services, run: cd services && docker compose up -d --build"
