FROM alpine:3.17

ARG VAULT_VERSION=1.15.5

RUN apk add --no-cache curl unzip libcap openssl jq bash wget && \
    curl -Lo /tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
    unzip /tmp/vault.zip -d /bin && \
    rm -f /tmp/vault.zip && \
    setcap cap_ipc_lock=+ep /bin/vault

VOLUME /vault/data
VOLUME /vault/config
VOLUME /vault/logs
VOLUME /vault/tls

EXPOSE 8200
EXPOSE 8201

COPY config/config.hcl /vault/config/config.hcl
COPY scripts/init-vault.sh /vault/init-vault.sh
COPY scripts/setup-secrets.sh /vault/setup-secrets.sh

RUN chmod +x /vault/init-vault.sh /vault/setup-secrets.sh

# Fixed entrypoint to properly run the server and initialization
ENTRYPOINT ["/bin/bash", "-c", "/bin/vault server -config=/vault/config/config.hcl & sleep 10 && /vault/init-vault.sh && /vault/setup-secrets.sh && wait"]
