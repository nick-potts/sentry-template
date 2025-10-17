FROM redis:6.2.20-alpine

COPY redis.conf /usr/local/etc/redis/redis.conf

EXPOSE 6379

HEALTHCHECK --interval=30s --timeout=60s --retries=5 --start-period=90s \
  CMD redis-cli ping || exit 1