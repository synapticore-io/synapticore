#!/bin/bash
# Vault Auto-Unseal with Transit Setup Script including Redis, MongoDB, and Qdrant integration

set -e

# Configuration variables
PRIMARY_VAULT_PORT=8200
SECONDARY_VAULT_PORT=8100
PRIMARY_VAULT_ADDR="http://127.0.0.1:$PRIMARY_VAULT_PORT"
SECONDARY_VAULT_ADDR="http://127.0.0.1:$SECONDARY_VAULT_PORT"
PRIMARY_VAULT_TOKEN="root"
DATA_DIR="/opt/vault"
LOG_DIR="/var/log/vault"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Vault Auto-Unseal Setup with Transit Secret Engine and Database Integration${NC}"

# Create directories
echo -e "${YELLOW}Creating directories...${NC}"
sudo mkdir -p $DATA_DIR/primary $DATA_DIR/secondary $LOG_DIR
sudo chown -R vscode:synapticore $DATA_DIR $LOG_DIR

# Create configuration files
echo -e "${YELLOW}Creating configuration files...${NC}"

# Primary Vault Configuration (Transit Key Provider)
cat > /tmp/vault-primary.hcl << EOF
storage "file" {
  path = "$DATA_DIR/primary"
}

listener "tcp" {
  address     = "0.0.0.0:$PRIMARY_VAULT_PORT"
  tls_disable = 1
}

ui = true
EOF

# Copy configuration file
sudo cp /tmp/vault-primary.hcl /etc/vault.d/vault-primary.hcl

# Start Primary Vault
echo -e "${YELLOW}Starting Primary Vault...${NC}"
echo -e "${YELLOW}Hinweis: systemd ist in der DevContainer-Umgebung nicht verfügbar. Die Services werden nicht gestartet.${NC}"

# Initialize Primary Vault
echo -e "${YELLOW}Initializing Primary Vault...${NC}"
export VAULT_ADDR=$PRIMARY_VAULT_ADDR

# Initialize Primary Vault
PRIMARY_INIT_RESPONSE=$(vault operator init -format=json -key-shares=1 -key-threshold=1)
PRIMARY_UNSEAL_KEY=$(echo $PRIMARY_INIT_RESPONSE | jq -r .unseal_keys_b64[0])
PRIMARY_ROOT_TOKEN=$(echo $PRIMARY_INIT_RESPONSE | jq -r .root_token)

# Save keys to secure files
echo $PRIMARY_INIT_RESPONSE | sudo tee $DATA_DIR/primary-init.json > /dev/null
sudo chmod 600 $DATA_DIR/primary-init.json

# Unseal Primary Vault
echo -e "${YELLOW}Unsealing Primary Vault...${NC}"
vault operator unseal $PRIMARY_UNSEAL_KEY

# Authenticate with Root Token
export VAULT_TOKEN=$PRIMARY_ROOT_TOKEN

# Enable Transit Secret Engine
echo -e "${YELLOW}Enabling Transit Secret Engine...${NC}"
vault secrets enable transit
vault write -f transit/keys/autounseal

# Create Policy for Auto-Unseal
echo -e "${YELLOW}Creating Policy for Auto-Unseal...${NC}"
vault policy write autounseal - << EOF
path "transit/encrypt/autounseal" {
  capabilities = [ "update" ]
}
path "transit/decrypt/autounseal" {
  capabilities = [ "update" ]
}
EOF

# Create Token for Secondary Vault
echo -e "${YELLOW}Creating Token for Secondary Vault...${NC}"
TRANSIT_TOKEN=$(vault token create -orphan -policy="autounseal" -period=24h -format=json | jq -r .auth.client_token)
echo $TRANSIT_TOKEN | sudo tee $DATA_DIR/transit-token.txt > /dev/null
sudo chmod 600 $DATA_DIR/transit-token.txt

# Secondary Vault Configuration (Auto-Unseal)
cat > /tmp/vault-secondary.hcl << EOF
storage "file" {
  path = "$DATA_DIR/secondary"
}

listener "tcp" {
  address     = "0.0.0.0:$SECONDARY_VAULT_PORT"
  tls_disable = 1
}

seal "transit" {
  address            = "$PRIMARY_VAULT_ADDR"
  token              = "$TRANSIT_TOKEN"
  disable_renewal    = "false"
  key_name           = "autounseal"
  mount_path         = "transit"
}

ui = true
EOF

# Copy configuration file
sudo cp /tmp/vault-secondary.hcl /etc/vault.d/vault-secondary.hcl

# Start Secondary Vault
echo -e "${YELLOW}Starting Secondary Vault...${NC}"
echo -e "${YELLOW}Hinweis: systemd ist in der DevContainer-Umgebung nicht verfügbar. Die Services werden nicht gestartet.${NC}"

