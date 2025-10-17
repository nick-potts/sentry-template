FROM edoburu/pgbouncer:v1.24.1-p1

ENV DB_USER=postgres
ENV DB_HOST=postgres.railway.internal
ENV DB_NAME=postgres
ENV AUTH_TYPE=trust
ENV POOL_MODE=transaction
ENV ADMIN_USERS=postgres,sentry
ENV MAX_CLIENT_CONN=10000

EXPOSE 5432

HEALTHCHECK --interval=30s --timeout=90s --retries=10 --start-period=10s \
  CMD psql -U postgres -p 5432 -h 127.0.0.1 -tA -c "select 1;" -d postgres >/dev/null || exit 1