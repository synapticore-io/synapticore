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
