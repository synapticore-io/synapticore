#!/bin/bash

set -e

echo "Starte Service-Verbesserungen..."

# Backup der aktuellen Konfiguration
echo "Erstelle Backup der aktuellen Konfiguration..."
timestamp=$(date +%Y%m%d_%H%M%S)
backup_dir="backup_$timestamp"
mkdir -p $backup_dir
cp -r services $backup_dir/
echo "Backup erstellt in $backup_dir"

# Service-Netzwerk erstellen
echo "Erstelle ein internes Docker-Netzwerk für die Services..."
cat > services/docker-compose-network.yml << EOL
networks:
  backend:
    driver: bridge
    internal: true
  frontend:
    driver: bridge
EOL

# Vault verbessern für Production-Ready mit Auto-Unseal
echo "Verbessere Vault-Konfiguration mit Auto-Unseal für Produktion..."

# Erstelle Verzeichnis für TLS-Zertifikate
mkdir -p services/vault/tls

# Generiere selbstsignierte Zertifikate für Vault
echo "Generiere TLS-Zertifikate für Vault..."
openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
  -keyout services/vault/tls/vault.key \
  -out services/vault/tls/vault.crt \
  -subj "/CN=vault.example.com/O=Example Org/C=DE" \
  -addext "subjectAltName = DNS:vault.example.com,DNS:vault,IP:127.0.0.1"

chmod 600 services/vault/tls/vault.key

# Für AWS KMS Auto-Unseal (als Beispiel)
AWS_REGION=${AWS_REGION:-"eu-central-1"}
KMS_KEY_ID=${KMS_KEY_ID:-""}

# Erstelle AWS Credentials Datei wenn Keys vorhanden sind
if [ ! -z "$AWS_ACCESS_KEY_ID" ] && [ ! -z "$AWS_SECRET_ACCESS_KEY" ]; then
  mkdir -p services/vault/aws
  cat > services/vault/aws/credentials << EOL
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
region = $AWS_REGION
EOL
  chmod 600 services/vault/aws/credentials
fi

cat > services/vault/config/config.hcl << EOL
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

# Alternative Konfiguration mit disabled TLS für Tests (auskommentiert)
# listener "tcp" {
#   address     = "0.0.0.0:8200"
#   tls_disable = 1
# }

api_addr = "https://0.0.0.0:8200"
cluster_addr = "https://0.0.0.0:8201"

# Auto-Unseal mit AWS KMS - aktivieren, wenn KMS_KEY_ID gesetzt ist
EOL

# Füge AWS KMS Auto-Unseal Konfiguration hinzu, wenn KMS_KEY_ID gesetzt ist
if [ ! -z "$KMS_KEY_ID" ]; then
  cat >> services/vault/config/config.hcl << EOL
seal "awskms" {
  region     = "$AWS_REGION"
  kms_key_id = "$KMS_KEY_ID"
  # Wenn AWS Credentials als Volumes gemounted werden
  # aws_access_key_id = ""
  # aws_secret_access_key = ""
}
EOL
  echo "AWS KMS Auto-Unseal konfiguriert mit KMS Key: $KMS_KEY_ID"
else
  cat >> services/vault/config/config.hcl << EOL
# Für Auto-Unseal, bitte einen der folgenden Blöcke aktivieren und konfigurieren:

# AWS KMS Auto-Unseal
# seal "awskms" {
#   region     = "eu-central-1"
#   kms_key_id = "arn:aws:kms:eu-central-1:ACCOUNT-ID:key/KEY-ID"
# }

# Google Cloud KMS Auto-Unseal
# seal "gcpckms" {
#   project     = "project-id"
#   region      = "global"
#   key_ring    = "vault-keyring"
#   crypto_key  = "vault-key"
# }

# Azure Key Vault Auto-Unseal
# seal "azurekeyvault" {
#   tenant_id      = "tenant-id"
#   client_id      = "client-id"
#   client_secret  = "client-secret"
#   vault_name     = "vault-name"
#   key_name       = "key-name"
# }

# Für Transit Auto-Unseal (einen anderen Vault Server verwenden)
# seal "transit" {
#   address            = "https://vault-transit:8200"
#   token              = "transit-token"
#   disable_renewal    = "false"
#   key_name           = "autounseal"
#   mount_path         = "transit/"
#   tls_skip_verify    = "false"
# }
EOL
  echo "Auto-Unseal Vorlagen für verschiedene Anbieter hinzugefügt, bitte konfigurieren Sie eine davon"
fi

