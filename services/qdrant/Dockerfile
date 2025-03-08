FROM qdrant/qdrant:v1.5.0

# Create directories for configuration and certificates
RUN mkdir -p /qdrant/config /qdrant/tls

VOLUME /qdrant/storage
VOLUME /qdrant/tls

COPY config/config.yaml /qdrant/config/
COPY scripts/generate-tls.sh /qdrant/
COPY scripts/entrypoint.sh /qdrant/

RUN chmod +x /qdrant/generate-tls.sh /qdrant/entrypoint.sh

EXPOSE 6333
EXPOSE 6334

ENTRYPOINT ["/qdrant/entrypoint.sh"]
