#!/bin/bash
set -e

# Farben für bessere Lesbarkeit
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Hilfsfunktion für Logging
log() {
  echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
  echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] FEHLER:${NC} $1"
}

success() {
  echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] ERFOLG:${NC} $1"
}

warning() {
  echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNUNG:${NC} $1"
}

# Prüfe Root-Rechte
if [ "$(id -u)" -ne 0 ]; then
  error "Dieses Skript muss mit Root-Rechten ausgeführt werden."
  exit 1
fi

# Basis-Verzeichnis
BASE_DIR="/workspaces/synapticore"
SERVICES_DIR="${BASE_DIR}/services"
SECRETS_DIR="${SERVICES_DIR}/secrets"
BACKUP_DIR="${SERVICES_DIR}/backup"
CERTS_DIR="${BASE_DIR}/certs"

# Erstelle Verzeichnisstruktur
create_directory_structure() {
  log "Erstelle Verzeichnisstruktur..."
  
  mkdir -p "${SERVICES_DIR}"
  mkdir -p "${SECRETS_DIR}"
  mkdir -p "${BACKUP_DIR}"
  mkdir -p "${CERTS_DIR}"
  chmod 700 "${SECRETS_DIR}"
  chmod 700 "${CERTS_DIR}"
  
  # Service-spezifische Verzeichnisse
  for service in vault redis mongodb qdrant prometheus grafana; do
    mkdir -p "${SERVICES_DIR}/${service}"
    mkdir -p "${SERVICES_DIR}/${service}/config"
    mkdir -p "${SERVICES_DIR}/${service}/data"
    
    if [ "${service}" == "mongodb" ]; then
      mkdir -p "${SERVICES_DIR}/${service}/logs"
    fi
    
    if [ "${service}" == "vault" ]; then
      mkdir -p "${SERVICES_DIR}/${service}/logs"
      mkdir -p "${SERVICES_DIR}/${service}/tls"
    fi
  done
  
  success "Verzeichnisstruktur erstellt."
}