# Verbesserte Telemetrie und Performance-Einstellungen
cat >> services/vault/config/config.hcl << EOL

# Performance und Stabilität
default_lease_ttl = "768h"
max_lease_ttl = "768h"

# Verbesserte Sicherheitseinstellungen
telemetry {
  prometheus_retention_time = "24h"
  disable_hostname = true
  statsite_address = "127.0.0.1:8125"
  
  # Detaillierte Metriken
  usage_gauge_period = "10m"
  maximum_gauge_cardinality = 500
  
  # StatsD-Konfiguration
  statsd_address = "127.0.0.1:8125"
}

# Log Konfiguration
log_level = "info"
log_format = "json"
EOL

# Erstelle ein Initialisierungsskript für Vault
cat > services/vault/init-vault.sh << 'EOL'
#!/bin/bash
set -e

# Warten auf Vault
until curl -s -k https://127.0.0.1:8200/v1/sys/health || curl -s http://127.0.0.1:8200/v1/sys/health; do
  echo "Warte auf Vault..."
  sleep 1
done

# Prüfe, ob Vault initialisiert ist
INITIALIZED=$(curl -s -k https://127.0.0.1:8200/v1/sys/init | grep -c '"initialized":true' || curl -s http://127.0.0.1:8200/v1/sys/init | grep -c '"initialized":true')

if [ "$INITIALIZED" -eq 0 ]; then
  echo "Initialisiere Vault..."
  
  # Bei Auto-Unseal werden weniger Unseal-Keys benötigt
  # Wenn kein Auto-Unseal konfiguriert ist, nutzt Shamir mit 5 Keys
  INIT_RESPONSE=$(curl -s -k https://127.0.0.1:8200/v1/sys/init -X PUT -d '{"secret_shares": 5, "secret_threshold": 3}' || curl -s http://127.0.0.1:8200/v1/sys/init -X PUT -d '{"secret_shares": 5, "secret_threshold": 3}')
  
  # Speichere Root-Token und Unseal-Keys sicher
  echo "$INIT_RESPONSE" > /vault/data/init_data.json
  chmod 600 /vault/data/init_data.json
  
  echo "Vault initialisiert. Root-Token und Unseal-Keys in /vault/data/init_data.json gespeichert."
  echo "WICHTIG: Sichern Sie diese Daten an einem sicheren Ort!"
else
  echo "Vault ist bereits initialisiert."
fi

# Konfiguriere Vault für Production
echo "Konfiguriere Vault für Production-Umgebung..."

# Extrahiere Root-Token aus init_data.json (wenn vorhanden)
if [ -f /vault/data/init_data.json ]; then
  ROOT_TOKEN=$(grep -o '"root_token":"[^"]*' /vault/data/init_data.json | cut -d'"' -f4)
  if [ ! -z "$ROOT_TOKEN" ]; then
    # Exportiere Root-Token für Vault-CLI
    export VAULT_TOKEN="$ROOT_TOKEN"
    
    # Aktiviere Audit Logging
    vault audit enable file file_path=/vault/logs/audit.log
    
    # Aktiviere wichtige Secret Engines für typische Anwendungsfälle
    vault secrets enable -path=secret kv-v2
    vault secrets enable -path=pki pki
    vault secrets enable -path=transit transit
    
    # Konfiguriere PKI für interne CAs
    vault secrets tune -max-lease-ttl=87600h pki
    
    echo "Vault ist produktionsbereit konfiguriert."
  fi
fi
EOL

chmod +x services/vault/init-vault.sh
echo "Vault für Produktion mit Auto-Unseal Optionen konfiguriert."

# Redis verbessern
echo "Verbessere Redis-Konfiguration..."
cat > services/redis/config/redis.conf << EOL
# Redis verbesserte Konfiguration
bind 0.0.0.0
port 6379
protected-mode yes
dir /data
appendonly yes

# Sicherheitseinstellungen
requirepass $(openssl rand -hex 16)
maxmemory 512mb
maxmemory-policy allkeys-lru

# Performance-Einstellungen
save 900 1
save 300 10
save 60 10000
EOL

# Speichere das generierte Redis-Passwort
grep "requirepass" services/redis/config/redis.conf | awk '{print $2}' > redis_password.txt
echo "Redis-Passwort gespeichert in redis_password.txt"

# MongoDB verbessern
echo "Verbessere MongoDB-Konfiguration..."
cat > services/mongodb/config/mongod.conf << EOL
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
EOL

# Qdrant auf eine spezifische Version festlegen
echo "Ändere Qdrant Dockerfile, um eine spezifische Version zu verwenden..."
sed -i 's/FROM qdrant\/qdrant:latest/FROM qdrant\/qdrant:v1.5.0/' services/qdrant/Dockerfile

# Aktualisiere die docker-compose.yml mit Verbesserungen
echo "Aktualisiere docker-compose.yml mit Verbesserungen..."
cat > services/docker-compose.yml << EOL
services:
  vault:
    build: ./vault
    container_name: vault
    ports:
      - "8200:8200"
      - "8201:8201"
    volumes:
      - ./vault/data:/vault/data
      - ./vault/logs:/vault/logs
      - ./vault/config:/vault/config
      - ./vault/tls:/vault/tls:ro
      # Für AWS KMS Auto-Unseal, falls verwendet
      - ./vault/aws:/root/.aws:ro
    cap_add:
      - IPC_LOCK
    environment:
      - VAULT_ADDR=https://0.0.0.0:8200
      - VAULT_SKIP_VERIFY=true
      # Für AWS KMS Auto-Unseal Umgebungsvariablen, falls benötigt
      # - AWS_REGION=eu-central-1
    restart: unless-stopped
    networks:
      - frontend
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
    entrypoint: 
      - "/bin/sh"
      - "-c"
      - "vault server -config=/vault/config/config.hcl && /vault/init-vault.sh"

  redis:
    build: ./redis
    container_name: redis
    ports:
      - "6379:6379"
    volumes:
      - ./redis/data:/data
      - ./redis/config:/usr/local/etc/redis
    restart: unless-stopped
    networks:
      - backend
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 1G

  qdrant:
    build: ./qdrant
    container_name: qdrant
    ports:
      - "6333:6333"
      - "6334:6334"
    volumes:
      - ./qdrant/data:/qdrant/storage
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
    build: ./mongodb
    container_name: mongodb
    ports:
      - "27017:27017"
    volumes:
      - ./mongodb/data:/data/db
      - ./mongodb/config:/etc/mongo
      - ./mongodb/logs:/var/log/mongodb
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
      - ./prometheus/config:/etc/prometheus
      - ./prometheus/data:/prometheus
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
      - ./grafana/data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
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

secrets:
  mongo_root_password:
    file: ./secrets/mongo_root_password.txt
  grafana_admin_password:
    file: ./secrets/grafana_admin_password.txt

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
EOL

# Erstelle Verzeichnisse für die neuen Services
echo "Erstelle Verzeichnisse für neue Services..."
mkdir -p services/prometheus/config services/prometheus/data
mkdir -p services/grafana/data services/grafana/provisioning
mkdir -p services/mongodb/logs

# Erstelle Secrets-Verzeichnis
echo "Erstelle Secrets-Verzeichnis und sichere Passwörter..."
mkdir -p services/secrets
openssl rand -hex 16 > services/secrets/mongo_root_password.txt
openssl rand -hex 16 > services/secrets/grafana_admin_password.txt
chmod 600 services/secrets/*.txt

# Erstelle Prometheus-Konfiguration
echo "Erstelle Prometheus-Konfiguration..."
cat > services/prometheus/config/prometheus.yml << EOL
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'vault'
    metrics_path: '/v1/sys/metrics'
    params:
      format: ['prometheus']
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
EOL

# Backup-Skript erstellen
echo "Erstelle Backup-Skript..."
cat > services/backup.sh << EOL
#!/bin/bash

# Backup-Skript für alle Services
backup_dir="/backup/\$(date +%Y%m%d_%H%M%S)"
mkdir -p \$backup_dir

# Backup MongoDB
echo "Backing up MongoDB..."
docker exec mongodb mongodump --username admin --password \$(cat services/secrets/mongo_root_password.txt) --out /tmp/backup
docker cp mongodb:/tmp/backup \$backup_dir/mongodb
docker exec mongodb rm -rf /tmp/backup

# Backup Redis
echo "Backing up Redis..."
docker exec redis redis-cli save
docker cp redis:/data \$backup_dir/redis

# Backup Vault
echo "Backing up Vault..."
docker cp vault:/vault/data \$backup_dir/vault

# Backup Qdrant
echo "Backing up Qdrant..."
docker cp qdrant:/qdrant/storage \$backup_dir/qdrant

echo "Backup completed! Files stored in \$backup_dir"
EOL
chmod +x services/backup.sh

echo "Verbesserungen abgeschlossen. Starten Sie die Services mit 'docker-compose up -d'."
echo "Wichtig: Sichern Sie die generierten Passwörter aus den secrets-Dateien und redis_password.txt!"
