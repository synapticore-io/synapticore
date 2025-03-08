#!/bin/sh
set -e

# Lese das Redis-Passwort aus der Secret-Datei
REDIS_PASSWORD=$(cat /run/secrets/redis_password)

# Erstelle Redis-Konfiguration mit dem Passwort
sed "s/REDIS_PASSWORD_PLACEHOLDER/$REDIS_PASSWORD/g" /usr/local/etc/redis/redis.conf.template > /usr/local/etc/redis/redis.conf

# Starte Redis-Server
exec redis-server /usr/local/etc/redis/redis.conf
