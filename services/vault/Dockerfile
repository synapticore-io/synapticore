FROM alpine:3.17

ARG VAULT_VERSION=1.15.5

RUN apk add --no-cache curl unzip libcap openssl jq bash wget && \
    curl -Lo /tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
    unzip /tmp/vault.zip -d /bin && \
    rm -f /tmp/vault.zip && \
    setcap cap_ipc_lock=+ep /bin/vault

# Create necessary directories
RUN mkdir -p /vault/data /vault/config /vault/logs /vault/tls

VOLUME /vault/data
VOLUME /vault/logs
VOLUME /vault/tls

EXPOSE 8200
EXPOSE 8201

COPY config/config.hcl /vault/config/config.hcl
COPY scripts/init-vault.sh /vault/init-vault.sh
COPY scripts/generate-tls.sh /vault/generate-tls.sh

RUN chmod +x /vault/init-vault.sh && \
    chmod +x /vault/generate-tls.sh

# Hinzufügen eines Reset-Skripts, um Initialisierungsprobleme zu beheben
COPY scripts/reset-vault.sh /vault/reset-vault.sh
RUN chmod +x /vault/reset-vault.sh

# Hinzufügen eines Startup-Skripts, das alles koordiniert
COPY scripts/startup.sh /vault/startup.sh
RUN chmod +x /vault/startup.sh

# Verwenden des Startup-Skripts als Entrypoint
ENTRYPOINT ["/vault/startup.sh"]