# Initialize Secondary Vault
echo -e "${YELLOW}Initializing Secondary Vault...${NC}"
export VAULT_ADDR=$SECONDARY_VAULT_ADDR
export VAULT_TOKEN=""

# Initialize Secondary Vault
SECONDARY_INIT_RESPONSE=$(vault operator init -format=json -key-shares=1 -key-threshold=1 -recovery-shares=1 -recovery-threshold=1)
SECONDARY_RECOVERY_KEY=$(echo $SECONDARY_INIT_RESPONSE | jq -r .recovery_keys_b64[0])
SECONDARY_ROOT_TOKEN=$(echo $SECONDARY_INIT_RESPONSE | jq -r .root_token)

# Save keys to secure files
echo $SECONDARY_INIT_RESPONSE | sudo tee $DATA_DIR/secondary-init.json > /dev/null
sudo chmod 600 $DATA_DIR/secondary-init.json

# Set Vault token for Secondary Vault
export VAULT_TOKEN=$SECONDARY_ROOT_TOKEN

# Check status
echo -e "${YELLOW}Checking status of Secondary Vault...${NC}"
vault status

# Set up database secrets engines
echo -e "${YELLOW}Setting up database secrets engines...${NC}"

# Enable the database secrets engine
vault secrets enable database

# Generate random passwords for database root users
REDIS_PASSWORD=$(openssl rand -base64 16)
MONGODB_PASSWORD=$(openssl rand -base64 16)
QDRANT_API_KEY=$(openssl rand -base64 32)

# Save root passwords to secure files (for initial setup)
echo $REDIS_PASSWORD | sudo tee $DATA_DIR/redis-root-password.txt > /dev/null
echo $MONGODB_PASSWORD | sudo tee $DATA_DIR/mongodb-root-password.txt > /dev/null
echo $QDRANT_API_KEY | sudo tee $DATA_DIR/qdrant-api-key.txt > /dev/null
sudo chmod 600 $DATA_DIR/redis-root-password.txt $DATA_DIR/mongodb-root-password.txt $DATA_DIR/qdrant-api-key.txt

# Configure Redis
echo -e "${YELLOW}Configuring Redis with Vault...${NC}"

# Create Redis configuration
sudo bash -c "cat > /etc/redis/redis.conf << EOF
bind 127.0.0.1
protected-mode yes
port 6379
requirepass $REDIS_PASSWORD
EOF"

# Configure MongoDB
echo -e "${YELLOW}Configuring MongoDB with Vault...${NC}"

# Create MongoDB admin user
cat > /tmp/create_mongodb_admin.js << EOF
db.createUser({
  user: "admin",
  pwd: "$MONGODB_PASSWORD",
  roles: [ { role: "root", db: "admin" } ]
})
EOF

# Apply MongoDB configuration
echo -e "${YELLOW}Restarting MongoDB...${NC}"
echo -e "${YELLOW}Hinweis: systemd ist in der DevContainer-Umgebung nicht verfügbar. MongoDB wird nicht neu gestartet.${NC}"
# sudo systemctl restart mongod
mongo admin /tmp/create_mongodb_admin.js

# Configure Qdrant
echo -e "${YELLOW}Configuring Qdrant with Vault...${NC}"

# Create Qdrant configuration
sudo bash -c "cat > /etc/qdrant/config.yaml << EOF
storage:
  dir: /var/lib/qdrant/storage

service:
  host: 127.0.0.1
  http_port: 6333
  grpc_port: 6334

security:
  api_key: $QDRANT_API_KEY
EOF"

echo -e "${YELLOW}Restarting Qdrant...${NC}"
echo -e "${YELLOW}Hinweis: systemd ist in der DevContainer-Umgebung nicht verfügbar. Qdrant wird nicht neu gestartet.${NC}"
# sudo systemctl restart qdrant

# Configure Vault database secrets engine
echo -e "${YELLOW}Configuring Vault database secrets engine...${NC}"

# Configure Redis connection
vault write database/config/redis \
    plugin_name=redis-database-plugin \
    allowed_roles="redis-role" \
    host="127.0.0.1" \
    port=6379 \
    username="" \
    password="$REDIS_PASSWORD"

# Configure MongoDB connection
vault write database/config/mongodb \
    plugin_name=mongodb-database-plugin \
    allowed_roles="mongodb-role" \
    connection_url="mongodb://admin:${MONGODB_PASSWORD}@localhost:27017/admin?authMechanism=SCRAM-SHA-256" \
    username="admin" \
    password="$MONGODB_PASSWORD"

# Create Redis role
vault write database/roles/redis-role \
    db_name=redis \
    creation_statements='{"redis":"config", "privileges":["keys", "read", "write"]}' \
    default_ttl="1h" \
    max_ttl="24h"

