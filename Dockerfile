ARG REDIS_VERSION=7.4.0
FROM redis:${REDIS_VERSION}-alpine

COPY start-redis-server.sh /usr/local/bin/

CMD ["start-redis-server.sh"]