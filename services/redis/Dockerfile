FROM redis:7.0.5-alpine

VOLUME /data

COPY config/redis.conf.template /usr/local/etc/redis/redis.conf.template
COPY scripts/startup.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/startup.sh

EXPOSE 6379

CMD ["/usr/local/bin/startup.sh"]
