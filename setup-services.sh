#!/bin/bash

# Variables
BASE_DIR="$(pwd)/services"
VAULT_VERSION="1.15.5"
REDIS_VERSION="7.0.5"
QDRANT_VERSION="v1.1.1"
MONGODB_VERSION="6.0"

# Functions

# Function: Create base directory structure
create_directory_structure() {
    echo "Creating directory structure..."
    mkdir -p "$BASE_DIR"/{vault,redis,qdrant,mongodb}/{data,config,logos}
    
    # Create specific subdirectories for each service
    mkdir -p "$BASE_DIR/vault/data"
    mkdir -p "$BASE_DIR/redis/data"
    mkdir -p "$BASE_DIR/qdrant/data"
    mkdir -p "$BASE_DIR/mongodb/data"
    
    echo "Directory structure created successfully!"
}

# Function: Download logos for services
download_logos() {
    echo "Downloading logos for services..."
    
    # Vault logo
    curl -s -o "$BASE_DIR/vault/logos/vault-logo.png" "https://www.datocms-assets.com/2885/1620155439-brandhcvaultverticalcolor.svg" || {
        echo "Error downloading Vault logo."
    }
    
    # Redis logo
    curl -s -o "$BASE_DIR/redis/logos/redis-logo.png" "https://redis.io/images/redis-logo.svg" || {
        echo "Error downloading Redis logo."
    }
    
    # Qdrant logo
    curl -s -o "$BASE_DIR/qdrant/logos/qdrant-logo.png" "https://qdrant.tech/images/logo.svg" || {
        echo "Error downloading Qdrant logo."
    }
    
    # MongoDB logo
    curl -s -o "$BASE_DIR/mongodb/logos/mongodb-logo.png" "https://www.mongodb.com/assets/images/global/leaf.svg" || {
        echo "Error downloading MongoDB logo."
    }
    
    echo "Logos downloaded successfully!"
}

# Function: Create Vault Dockerfile
create_vault_dockerfile() {
    echo "Creating Vault Dockerfile..."
    cat << EOF > "$BASE_DIR/vault/Dockerfile"
FROM alpine:3.17

ARG VAULT_VERSION=$VAULT_VERSION

RUN apk add --no-cache curl unzip libcap && \\
    curl -Lo /tmp/vault.zip https://releases.hashicorp.com/vault/\${VAULT_VERSION}/vault_\${VAULT_VERSION}_linux_amd64.zip && \\
    unzip /tmp/vault.zip -d /bin && \\
    rm -f /tmp/vault.zip && \\
    setcap cap_ipc_lock=+ep /bin/vault

VOLUME /vault/data
VOLUME /vault/config
VOLUME /vault/logs

EXPOSE 8200

COPY ./config/config.hcl /vault/config/config.hcl

ENTRYPOINT ["vault", "server", "-config=/vault/config/config.hcl"]
EOF

    # Create Vault config
    cat << EOF > "$BASE_DIR/vault/config/config.hcl"
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
    
    echo "Vault Dockerfile created successfully!"
}

# Function: Create Redis Dockerfile
create_redis_dockerfile() {
    echo "Creating Redis Dockerfile..."
    cat << EOF > "$BASE_DIR/redis/Dockerfile"
FROM redis:$REDIS_VERSION

VOLUME /data

COPY ./config/redis.conf /usr/local/etc/redis/redis.conf

EXPOSE 6379

CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]
EOF

    # Create Redis config
    cat << EOF > "$BASE_DIR/redis/config/redis.conf"
# Redis configuration file
bind 0.0.0.0
port 6379
protected-mode yes
dir /data
appendonly yes
EOF
    
    echo "Redis Dockerfile created successfully!"
}

# Function: Create Qdrant Dockerfile
create_qdrant_dockerfile() {
    echo "Creating Qdrant Dockerfile..."
    cat << EOF > "$BASE_DIR/qdrant/Dockerfile"
FROM qdrant/qdrant:$QDRANT_VERSION

VOLUME /qdrant/storage
VOLUME /qdrant/config

EXPOSE 6333
EXPOSE 6334

COPY ./config/config.yaml /qdrant/config/config.yaml

CMD ["./qdrant", "--config-path", "/qdrant/config/config.yaml"]
EOF

    # Create Qdrant config
    cat << EOF > "$BASE_DIR/qdrant/config/config.yaml"
storage:
  storage_path: /qdrant/storage

service:
  host: 0.0.0.0
  http_port: 6333
  grpc_port: 6334

telemetry:
  disabled: false
EOF
    
    echo "Qdrant Dockerfile created successfully!"
}

