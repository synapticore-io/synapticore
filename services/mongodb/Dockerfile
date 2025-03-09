FROM mongo:6.0

VOLUME /data/db
VOLUME /data/configdb
VOLUME /var/log/mongodb

EXPOSE 27017

COPY config/mongod.conf /etc/mongod.conf
COPY scripts/init-mongodb.sh /docker-entrypoint-initdb.d/

CMD ["mongod", "--config", "/etc/mongod.conf"]
