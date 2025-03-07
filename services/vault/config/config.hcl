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
