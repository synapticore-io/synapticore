FROM alpine:3.17

ARG VAULT_VERSION=1.15.5

RUN apk add --no-cache curl unzip libcap && \
    curl -Lo /tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
    unzip /tmp/vault.zip -d /bin && \
    rm -f /tmp/vault.zip && \
    setcap cap_ipc_lock=+ep /bin/vault

VOLUME /vault/data
VOLUME /vault/config
VOLUME /vault/logs

EXPOSE 8200

COPY config/config.hcl /vault/config/config.hcl

ENTRYPOINT ["vault", "server", "-config=/vault/config/config.hcl"]
