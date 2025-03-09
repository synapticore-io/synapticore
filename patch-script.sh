#!/bin/bash
set -e

# Farben für die Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Keine Farbe

echo -e "${BLUE}Synapticore Services Notfall-Fix${NC}"
echo -e "Dieses Script behebt kritische Probleme mit Vault und Prometheus.\n"

# 1. Korrigiere die Vault-Container-Probleme
echo -e "${BLUE}1. Korrigiere Vault Reset-Script...${NC}"

cat > services/vault/scripts/reset-vault.sh << 'EOF'
#!/bin/bash
set -e

# Kein automatisches Reset, wenn eine .keep Datei existiert
if [ -f "/vault/data/.keep" ]; then
  echo "Reset wurde manuell deaktiviert (.keep Datei gefunden)."
  exit 0
fi

# Überprüfen, ob ein Reset-Lock existiert
if [ -f "/vault/data/.reset_lock" ]; then
  echo "Reset lock exists, skipping reset."
  exit 0
fi

# Überprüfen, ob wir beim ersten Start sind - für den ersten Start keine Reset-Bedingung prüfen
if [ ! -f "/vault/data/vault.db" ] && [ ! -f "/vault/data/unseal_key.txt" ]; then
  echo "First-time initialization, no reset needed."
  touch /vault/data/.reset_lock
  exit 0
fi

