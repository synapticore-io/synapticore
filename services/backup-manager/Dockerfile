FROM alpine:3.17

RUN apk add --no-cache bash docker-cli jq curl openssl gzip tar mongodb-tools redis coreutils     && mkdir -p /scripts /backup-data

COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

VOLUME /backup-data
VOLUME /backup

ENTRYPOINT ["/scripts/entrypoint.sh"]