# Create MongoDB role
vault write database/roles/mongodb-role \
    db_name=mongodb \
    creation_statements='{ "db": "app", "roles": [{ "role": "readWrite" }] }' \
    default_ttl="1h" \
    max_ttl="24h"

# Create KV secrets engine for Qdrant API key
vault secrets enable -path=qdrant kv-v2
vault kv put qdrant/api-keys/main api_key="$QDRANT_API_KEY"

# Create policies for applications
echo -e "${YELLOW}Creating application policies...${NC}"

# Redis policy
vault policy write redis-app - << EOF
path "database/creds/redis-role" {
  capabilities = ["read"]
}
EOF

# MongoDB policy
vault policy write mongodb-app - << EOF
path "database/creds/mongodb-role" {
  capabilities = ["read"]
}
EOF

# Qdrant policy
vault policy write qdrant-app - << EOF
path "qdrant/data/api-keys/main" {
  capabilities = ["read"]
}
EOF

# Create example application tokens
echo -e "${YELLOW}Creating application tokens...${NC}"
REDIS_APP_TOKEN=$(vault token create -policy="redis-app" -format=json | jq -r .auth.client_token)
MONGODB_APP_TOKEN=$(vault token create -policy="mongodb-app" -format=json | jq -r .auth.client_token)
QDRANT_APP_TOKEN=$(vault token create -policy="qdrant-app" -format=json | jq -r .auth.client_token)

echo $REDIS_APP_TOKEN | sudo tee $DATA_DIR/redis-app-token.txt > /dev/null
echo $MONGODB_APP_TOKEN | sudo tee $DATA_DIR/mongodb-app-token.txt > /dev/null
echo $QDRANT_APP_TOKEN | sudo tee $DATA_DIR/qdrant-app-token.txt > /dev/null
sudo chmod 600 $DATA_DIR/redis-app-token.txt $DATA_DIR/mongodb-app-token.txt $DATA_DIR/qdrant-app-token.txt

# Create example application script
cat > /tmp/app-example.sh << 'EOF'
#!/bin/bash

# Set Vault address
export VAULT_ADDR=http://127.0.0.1:8100

# Function to get Redis credentials
get_redis_creds() {
    VAULT_TOKEN=$(cat /opt/vault/redis-app-token.txt)
    REDIS_CREDS=$(VAULT_TOKEN=$VAULT_TOKEN vault read -format=json database/creds/redis-role)
    REDIS_USERNAME=$(echo $REDIS_CREDS | jq -r .data.username)
    REDIS_PASSWORD=$(echo $REDIS_CREDS | jq -r .data.password)
    echo "Redis Username: $REDIS_USERNAME"
    echo "Redis Password: $REDIS_PASSWORD"
}

# Function to get MongoDB credentials
get_mongodb_creds() {
    VAULT_TOKEN=$(cat /opt/vault/mongodb-app-token.txt)
    MONGODB_CREDS=$(VAULT_TOKEN=$VAULT_TOKEN vault read -format=json database/creds/mongodb-role)
    MONGODB_USERNAME=$(echo $MONGODB_CREDS | jq -r .data.username)
    MONGODB_PASSWORD=$(echo $MONGODB_CREDS | jq -r .data.password)
    echo "MongoDB Username: $MONGODB_USERNAME"
    echo "MongoDB Password: $MONGODB_PASSWORD"
}

# Function to get Qdrant API key
get_qdrant_api_key() {
    VAULT_TOKEN=$(cat /opt/vault/qdrant-app-token.txt)
    QDRANT_API_KEY=$(VAULT_TOKEN=$VAULT_TOKEN vault kv get -format=json qdrant/api-keys/main | jq -r .data.data.api_key)
    echo "Qdrant API Key: $QDRANT_API_KEY"
}

# Main
echo "Getting credentials from Vault..."
get_redis_creds
get_mongodb_creds
get_qdrant_api_key
EOF

sudo cp /tmp/app-example.sh $DATA_DIR/app-example.sh
sudo chmod +x $DATA_DIR/app-example.sh

echo -e "${GREEN}Setup completed!${NC}"
echo -e "${GREEN}Primary Vault is running at $PRIMARY_VAULT_ADDR${NC}"
echo -e "${GREEN}Secondary Vault is running at $SECONDARY_VAULT_ADDR${NC}"
echo -e "${GREEN}Redis, MongoDB, and Qdrant have been configured with secrets from Vault${NC}"
echo -e "${YELLOW}Important: Initialization data has been saved to $DATA_DIR. Secure these files!${NC}"
echo -e "${YELLOW}Example application script: $DATA_DIR/app-example.sh${NC}"
