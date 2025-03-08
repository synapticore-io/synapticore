FROM alpine:3.17

# Install necessary tools including AWS CLI for S3 uploads
RUN apk add --no-cache bash docker-cli jq curl openssl gzip tar mongodb-tools redis coreutils aws-cli \
    && mkdir -p /scripts /backup-data

COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

VOLUME /backup-data
VOLUME /backup
VOLUME /secrets

ENTRYPOINT ["/scripts/entrypoint.sh"]
