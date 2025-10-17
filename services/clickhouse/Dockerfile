FROM altinity/clickhouse-server:25.3.6.10034.altinitystable

COPY config.xml /etc/clickhouse-server/config.d/sentry.xml
COPY default-password.xml /etc/clickhouse-server/users.d/default-password.xml

ENV MAX_MEMORY_USAGE_RATIO=0.3

EXPOSE 8123 9000

HEALTHCHECK --interval=10s --timeout=10s --retries=30 \
  CMD wget -nv -t1 --spider 'http://localhost:8123/' || exit 1