# Function: Create MongoDB Dockerfile
create_mongodb_dockerfile() {
    echo "Creating MongoDB Dockerfile..."
    cat << EOF > "$BASE_DIR/mongodb/Dockerfile"
FROM mongo:$MONGODB_VERSION

VOLUME /data/db
VOLUME /data/configdb

EXPOSE 27017

COPY ./config/mongod.conf /etc/mongod.conf

CMD ["mongod", "--config", "/etc/mongod.conf"]
EOF

    # Create MongoDB config
    cat << EOF > "$BASE_DIR/mongodb/config/mongod.conf"
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
    
    echo "MongoDB Dockerfile created successfully!"
}

# Function: Create docker-compose.yml
create_docker_compose() {
    echo "Creating docker-compose.yml..."
    cat << EOF > "$BASE_DIR/docker-compose.yml"
version: '3.8'

services:
  vault:
    build: ./vault
    container_name: vault
    ports:
      - "8200:8200"
    volumes:
      - ./vault/data:/vault/data
      - ./vault/config:/vault/config
      - ./vault/logos:/vault/logos
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
      - ./redis/config:/usr/local/etc/redis
      - ./redis/logos:/redis/logos
    restart: unless-stopped

  qdrant:
    build: ./qdrant
    container_name: qdrant
    ports:
      - "6333:6333"
      - "6334:6334"
    volumes:
      - ./qdrant/data:/qdrant/storage
      - ./qdrant/config:/qdrant/config
      - ./qdrant/logos:/qdrant/logos
    restart: unless-stopped

  mongodb:
    build: ./mongodb
    container_name: mongodb
    ports:
      - "27017:27017"
    volumes:
      - ./mongodb/data:/data/db
      - ./mongodb/config:/data/configdb
      - ./mongodb/logos:/mongodb/logos
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=password
    restart: unless-stopped
EOF
    
    echo "docker-compose.yml created successfully!"
}

# Function: Create README.md
create_readme() {
    echo "Creating README.md..."
    cat << EOF > "$BASE_DIR/README.md"
# Service Setup

This directory contains the setup for the following services:

## Services

1. **Vault** - Secret management service
   - Port: 8200
   - Version: $VAULT_VERSION
   - Data directory: ./vault/data
   - Configuration: ./vault/config

2. **Redis** - In-memory data structure store
   - Port: 6379
   - Version: $REDIS_VERSION
   - Data directory: ./redis/data
   - Configuration: ./redis/config

3. **Qdrant** - Vector similarity search engine
   - Ports: 6333 (HTTP), 6334 (gRPC)
   - Version: $QDRANT_VERSION
   - Data directory: ./qdrant/data
   - Configuration: ./qdrant/config

4. **MongoDB** - NoSQL database
   - Port: 27017
   - Version: $MONGODB_VERSION
   - Data directory: ./mongodb/data
   - Configuration: ./mongodb/config

## Usage

To start all services:

```bash
cd services
docker-compose up -d
```

To start a specific service:

```bash
cd services
docker-compose up -d <service-name>
```

## Accessing Services

- Vault UI: http://localhost:8200
- Redis: redis-cli -h localhost -p 6379
- Qdrant REST API: http://localhost:6333
- MongoDB: mongodb://admin:password@localhost:27017
EOF
    
    echo "README.md created successfully!"
}

# Function: Set permissions
set_permissions() {
    echo "Setting permissions..."
    chmod -R 755 "$BASE_DIR"
    chmod -R 700 "$BASE_DIR"/{vault,redis,qdrant,mongodb}/data
    chmod -R 600 "$BASE_DIR"/{vault,redis,qdrant,mongodb}/config/*
    
    echo "Permissions set successfully!"
}

# Main function
main() {
    echo "Starting services setup..."
    create_directory_structure
    download_logos
    create_vault_dockerfile
    create_redis_dockerfile
    create_qdrant_dockerfile
    create_mongodb_dockerfile
    create_docker_compose
    create_readme
    set_permissions
    
    echo "Services setup completed successfully!"
    echo "You can now navigate to $BASE_DIR and run 'docker-compose up -d' to start all services."
}

# Run main function
main
