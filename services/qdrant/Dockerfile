FROM qdrant/qdrant:v1.1.1

VOLUME /qdrant/storage
VOLUME /qdrant/config

EXPOSE 6333
EXPOSE 6334

COPY ./config/config.yaml /qdrant/config/config.yaml

CMD ["./qdrant", "--config-path", "/qdrant/config/config.yaml"]
