FROM postgres:14.19-bookworm

ENV POSTGRES_HOST_AUTH_METHOD=trust
ENV POSTGRES_USER=postgres
ENV POSTGRES_DB=sentry

EXPOSE 5432

HEALTHCHECK --interval=30s --timeout=90s --retries=10 --start-period=10s \
  CMD pg_isready -U ${POSTGRES_USER:-postgres} || exit 1