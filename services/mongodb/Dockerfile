FROM mongo:6.0

VOLUME /data/db
VOLUME /data/configdb

EXPOSE 27017

COPY config/mongod.conf /etc/mongod.conf

CMD ["mongod", "--config", "/etc/mongod.conf"]
