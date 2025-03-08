ui = true
disable_mlock = true

# Storage-Konfiguration
storage "raft" {
  path = "/vault/data"
  node_id = "vault_1"
}

# Listener-Konfiguration, TLS für einfachere Tests zunächst deaktiviert
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

api_addr = "http://0.0.0.0:8200"
cluster_addr = "http://0.0.0.0:8201"

# Performance und Stabilität
default_lease_ttl = "768h"
max_lease_ttl = "768h"

# Telemetrie
telemetry {
  prometheus_retention_time = "24h"
  disable_hostname = true
}

# Log Konfiguration
log_level = "info"
log_format = "json"
