ui = true
disable_mlock = true

# Hochverfügbare Konfiguration
cluster_name = "vault-cluster"

# Verbesserte Datenspeicherung mit Integrated Storage (Raft)
storage "raft" {
  path = "/vault/data"
  node_id = "vault_1"
}

# TLS-Konfiguration für sichere Kommunikation
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_cert_file = "/vault/tls/vault.crt"
  tls_key_file  = "/vault/tls/vault.key"
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