# Überprüfen, ob Vault-Daten existieren, aber der Unseal-Schlüssel fehlt - nur dann zurücksetzen
if [ -d "/vault/data" ] && [ -f "/vault/data/vault.db" ] && [ ! -f "/vault/data/unseal_key.txt" ]; then
  echo "Vault data exists but unseal key is missing. Performing complete reset..."
  
  # Sicherstellen, dass Vault nicht läuft
  pkill vault || true
  
  # Warten, bis Vault vollständig beendet ist
  sleep 2
  
  # Vollständiges Löschen aller Daten - WICHTIG: Spezifisch nur die DB-Dateien löschen!
  rm -f /vault/data/vault.db*
  rm -f /vault/data/raft/*
  
  # Erstellen einer .keep-Datei, um sicherzustellen, dass das Verzeichnis existiert
  touch /vault/data/.keep
  
  # Erstellen eines Reset-Locks, um zu verhindern, dass das Skript erneut ausgeführt wird
  touch /vault/data/.reset_lock
  
  echo "Vault data reset completed. Vault will be reinitialized."
else
  echo "Vault data check passed, no reset needed."
  # Erstellen eines Reset-Locks, um zu verhindern, dass das Skript erneut ausgeführt wird
  touch /vault/data/.reset_lock
fi
EOF

chmod +x services/vault/scripts/reset-vault.sh

# 2. Korrigiere Vault init-vault.sh (richtige URL)
echo -e "${BLUE}2. Korrigiere Vault init-script...${NC}"

cat > services/vault/scripts/init-vault.sh << 'EOF'
#!/bin/bash
set -e

# Nutze HTTP statt HTTPS da TLS deaktiviert ist
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_SKIP_VERIFY="true"

# Warten, bis Vault bereit ist
echo "Waiting for Vault to start..."
until curl -s $VAULT_ADDR/v1/sys/health > /dev/null 2>&1; do
  echo "Waiting for Vault to become available..."
  sleep 1
done

# Check if Vault is initialized
initialized=$(curl -s $VAULT_ADDR/v1/sys/init | jq -r '.initialized')

if [ "$initialized" = "false" ]; then
  echo "Initializing Vault..."
  
  # Initialize Vault with 1 key share and 1 key threshold (for development/testing)
  INIT_RESPONSE=$(curl -s -X PUT -d '{"secret_shares": 1, "secret_threshold": 1}' $VAULT_ADDR/v1/sys/init)
  
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
sealed=$(curl -s $VAULT_ADDR/v1/sys/seal-status | jq -r '.sealed')

if [ "$sealed" = "true" ]; then
  echo "Unsealing Vault..."
  
  # Get unseal key
  if [ -f /vault/data/unseal_key.txt ]; then
    UNSEAL_KEY=$(cat /vault/data/unseal_key.txt)
    curl -s -X PUT -d "{\"key\": \"$UNSEAL_KEY\"}" $VAULT_ADDR/v1/sys/unseal
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
SECRETS_ENABLED=$(curl -s -H "X-Vault-Token: $ROOT_TOKEN" $VAULT_ADDR/v1/sys/mounts | grep -c '"secret/"' || echo "0")
if [ "$SECRETS_ENABLED" = "0" ]; then
  echo "Enabling KV secrets engine..."
  curl -s -X POST -H "X-Vault-Token: $ROOT_TOKEN" -d '{"type":"kv","options":{"version":"2"}}' $VAULT_ADDR/v1/sys/mounts/secret
fi

# Enable Transit Secret Engine for encryption operations if not already enabled
TRANSIT_ENABLED=$(curl -s -H "X-Vault-Token: $ROOT_TOKEN" $VAULT_ADDR/v1/sys/mounts | grep -c '"transit/"' || echo "0")
if [ "$TRANSIT_ENABLED" = "0" ]; then
  echo "Enabling Transit Secret Engine..."
  curl -s -X POST -H "X-Vault-Token: $ROOT_TOKEN" -d '{"type":"transit"}' $VAULT_ADDR/v1/sys/mounts/transit
  
  # Create encryption key for general use
  curl -s -X POST -H "X-Vault-Token: $ROOT_TOKEN" -d '{}' $VAULT_ADDR/v1/transit/keys/synapticore-key
  
  echo "Transit Secret Engine enabled!"
fi

# Vault CLI benötigt die korrekte Adresse
export VAULT_ADDR="http://127.0.0.1:8200"

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

chmod +x services/vault/scripts/init-vault.sh

# 3. Korrigiere Vault Docker-Compose Einträge
echo -e "${BLUE}3. Korrigiere Vault-Umgebungsvariablen in docker-compose.yml...${NC}"

# Temporäre Datei erstellen
cat > docker-compose.yml.new << 'EOF'
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
      - VAULT_ADDR=http://127.0.0.1:8200
      - VAULT_API_ADDR=http://0.0.0.0:8200
    networks:
      - synapticore-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://127.0.0.1:8200/v1/sys/health"]
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
      - VAULT_ADDR=http://127.0.0.1:8200
      - VAULT_API_ADDR=http://0.0.0.0:8200
      - VAULT_TRANSIT_SERVER=true
    networks:
      - synapticore-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://127.0.0.1:8200/v1/sys/health"]
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
      - VAULT_ADDR=http://vault:8200
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
      - VAULT_ADDR=http://vault:8200
      - VAULT_SKIP_VERIFY=true
      - BACKUP_RETENTION_DAYS=14
      - RUN_INITIAL_BACKUP=false
      - REMOTE_BACKUP=false
      - USE_VAULT_SECRETS=true
    networks:
      - synapticore-network
    depends_on:
      - vault
      - redis
      - mongodb
      - qdrant
    restart: unless-stopped
EOF

# Ersetze die originale Datei
mv docker-compose.yml.new docker-compose.yml

# 4. Korrigiere Redis startup.sh (HTTP statt HTTPS)
echo -e "${BLUE}4. Korrigiere Redis startup.sh...${NC}"

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
    HEALTH_CHECK=$(curl -s $VAULT_ADDR/v1/sys/health || echo '{"sealed":true}')
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
    ROOT_TOKEN=""
    
    # Versuche, das Token von einem gemounteten Volume zu lesen
    if [ -f "/tmp/vault_token.txt" ]; then
      ROOT_TOKEN=$(cat /tmp/vault_token.txt 2>/dev/null || echo "")
    fi
    
    # Versuche, das Token über curl von Vault zu bekommen
    if [ -z "$ROOT_TOKEN" ]; then
      # Warte etwas länger auf Vault
      sleep 5
      # Verwende curl ohne -k da wir HTTP verwenden
      VAULT_RESPONSE=$(curl -s $VAULT_ADDR/v1/secret/data/redis || echo '{"data":{"data":{"password":""}}}')
      PASSWORD=$(echo $VAULT_RESPONSE | grep -o '"password":"[^"]*"' | sed 's/"password":"//;s/"//')
      
      if [ -n "$PASSWORD" ]; then
        echo "Got password via anonymous request - this should not happen in production!"
        REDIS_PASSWORD="$PASSWORD"
      else
        echo "Failed to retrieve password anonymously"
        
        # Versuche, das Root-Token direkt vom Vault-Container zu bekommen
        ROOT_TOKEN=$(curl -s --unix-socket /var/run/docker.sock http:/v1.40/containers/vault/exec -H "Content-Type: application/json" -d '{"AttachStdin":false,"AttachStdout":true,"AttachStderr":true,"Cmd":["cat","/vault/data/root_token.txt"]}' | grep -o '"Id":"[^"]*"' | cut -d'"' -f4)
        
        if [ -n "$ROOT_TOKEN" ]; then
          echo "Got root token from Vault container"
        fi
      fi
    fi
    
    # Wenn wir jetzt ein Token haben, versuche nochmal
    if [ -n "$ROOT_TOKEN" ]; then
      # Verwende curl ohne -k da wir HTTP verwenden
      VAULT_RESPONSE=$(curl -s -H "X-Vault-Token: ${ROOT_TOKEN}" \
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

echo "Using Redis password: $REDIS_PASSWORD"

# Create Redis configuration
sed "s/REDIS_PASSWORD_PLACEHOLDER/$REDIS_PASSWORD/g" /usr/local/etc/redis/redis.conf.template > /usr/local/etc/redis/redis.conf

# Start Redis server
exec redis-server /usr/local/etc/redis/redis.conf
EOF

chmod +x services/redis/scripts/startup.sh

# 5. Korrigiere Prometheus-Config (Schema auf HTTP)
echo -e "${BLUE}5. Korrigiere Prometheus Konfiguration...${NC}"

# Sicherstellen, dass das Prometheus-Konfigurationsverzeichnis existiert
mkdir -p services/prometheus/config

cat > services/prometheus/config/prometheus.yml << 'EOF'
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
    scheme: http
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

# 6. Erstelle init script das alles richtig initialisiert
echo -e "${BLUE}6. Erstelle verbessertes init-all.sh Script...${NC}"

cat > init-all.sh << 'EOF'
#!/bin/bash
set -e

# Farben für die Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Keine Farbe

echo -e "${BLUE}Synapticore Services Init Script${NC}"
echo -e "Dieses Script initialisiert alle Services und setzt die notwendigen Konfigurationen.\n"

# Prüfe, ob docker-compose läuft
if ! command -v docker-compose &> /dev/null; then
    if ! docker compose version &> /dev/null; then
        echo -e "${RED}Docker Compose nicht gefunden. Bitte zuerst Docker Compose installieren.${NC}"
        exit 1
    else
        DOCKER_COMPOSE="docker compose"
    fi
else
    DOCKER_COMPOSE="docker-compose"
fi

# Stoppe alle Container, falls sie bereits laufen
echo -e "${BLUE}Stoppe alle eventuell laufenden Container...${NC}"
$DOCKER_COMPOSE down

# Stelle sicher, dass alle Volumes richtig vorbereitet sind
echo -e "${BLUE}Erstelle leere Keep-Dateien in Vault-Volumes...${NC}"
$DOCKER_COMPOSE run --rm -v vault_data:/vault/data --entrypoint "bash" vault -c "touch /vault/data/.keep && chmod 777 /vault/data/.keep"
$DOCKER_COMPOSE run --rm -v vault_transit_data:/vault/data --entrypoint "bash" vault-transit -c "touch /vault/data/.keep && chmod 777 /vault/data/.keep"

# Starte Vault und Vault-Transit zuerst
echo -e "${BLUE}Starte Vault und Vault-Transit...${NC}"
$DOCKER_COMPOSE up -d vault vault-transit

# Warte, bis Vault bereit ist
echo -e "${YELLOW}Warte auf Vault...${NC}"
MAX_RETRIES=30
RETRY_COUNT=0

while ! docker exec vault curl -s http://127.0.0.1:8200/v1/sys/health > /dev/null 2>&1; do
    echo "Waiting for Vault to be ready... (Attempt $((RETRY_COUNT+1))/$MAX_RETRIES)"
    sleep 3
    RETRY_COUNT=$((RETRY_COUNT+1))
    
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo -e "${RED}Vault ist nach $MAX_RETRIES Versuchen nicht erreichbar. Zeige die Logs...${NC}"
        docker logs vault
        echo -e "${YELLOW}Versuche einen Neustart von Vault...${NC}"
        $DOCKER_COMPOSE restart vault
        sleep 10
        if ! docker exec vault curl -s http://127.0.0.1:8200/v1/sys/health > /dev/null 2>&1; then
            echo -e "${RED}Vault ist immer noch nicht erreichbar. Bitte manuell überprüfen.${NC}"
            exit 1
        fi
    fi
done

# Hole Vault Root Token
echo -e "${BLUE}Hole Vault Root Token...${NC}"
VAULT_TOKEN=$(docker exec vault cat /vault/data/root_token.txt 2>/dev/null || echo "")

if [ -z "$VAULT_TOKEN" ]; then
    echo -e "${YELLOW}Konnte Vault Root Token nicht abrufen. Versuche es nochmal...${NC}"
    sleep 5
    VAULT_TOKEN=$(docker exec vault cat /vault/data/root_token.txt 2>/dev/null || echo "")
    
    if [ -z "$VAULT_TOKEN" ]; then
        echo -e "${RED}Konnte Vault Root Token nicht abrufen. Vault wurde möglicherweise nicht korrekt initialisiert.${NC}"
        echo -e "${YELLOW}Zeige Vault-Logs:${NC}"
        docker logs vault
        exit 1
    fi
fi

echo -e "${GREEN}Vault Root Token: $VAULT_TOKEN${NC}"

# Kopiere Root Token für andere Services
echo -e "${BLUE}Kopiere Vault Token für andere Services...${NC}"
mkdir -p .vault-token
echo "$VAULT_TOKEN" > .vault-token/root_token.txt

# Starte den Rest der Services
echo -e "${BLUE}Starte übrige Services...${NC}"
$DOCKER_COMPOSE up -d

# Warte kurz bis alle Services gestartet sind
echo -e "${YELLOW}Warte, bis alle Services hochgefahren sind...${NC}"
sleep 10

# Zeige Status
echo -e "${BLUE}Service Status:${NC}"
$DOCKER_COMPOSE ps

# Sammle Zugangsdaten
echo -e "\n${BLUE}Zugangsdaten für Services:${NC}"

# MongoDB
echo -e "${YELLOW}MongoDB:${NC}"
MONGO_SECRET=$(docker exec vault curl -s -H "X-Vault-Token: $VAULT_TOKEN" http://127.0.0.1:8200/v1/secret/data/mongodb || echo '{"data":{"data":{}}}')
MONGO_USERNAME=$(echo $MONGO_SECRET | grep -o '"username":"[^"]*"' | cut -d':' -f2 | tr -d '"' || echo "admin")
MONGO_PASSWORD=$(echo $MONGO_SECRET | grep -o '"password":"[^"]*"' | cut -d':' -f2 | tr -d '"' || echo "Default-Passwort nicht gefunden")
echo "  Username: $MONGO_USERNAME"
echo "  Password: $MONGO_PASSWORD"
echo "  URL: mongodb://$MONGO_USERNAME:$MONGO_PASSWORD@localhost:27017/"

# Redis
echo -e "\n${YELLOW}Redis:${NC}"
REDIS_SECRET=$(docker exec vault curl -s -H "X-Vault-Token: $VAULT_TOKEN" http://127.0.0.1:8200/v1/secret/data/redis || echo '{"data":{"data":{}}}')
REDIS_PASSWORD=$(echo $REDIS_SECRET | grep -o '"password":"[^"]*"' | cut -d':' -f2 | tr -d '"' || echo "Default-Passwort nicht gefunden")
echo "  Password: $REDIS_PASSWORD"
echo "  URL: redis://:$REDIS_PASSWORD@localhost:6379/"

# Vault
echo -e "\n${YELLOW}Vault:${NC}"
echo "  Root Token: $VAULT_TOKEN"
echo "  URL: http://localhost:8200"

# Qdrant
echo -e "\n${YELLOW}Qdrant:${NC}"
echo "  URL: http://localhost:6333"

# Prometheus
echo -e "\n${YELLOW}Prometheus:${NC}"
echo "  URL: http://localhost:9090"

echo -e "\n${GREEN}Alle Services wurden erfolgreich initialisiert!${NC}"
echo -e "${BLUE}Du kannst nun die Synapticore Anwendung starten und mit den Services verbinden.${NC}"
echo -e "${YELLOW}Wichtig: Bewahre die Zugangsdaten sicher auf oder rufe sie später mit diesem Script erneut ab.${NC}"
EOF

chmod +x init-all.sh

# Abschluss-Nachricht
echo -e "\n${GREEN}Fix wurde erfolgreich angewendet!${NC}"
echo -e "${BLUE}Jetzt ausführen:${NC}"
echo -e "1. ${YELLOW}docker-compose down -v${NC} (um alle Container und Volumes zurückzusetzen)"
echo -e "2. ${YELLOW}./init-all.sh${NC} (um alles neu zu initialisieren)"
echo -e "\n${GREEN}Viel Erfolg!${NC}"