# Generiere sichere Passwörter
generate_secure_passwords() {
  log "Generiere sichere Passwörter..."
  
  # Generiere Passwörter mit hoher Entropie
  MONGO_ROOT_PASSWORD=$(openssl rand -base64 32)
  REDIS_PASSWORD=$(openssl rand -base64 32)
  GRAFANA_ADMIN_PASSWORD=$(openssl rand -base64 24)
  
  # Speichere Passwörter in Secret-Dateien
  echo "${MONGO_ROOT_PASSWORD}" > "${SECRETS_DIR}/mongo_root_password.txt"
  echo "${REDIS_PASSWORD}" > "${SECRETS_DIR}/redis_password.txt"
  echo "${GRAFANA_ADMIN_PASSWORD}" > "${SECRETS_DIR}/grafana_admin_password.txt"
  
  # Setze strenge Berechtigungen für Secret-Dateien
  chmod 600 "${SECRETS_DIR}"/*.txt
  
  success "Sichere Passwörter generiert."
}

# Generiere TLS-Zertifikate für Vault
generate_tls_certificates() {
  log "Generiere TLS-Zertifikate für Vault..."
  
  # Erstelle CA
  openssl genrsa -out "${CERTS_DIR}/ca.key" 4096
  openssl req -x509 -new -nodes -key "${CERTS_DIR}/ca.key" -sha256 -days 1095 -out "${CERTS_DIR}/ca.crt" -subj "/CN=SecureInfrastructureCA"
  
  # Erstelle Vault Zertifikat
  openssl genrsa -out "${CERTS_DIR}/vault.key" 2048
  openssl req -new -key "${CERTS_DIR}/vault.key" -out "${CERTS_DIR}/vault.csr" -subj "/CN=vault"
  
  # Erstelle SAN-Erweiterung für mehrere Hostnamen
  cat > "${CERTS_DIR}/vault.ext" << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = vault
DNS.2 = localhost
IP.1 = 127.0.0.1
EOF
  
  # Signiere Zertifikat
  openssl x509 -req -in "${CERTS_DIR}/vault.csr" -CA "${CERTS_DIR}/ca.crt" -CAkey "${CERTS_DIR}/ca.key" -CAcreateserial -out "${CERTS_DIR}/vault.crt" -days 730 -sha256 -extfile "${CERTS_DIR}/vault.ext"
  
  # Kopiere Zertifikate für Vault
  cp "${CERTS_DIR}/vault.key" "${SERVICES_DIR}/vault/tls/vault.key"
  cp "${CERTS_DIR}/vault.crt" "${SERVICES_DIR}/vault/tls/vault.crt"
  cp "${CERTS_DIR}/ca.crt" "${SERVICES_DIR}/vault/tls/ca.crt"
  
  chmod 600 "${SERVICES_DIR}/vault/tls/vault.key"
  
  success "TLS-Zertifikate für Vault generiert."
}

# Erstelle verbesserte Docker Compose Konfiguration
create_docker_compose() {
  log "Erstelle verbesserte Docker Compose Konfiguration..."
  
  cat > "${BASE_DIR}/docker-compose.yml" << EOF
version: '3.8'

services:
  vault:
    build: ./services/vault
    container_name: vault
    ports:
      - "8200:8200"
      - "8201:8201"
    volumes:
      - ./services/vault/data:/vault/data
      - ./services/vault/logs:/vault/logs
      - ./services/vault/config:/vault/config
      - ./services/vault/tls:/vault/tls:ro
    cap_add:
      - IPC_LOCK
    environment:
      - VAULT_ADDR=https://0.0.0.0:8200
    restart: unless-stopped
    networks:
      - frontend
      - backend
    healthcheck:
      test: ["CMD", "wget", "--no-check-certificate", "-qO-", "https://localhost:8200/v1/sys/health"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 30s
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
      replicas: 1
      update_config:
        parallelism: 1
        delay: 60s

  redis:
    build: ./services/redis
    container_name: redis
    ports:
      - "6379:6379"
    volumes:
      - ./services/redis/data:/data
      - ./services/redis/config:/usr/local/etc/redis
    restart: unless-stopped
    networks:
      - backend
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "\${REDIS_PASSWORD}", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 1G
    secrets:
      - redis_password
    environment:
      - REDIS_PASSWORD_FILE=/run/secrets/redis_password

  qdrant:
    build: ./services/qdrant
    container_name: qdrant
    ports:
      - "6333:6333"
      - "6334:6334"
    volumes:
      - ./services/qdrant/data:/qdrant/storage
    restart: unless-stopped
    networks:
      - backend
      - frontend
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:6333/readiness"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 2G

  mongodb:
    build: ./services/mongodb
    container_name: mongodb
    ports:
      - "27017:27017"
    volumes:
      - ./services/mongodb/data:/data/db
      - ./services/mongodb/config:/etc/mongo
      - ./services/mongodb/logs:/var/log/mongodb
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD_FILE=/run/secrets/mongo_root_password
    restart: unless-stopped
    networks:
      - backend
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 2G
    secrets:
      - mongo_root_password

  prometheus:
    image: prom/prometheus:v2.43.0
    container_name: prometheus
    volumes:
      - ./services/prometheus/config:/etc/prometheus
      - ./services/prometheus/data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
    ports:
      - "9090:9090"
    restart: unless-stopped
    networks:
      - backend
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 1G

  grafana:
    image: grafana/grafana:9.5.1
    container_name: grafana
    volumes:
      - ./services/grafana/data:/var/lib/grafana
      - ./services/grafana/provisioning:/etc/grafana/provisioning
    environment:
      - GF_SECURITY_ADMIN_PASSWORD_FILE=/run/secrets/grafana_admin_password
      - GF_USERS_ALLOW_SIGN_UP=false
    ports:
      - "3000:3000"
    restart: unless-stopped
    networks:
      - frontend
      - backend
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 1G
    secrets:
      - grafana_admin_password

  backup-manager:
    build:
      context: ./services/backup-manager
      dockerfile: Dockerfile
    container_name: backup-manager
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./services/backup-manager/scripts:/scripts
      - ./services/backup-manager/data:/backup-data
      - /backup:/backup
      - ./services/secrets:/secrets:ro
    environment:
      - BACKUP_RETENTION_DAYS=14
      - ENCRYPTION_KEY_FILE=/secrets/backup_encryption_key.txt
      - REMOTE_BACKUP=false
      - S3_BUCKET=your-backup-bucket
      - AWS_REGION=eu-central-1
    restart: unless-stopped
    networks:
      - backend
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M

secrets:
  mongo_root_password:
    file: ./services/secrets/mongo_root_password.txt
  redis_password:
    file: ./services/secrets/redis_password.txt
  grafana_admin_password:
    file: ./services/secrets/grafana_admin_password.txt

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
EOF
  
  success "Docker Compose Konfiguration erstellt."
}

# Erstelle Dockerfiles für jeden Dienst
create_dockerfiles() {
  log "Erstelle Dockerfiles für Services..."
  
  # Vault Dockerfile
  cat > "${SERVICES_DIR}/vault/Dockerfile" << EOF
FROM alpine:3.17

ARG VAULT_VERSION=1.15.5

RUN apk add --no-cache curl unzip libcap openssl jq bash wget && \\
    curl -Lo /tmp/vault.zip https://releases.hashicorp.com/vault/\${VAULT_VERSION}/vault_\${VAULT_VERSION}_linux_amd64.zip && \\
    unzip /tmp/vault.zip -d /bin && \\
    rm -f /tmp/vault.zip && \\
    setcap cap_ipc_lock=+ep /bin/vault

VOLUME /vault/data
VOLUME /vault/config
VOLUME /vault/logs
VOLUME /vault/tls

EXPOSE 8200
EXPOSE 8201

COPY config/config.hcl /vault/config/config.hcl
COPY scripts/init-vault.sh /vault/init-vault.sh

RUN chmod +x /vault/init-vault.sh

ENTRYPOINT ["/bin/bash", "-c", "vault server -config=/vault/config/config.hcl && /vault/init-vault.sh"]
EOF
  
  # Redis Dockerfile
  cat > "${SERVICES_DIR}/redis/Dockerfile" << EOF
FROM redis:7.0.5-alpine

VOLUME /data

COPY config/redis.conf.template /usr/local/etc/redis/redis.conf.template
COPY scripts/startup.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/startup.sh

EXPOSE 6379

CMD ["/usr/local/bin/startup.sh"]
EOF
  
  # MongoDB Dockerfile
  cat > "${SERVICES_DIR}/mongodb/Dockerfile" << EOF
FROM mongo:6.0

VOLUME /data/db
VOLUME /data/configdb
VOLUME /var/log/mongodb

EXPOSE 27017

COPY config/mongod.conf /etc/mongod.conf

CMD ["mongod", "--config", "/etc/mongod.conf"]
EOF
  
  # Qdrant Dockerfile
  cat > "${SERVICES_DIR}/qdrant/Dockerfile" << EOF
FROM qdrant/qdrant:v1.5.0

VOLUME /qdrant/storage

EXPOSE 6333
EXPOSE 6334

CMD ["./qdrant"]
EOF
  
  # Backup Manager Dockerfile und Skripte
  mkdir -p "${SERVICES_DIR}/backup-manager/scripts"
  
  cat > "${SERVICES_DIR}/backup-manager/Dockerfile" << EOF
FROM alpine:3.17

RUN apk add --no-cache bash docker-cli jq curl openssl gzip tar mongodb-tools redis coreutils \
    && mkdir -p /scripts /backup-data

COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

VOLUME /backup-data
VOLUME /backup

ENTRYPOINT ["/scripts/entrypoint.sh"]
EOF
  
  success "Dockerfiles für Services erstellt."
}

# Erstelle Konfigurationsdateien für jeden Dienst
create_service_configs() {
  log "Erstelle Konfigurationsdateien für Services..."
  
  # Vault Konfiguration
  mkdir -p "${SERVICES_DIR}/vault/scripts"
  
  # Vault config.hcl
  cat > "${SERVICES_DIR}/vault/config/config.hcl" << EOF
ui = true
disable_mlock = true

# Hochverfügbare Konfiguration
cluster_name = "vault-cluster"

# Verbesserte Datenspeicherung mit Integrated Storage (Raft)
storage "raft" {
  path = "/vault/data"
  node_id = "vault_1"
  
  retry_join {
    leader_api_addr = "https://127.0.0.1:8200"
  }
}

# TLS-aktivierter Listener
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 0
  tls_cert_file = "/vault/tls/vault.crt"
  tls_key_file  = "/vault/tls/vault.key"
  tls_min_version = "tls12"
}

api_addr = "https://0.0.0.0:8200"
cluster_addr = "https://0.0.0.0:8201"

# Performance und Stabilität
default_lease_ttl = "768h"
max_lease_ttl = "768h"

# Verbesserte Sicherheitseinstellungen
telemetry {
  prometheus_retention_time = "24h"
  disable_hostname = true
}

# Log Konfiguration
log_level = "info"
log_format = "json"
EOF
  
  # Vault init script
  cat > "${SERVICES_DIR}/vault/scripts/init-vault.sh" << EOF
#!/bin/bash
set -e

# Warten auf Vault
until curl -s -k https://127.0.0.1:8200/v1/sys/health; do
  echo "Warte auf Vault..."
  sleep 1
done

# Prüfe, ob Vault initialisiert ist
INITIALIZED=\$(curl -s -k https://127.0.0.1:8200/v1/sys/init | grep -c '"initialized":true')

if [ "\$INITIALIZED" -eq 0 ]; then
  echo "Initialisiere Vault..."
  
  # Bei Auto-Unseal werden weniger Unseal-Keys benötigt
  # Wenn kein Auto-Unseal konfiguriert ist, nutzt Shamir mit 5 Keys
  INIT_RESPONSE=\$(curl -s -k https://127.0.0.1:8200/v1/sys/init -X PUT -d '{"secret_shares": 5, "secret_threshold": 3}')
  
  # Speichere Root-Token und Unseal-Keys sicher
  echo "\$INIT_RESPONSE" > /vault/data/init_data.json
  chmod 600 /vault/data/init_data.json
  
  # Exportiere die Keys auch in einzelne Dateien für einfachere Handhabung
  ROOT_TOKEN=\$(echo "\$INIT_RESPONSE" | jq -r '.root_token')
  echo "\$ROOT_TOKEN" > /vault/data/root_token.txt
  chmod 600 /vault/data/root_token.txt
  
  echo "Vault initialisiert. Root-Token und Unseal-Keys in /vault/data/init_data.json gespeichert."
  echo "WICHTIG: Sichern Sie diese Daten an einem sicheren Ort!"
  
  # Extrahiere Unseal-Keys
  for i in {0..4}; do
    KEY=\$(echo "\$INIT_RESPONSE" | jq -r ".keys_base64[\$i]")
    echo "\$KEY" > /vault/data/unseal_key_\$i.txt
    chmod 600 /vault/data/unseal_key_\$i.txt
  done
  
  # Unseal Vault
  for i in {0..2}; do
    UNSEAL_KEY=\$(cat /vault/data/unseal_key_\$i.txt)
    curl -s -k https://127.0.0.1:8200/v1/sys/unseal -X PUT -d "{\"key\":\"\$UNSEAL_KEY\"}"
    sleep 1
  done
else
  echo "Vault ist bereits initialisiert."
  
  # Wenn Vault versiegelt ist, entsiegeln
  SEALED=\$(curl -s -k https://127.0.0.1:8200/v1/sys/seal-status | grep -c '"sealed":true')
  if [ "\$SEALED" -eq 1 ] && [ -f /vault/data/unseal_key_0.txt ]; then
    echo "Vault ist versiegelt. Entsiegele..."
    
    # Unseal mit den vorhandenen Keys
    for i in {0..2}; do
      if [ -f /vault/data/unseal_key_\$i.txt ]; then
        UNSEAL_KEY=\$(cat /vault/data/unseal_key_\$i.txt)
        curl -s -k https://127.0.0.1:8200/v1/sys/unseal -X PUT -d "{\"key\":\"\$UNSEAL_KEY\"}"
        sleep 1
      fi
    done
  fi
fi

# Konfiguriere Vault für Production, wenn Root-Token vorhanden ist
if [ -f /vault/data/root_token.txt ]; then
  echo "Konfiguriere Vault für Production-Umgebung..."
  
  # Extrahiere Root-Token
  ROOT_TOKEN=\$(cat /vault/data/root_token.txt)
  
  # Exportiere Root-Token für Vault-CLI
  export VAULT_TOKEN="\$ROOT_TOKEN"
  export VAULT_ADDR="https://127.0.0.1:8200"
  export VAULT_SKIP_VERIFY="true"
  
  # Prüfe ob Audit-Logging aktiviert ist, wenn nicht, aktivieren
  AUDIT_ENABLED=\$(vault audit list 2>/dev/null | grep -c 'file/' || echo "0")
  if [ "\$AUDIT_ENABLED" -eq 0 ]; then
    vault audit enable file file_path=/vault/logs/audit.log
  fi
  
  # Aktiviere wichtige Secret Engines, falls noch nicht geschehen
  vault secrets enable -path=secret kv-v2 2>/dev/null || echo "KV-v2 bereits aktiviert"
  vault secrets enable -path=pki pki 2>/dev/null || echo "PKI bereits aktiviert"
  vault secrets enable -path=transit transit 2>/dev/null || echo "Transit bereits aktiviert"
  
  # Konfiguriere PKI für interne CAs
  vault secrets tune -max-lease-ttl=87600h pki 2>/dev/null || echo "PKI bereits konfiguriert"
  
  echo "Vault ist produktionsbereit konfiguriert."
fi
EOF
  
  chmod +x "${SERVICES_DIR}/vault/scripts/init-vault.sh"
  
  # Redis Konfiguration
  mkdir -p "${SERVICES_DIR}/redis/scripts"
  
  # Redis config template
  cat > "${SERVICES_DIR}/redis/config/redis.conf.template" << EOF
# Redis verbesserte Konfiguration
bind 0.0.0.0
port 6379
protected-mode yes
dir /data
appendonly yes

# Sicherheitseinstellungen
requirepass REDIS_PASSWORD_PLACEHOLDER
maxmemory 512mb
maxmemory-policy allkeys-lru

# Performance-Einstellungen
save 900 1
save 300 10
save 60 10000

# Verbesserte Sicherheitseinstellungen
rename-command FLUSHALL ""
rename-command FLUSHDB ""
rename-command DEBUG ""
rename-command CONFIG ""
EOF
  
  # Redis startup script
  cat > "${SERVICES_DIR}/redis/scripts/startup.sh" << EOF
#!/bin/sh
set -e

# Lese das Redis-Passwort aus der Secret-Datei
REDIS_PASSWORD=\$(cat /run/secrets/redis_password)

# Erstelle Redis-Konfiguration mit dem Passwort
sed "s/REDIS_PASSWORD_PLACEHOLDER/\$REDIS_PASSWORD/g" /usr/local/etc/redis/redis.conf.template > /usr/local/etc/redis/redis.conf

# Starte Redis-Server
exec redis-server /usr/local/etc/redis/redis.conf
EOF
  
  chmod +x "${SERVICES_DIR}/redis/scripts/startup.sh"
  
  # MongoDB Konfiguration
  cat > "${SERVICES_DIR}/mongodb/config/mongod.conf" << EOF
# MongoDB verbesserte Konfiguration
storage:
  dbPath: /data/db
  journal:
    enabled: true
  wiredTiger:
    engineConfig:
      cacheSizeGB: 1

systemLog:
  destination: file
  path: /var/log/mongodb/mongod.log
  logAppend: true

net:
  port: 27017
  bindIp: 0.0.0.0

security:
  authorization: enabled

operationProfiling:
  mode: slowOp
  slowOpThresholdMs: 100

setParameter:
  enableLocalhostAuthBypass: false
EOF
  
  # Prometheus Konfiguration
  cat > "${SERVICES_DIR}/prometheus/config/prometheus.yml" << EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  scrape_timeout: 10s

rule_files:
  - "rules/*.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'vault'
    metrics_path: '/v1/sys/metrics'
    params:
      format: ['prometheus']
    scheme: https
    tls_config:
      insecure_skip_verify: true
    static_configs:
      - targets: ['vault:8200']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']

  - job_name: 'mongodb'
    static_configs:
      - targets: ['mongodb:27017']

  - job_name: 'qdrant'
    static_configs:
      - targets: ['qdrant:6333']
EOF
  
  # Backup Manager Scripts
  cat > "${SERVICES_DIR}/backup-manager/scripts/entrypoint.sh" << EOF
#!/bin/bash
set -e

# Encryption key generation if not exists
if [ ! -f /secrets/backup_encryption_key.txt ]; then
  echo "Generating new backup encryption key..."
  openssl rand -base64 32 > /secrets/backup_encryption_key.txt
  chmod 600 /secrets/backup_encryption_key.txt
fi

# Einrichten des Cron-Jobs für regelmäßige Backups
echo "Setting up backup cron job..."
echo "0 2 * * * /scripts/backup.sh > /backup-data/backup_\$(date +\\%Y\\%m\\%d).log 2>&1" > /etc/crontabs/root
echo "0 3 * * * /scripts/cleanup.sh > /backup-data/cleanup_\$(date +\\%Y\\%m\\%d).log 2>&1" >> /etc/crontabs/root
echo "0 4 * * 0 /scripts/backup_check.sh > /backup-data/backup_check_\$(date +\\%Y\\%m\\%d).log 2>&1" >> /etc/crontabs/root

# Starte den Cron-Daemon und halte den Container am Leben
echo "Starting crond..."
crond -f -l 8
EOF
  
  chmod +x "${SERVICES_DIR}/backup-manager/scripts/entrypoint.sh"
  
  # Backup script
  cat > "${SERVICES_DIR}/backup-manager/scripts/backup.sh" << EOF
#!/bin/bash
set -e

# Konfiguration
BACKUP_DIR="/backup/\$(date +%Y%m%d_%H%M%S)"
ENCRYPTION_KEY=\$(cat \$ENCRYPTION_KEY_FILE)
MONGO_PASSWORD=\$(cat /secrets/mongo_root_password.txt)
TIMESTAMP=\$(date +%Y%m%d_%H%M%S)

# Erstelle Backup-Verzeichnis
mkdir -p \$BACKUP_DIR

# Funktion zum Verschlüsseln von Backup-Dateien
encrypt_backup() {
  local src_file=\$1
  local dest_file="\${src_file}.enc"
  
  openssl enc -aes-256-cbc -salt -in "\$src_file" -out "\$dest_file" -k "\$ENCRYPTION_KEY" -md sha256
  rm "\$src_file"
  echo "Verschlüsselt: \$src_file -> \$dest_file"
}

# Backup MongoDB
echo "[\$TIMESTAMP] Backing up MongoDB..."
mkdir -p "\$BACKUP_DIR/mongodb"
docker exec mongodb mongodump --username admin --password "\$MONGO_PASSWORD" --out /tmp/backup
docker cp mongodb:/tmp/backup "\$BACKUP_DIR/mongodb"
docker exec mongodb rm -rf /tmp/backup
tar -czf "\$BACKUP_DIR/mongodb_\$TIMESTAMP.tar.gz" -C "\$BACKUP_DIR" mongodb
rm -rf "\$BACKUP_DIR/mongodb"
encrypt_backup "\$BACKUP_DIR/mongodb_\$TIMESTAMP.tar.gz"

# Backup Redis
echo "[\$TIMESTAMP] Backing up Redis..."
mkdir -p "\$BACKUP_DIR/redis"
# Sicherstellen, dass Redis SAVE ausführt
docker exec redis redis-cli SAVE
docker cp redis:/data "\$BACKUP_DIR/redis"
tar -czf "\$BACKUP_DIR/redis_\$TIMESTAMP.tar.gz" -C "\$BACKUP_DIR" redis
rm -rf "\$BACKUP_DIR/redis"
encrypt_backup "\$BACKUP_DIR/redis_\$TIMESTAMP.tar.gz"

# Backup Vault
echo "[\$TIMESTAMP] Backing up Vault..."
mkdir -p "\$BACKUP_DIR/vault"
docker cp vault:/vault/data "\$BACKUP_DIR/vault"
tar -czf "\$BACKUP_DIR/vault_\$TIMESTAMP.tar.gz" -C "\$BACKUP_DIR" vault
rm -rf "\$BACKUP_DIR/vault"
encrypt_backup "\$BACKUP_DIR/vault_\$TIMESTAMP.tar.gz"

# Backup Qdrant
echo "[\$TIMESTAMP] Backing up Qdrant..."
mkdir -p "\$BACKUP_DIR/qdrant"
docker cp qdrant:/qdrant/storage "\$BACKUP_DIR/qdrant"
tar -czf "\$BACKUP_DIR/qdrant_\$TIMESTAMP.tar.gz" -C "\$BACKUP_DIR" qdrant
rm -rf "\$BACKUP_DIR/qdrant"
encrypt_backup "\$BACKUP_DIR/qdrant_\$TIMESTAMP.tar.gz"

# Erstelle Backup-Manifest mit SHA256 Prüfsummen
echo "[\$TIMESTAMP] Creating backup manifest..."
echo "Backup created on \$(date)" > "\$BACKUP_DIR/manifest.txt"
echo "Services: MongoDB, Redis, Vault, Qdrant" >> "\$BACKUP_DIR/manifest.txt"
echo "" >> "\$BACKUP_DIR/manifest.txt"
echo "Checksums:" >> "\$BACKUP_DIR/manifest.txt"
for file in "\$BACKUP_DIR"/*.enc; do
  CHECKSUM=\$(sha256sum "\$file" | cut -d' ' -f1)
  echo "\$(basename "\$file"): \$CHECKSUM" >> "\$BACKUP_DIR/manifest.txt"
done

# Manifest selbst verschlüsseln
encrypt_backup "\$BACKUP_DIR/manifest.txt"

echo "[\$TIMESTAMP] Backup completed successfully! Files stored in \$BACKUP_DIR"

# Remote Backup zu S3 (falls konfiguriert)
if [ "\$REMOTE_BACKUP" = "true" ] && [ ! -z "\$S3_BUCKET" ]; then
  echo "[\$TIMESTAMP] Uploading backup to S3 bucket \$S3_BUCKET..."
  aws s3 sync "\$BACKUP_DIR" "s3://\$S3_BUCKET/\$(basename "\$BACKUP_DIR")/"
  echo "[\$TIMESTAMP] S3 upload completed!"
fi
EOF

chmod +x "${SERVICES_DIR}/backup-manager/scripts/backup.sh"

# Cleanup script für alte Backups
cat > "${SERVICES_DIR}/backup-manager/scripts/cleanup.sh" << EOF
#!/bin/bash
set -e

# Konfiguration
TIMESTAMP=\$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=\${BACKUP_RETENTION_DAYS:-14}

echo "[\$TIMESTAMP] Cleaning up backups older than \$RETENTION_DAYS days..."

# Identifiziere alte Backups
find /backup -type d -name "20*_*" -mtime +\$RETENTION_DAYS | while read backup_dir; do
  echo "[\$TIMESTAMP] Removing old backup: \$backup_dir"
  rm -rf "\$backup_dir"
done

echo "[\$TIMESTAMP] Cleanup completed!"
EOF

chmod +x "${SERVICES_DIR}/backup-manager/scripts/cleanup.sh"

# Backup check script für Integritätsprüfungen
cat > "${SERVICES_DIR}/backup-manager/scripts/backup_check.sh" << EOF
#!/bin/bash
set -e

# Konfiguration
TIMESTAMP=\$(date +%Y%m%d_%H%M%S)
ENCRYPTION_KEY=\$(cat \$ENCRYPTION_KEY_FILE)
CHECK_DIR="/backup-data/check_\$TIMESTAMP"
LATEST_BACKUP=\$(find /backup -type d -name "20*_*" | sort | tail -n 1)

echo "[\$TIMESTAMP] Performing integrity check on latest backup: \$LATEST_BACKUP"

# Erstelle temporäres Verzeichnis für die Überprüfung
mkdir -p "\$CHECK_DIR"

# Prüfe, ob Manifest existiert und korrekt entschlüsselt werden kann
if [ -f "\$LATEST_BACKUP/manifest.txt.enc" ]; then
  echo "[\$TIMESTAMP] Verifying manifest file..."
  
  # Versuche das Manifest zu entschlüsseln
  if openssl enc -aes-256-cbc -d -salt -in "\$LATEST_BACKUP/manifest.txt.enc" -out "\$CHECK_DIR/manifest.txt" -k "\$ENCRYPTION_KEY" -md sha256 2>/dev/null; then
    echo "[\$TIMESTAMP] Manifest successfully decrypted."
    
    # Prüfe Checksummen
    grep -A 100 "Checksums:" "\$CHECK_DIR/manifest.txt" | grep -v "Checksums:" | while read line; do
      if [ ! -z "\$line" ]; then
        FILENAME=\$(echo "\$line" | cut -d':' -f1)
        EXPECTED_CHECKSUM=\$(echo "\$line" | cut -d':' -f2 | tr -d ' ')
        
        if [ -f "\$LATEST_BACKUP/\$FILENAME" ]; then
          ACTUAL_CHECKSUM=\$(sha256sum "\$LATEST_BACKUP/\$FILENAME" | cut -d' ' -f1)
          
          if [ "\$EXPECTED_CHECKSUM" = "\$ACTUAL_CHECKSUM" ]; then
            echo "[\$TIMESTAMP] Checksum OK: \$FILENAME"
          else
            echo "[\$TIMESTAMP] CHECKSUM ERROR: \$FILENAME"
            echo "   Expected: \$EXPECTED_CHECKSUM"
            echo "   Actual: \$ACTUAL_CHECKSUM"
          fi
        else
          echo "[\$TIMESTAMP] FILE MISSING: \$FILENAME"
        fi
      fi
    done
  else
    echo "[\$TIMESTAMP] ERROR: Failed to decrypt manifest file. Key may be incorrect."
  fi
else
  echo "[\$TIMESTAMP] ERROR: Manifest file not found in backup."
fi

# Aufräumen
rm -rf "\$CHECK_DIR"
echo "[\$TIMESTAMP] Integrity check completed!"
EOF

chmod +x "${SERVICES_DIR}/backup-manager/scripts/backup_check.sh"

success "Service-Konfigurationen erstellt."
}

# Hauptfunktion zum Setup der verbesserten Infrastruktur
setup_infrastructure() {
  log "Starte Setup der verbesserten Infrastruktur..."
  
  # Erstelle Verzeichnisstruktur
  create_directory_structure
  
  # Generiere sichere Passwörter
  generate_secure_passwords
  
  # Generiere TLS-Zertifikate
  generate_tls_certificates
  
  # Erstelle Docker Compose Konfiguration
  create_docker_compose
  
  # Erstelle Dockerfiles
  create_dockerfiles
  
  # Erstelle Service-Konfigurationen
  create_service_configs
  
  # Backup-Verschlüsselungsschlüssel generieren
  openssl rand -base64 32 > "${SECRETS_DIR}/backup_encryption_key.txt"
  chmod 600 "${SECRETS_DIR}/backup_encryption_key.txt"
  
  log "Starte Docker-Dienste..."
  cd "${BASE_DIR}" && docker-compose up -d
  
  success "Infrastruktur-Setup abgeschlossen!"
  
  log "Installation abgeschlossen. Details zur Infrastruktur:"
  echo ""
  echo -e "${GREEN}Vault${NC} ist verfügbar unter: https://localhost:8200"
  echo -e "${GREEN}MongoDB${NC} ist verfügbar unter: localhost:27017"
  echo -e "${GREEN}Redis${NC} ist verfügbar unter: localhost:6379"
  echo -e "${GREEN}Qdrant${NC} ist verfügbar unter: http://localhost:6333"
  echo -e "${GREEN}Prometheus${NC} ist verfügbar unter: http://localhost:9090"
  echo -e "${GREEN}Grafana${NC} ist verfügbar unter: http://localhost:3000"
  echo ""
  echo -e "${YELLOW}WICHTIG:${NC} Sichern Sie die folgenden Dateien an einem sicheren Ort:"
  echo "- ${SECRETS_DIR}/mongo_root_password.txt"
  echo "- ${SECRETS_DIR}/redis_password.txt"
  echo "- ${SECRETS_DIR}/grafana_admin_password.txt"
  echo "- ${SECRETS_DIR}/backup_encryption_key.txt"
  echo "- ${SERVICES_DIR}/vault/data/root_token.txt"
  echo "- ${SERVICES_DIR}/vault/data/unseal_key_*.txt"
  echo ""
  echo -e "${BLUE}Backups${NC} werden täglich um 02:00 Uhr erstellt und verschlüsselt in ${BACKUP_DIR} gespeichert."
  echo "Backups älter als 14 Tage werden automatisch gelöscht."
  echo "Eine wöchentliche Integritätsprüfung der Backups wird jeden Sonntag um 04:00 Uhr durchgeführt."
}

# Skript ausführen
setup_infrastructure
