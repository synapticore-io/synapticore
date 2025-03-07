# Docker Compose Services Setup Guide

The error messages indicate that your containers can't find their configuration files. Here's how to properly set up the directory structure and configuration files for each service.

## Project Structure

First, ensure your project has the following directory structure:

```
services/
├── docker-compose.yml
├── vault/
│   ├── Dockerfile
│   ├── config/
│   │   └── config.hcl
│   ├── data/
│   ├── logs/
│   └── logos/
├── redis/
│   ├── Dockerfile
│   ├── config/
│   │   └── redis.conf
│   ├── data/
│   └── logos/
├── qdrant/
│   ├── Dockerfile
│   ├── config/
│   │   └── config.yaml
│   ├── data/
│   └── logos/
└── mongodb/
    ├── Dockerfile
    ├── config/
    │   └── mongod.conf
    ├── data/
    └── logos/
```

## Service-Specific Configuration

### 1. Vault Configuration

Make sure the `config.hcl` file exists in the `vault/config/` directory with the following content:

```hcl
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
```

### 2. Redis Configuration

Ensure the `redis.conf` file exists in the `redis/config/` directory with the following content:

```
# Redis configuration file
bind 0.0.0.0
port 6379
protected-mode yes
dir /data
appendonly yes
```

### 3. Qdrant Configuration

Create the `config.yaml` file in the `qdrant/config/` directory with the following content:

```yaml
storage:
  storage_path: /qdrant/storage

service:
  host: 0.0.0.0
  http_port: 6333
  grpc_port: 6334

telemetry:
  disabled: false
```

### 4. MongoDB Configuration

Ensure the `mongod.conf` file exists in the `mongodb/config/` directory with the following content:

```yaml
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
```

## Folder Permissions

Make sure that all the directories have the correct permissions:

```bash
# Create required directories
mkdir -p services/vault/{data,logs,config,logos}
mkdir -p services/redis/{data,config,logos}
mkdir -p services/qdrant/{data,config,logos}
mkdir -p services/mongodb/{data,config,logos}

# Set permissions (if running on Linux/macOS)
chmod -R 755 services/
```

## Common Issues and Solutions

1. **File not found errors:** Ensure configuration files exist in the correct locations.
2. **Permission issues:** Make sure your directories have the appropriate permissions.
3. **Volume mount problems:** Check that the Docker Compose volume paths are correct.
4. **Container restarting:** Use `docker logs <container_name>` to view detailed error messages.

After making these changes, try running your Docker Compose setup again:

```bash
cd services
docker-compose down -v
docker-compose up -d
```
