#!/bin/bash

# Create base Sentry Dockerfile
cat > shared/Dockerfile.sentry << 'EOF'
FROM ghcr.io/getsentry/sentry:nightly

COPY sentry /etc/sentry
COPY geoip /geoip
COPY certificates /usr/local/share/ca-certificates

ENV PYTHONUSERBASE=/data/custom-packages
ENV SENTRY_CONF=/etc/sentry
ENV DEFAULT_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV GRPC_DEFAULT_SSL_ROOTS_FILE_PATH_ENV_VAR=/etc/ssl/certs/ca-certificates.crt

RUN update-ca-certificates

ENTRYPOINT ["/etc/sentry/entrypoint.sh"]
EOF

# Web service
cat > services/web/Dockerfile << 'EOF'
FROM ghcr.io/getsentry/sentry:nightly

COPY --from=shared /shared/sentry /etc/sentry
COPY --from=shared /shared/geoip /geoip
COPY --from=shared /shared/certificates /usr/local/share/ca-certificates

ENV PYTHONUSERBASE=/data/custom-packages
ENV SENTRY_CONF=/etc/sentry
ENV DEFAULT_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV GRPC_DEFAULT_SSL_ROOTS_FILE_PATH_ENV_VAR=/etc/ssl/certs/ca-certificates.crt

RUN update-ca-certificates

EXPOSE 9000

HEALTHCHECK --interval=30s --timeout=90s --retries=10 --start-period=10s \
  CMD /bin/bash -c 'exec 3<>/dev/tcp/127.0.0.1/9000 && echo -e "GET /_health/ HTTP/1.1\r\nhost: 127.0.0.1\r\n\r\n" >&3 && grep ok -s -m 1 <&3' || exit 1

ENTRYPOINT ["/etc/sentry/entrypoint.sh"]
CMD ["run", "web"]
EOF

cat > services/web/railway.toml << 'EOF'
[build]
builder = "DOCKERFILE"
dockerfilePath = "Dockerfile"
context = "../.."

[deploy]
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10
EOF

# Events consumer
cat > services/events-consumer/Dockerfile << 'EOF'
FROM ghcr.io/getsentry/sentry:nightly

COPY --from=shared /shared/sentry /etc/sentry
COPY --from=shared /shared/geoip /geoip
COPY --from=shared /shared/certificates /usr/local/share/ca-certificates

ENV PYTHONUSERBASE=/data/custom-packages
ENV SENTRY_CONF=/etc/sentry
ENV DEFAULT_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV GRPC_DEFAULT_SSL_ROOTS_FILE_PATH_ENV_VAR=/etc/ssl/certs/ca-certificates.crt

RUN update-ca-certificates

HEALTHCHECK --interval=60s --timeout=10s --retries=3 --start-period=600s \
  CMD test -f /tmp/health.txt || exit 1

ENTRYPOINT ["/etc/sentry/entrypoint.sh"]
CMD ["run", "consumer", "ingest-events", "--consumer-group", "ingest-consumer", "--healthcheck-file-path", "/tmp/health.txt"]
EOF

cat > services/events-consumer/railway.toml << 'EOF'
[build]
builder = "DOCKERFILE"
dockerfilePath = "Dockerfile"
context = "../.."

[deploy]
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10
EOF

# Attachments consumer
cat > services/attachments-consumer/Dockerfile << 'EOF'
FROM ghcr.io/getsentry/sentry:nightly

COPY --from=shared /shared/sentry /etc/sentry
COPY --from=shared /shared/geoip /geoip
COPY --from=shared /shared/certificates /usr/local/share/ca-certificates

ENV PYTHONUSERBASE=/data/custom-packages
ENV SENTRY_CONF=/etc/sentry
ENV DEFAULT_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV GRPC_DEFAULT_SSL_ROOTS_FILE_PATH_ENV_VAR=/etc/ssl/certs/ca-certificates.crt

RUN update-ca-certificates

HEALTHCHECK --interval=60s --timeout=10s --retries=3 --start-period=600s \
  CMD test -f /tmp/health.txt || exit 1

ENTRYPOINT ["/etc/sentry/entrypoint.sh"]
CMD ["run", "consumer", "ingest-attachments", "--consumer-group", "ingest-consumer", "--healthcheck-file-path", "/tmp/health.txt"]
EOF

cat > services/attachments-consumer/railway.toml << 'EOF'
[build]
builder = "DOCKERFILE"
dockerfilePath = "Dockerfile"
context = "../.."

[deploy]
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10
EOF

# Post process forwarder errors
cat > services/post-process-forwarder-errors/Dockerfile << 'EOF'
FROM ghcr.io/getsentry/sentry:nightly

COPY --from=shared /shared/sentry /etc/sentry
COPY --from=shared /shared/geoip /geoip
COPY --from=shared /shared/certificates /usr/local/share/ca-certificates

ENV PYTHONUSERBASE=/data/custom-packages
ENV SENTRY_CONF=/etc/sentry
ENV DEFAULT_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV GRPC_DEFAULT_SSL_ROOTS_FILE_PATH_ENV_VAR=/etc/ssl/certs/ca-certificates.crt

RUN update-ca-certificates

HEALTHCHECK --interval=60s --timeout=10s --retries=3 --start-period=600s \
  CMD test -f /tmp/health.txt || exit 1

ENTRYPOINT ["/etc/sentry/entrypoint.sh"]
CMD ["run", "consumer", "--no-strict-offset-reset", "post-process-forwarder-errors", "--consumer-group", "post-process-forwarder", "--synchronize-commit-log-topic=snuba-commit-log", "--synchronize-commit-group=snuba-consumers", "--healthcheck-file-path", "/tmp/health.txt"]
EOF

cat > services/post-process-forwarder-errors/railway.toml << 'EOF'
[build]
builder = "DOCKERFILE"
dockerfilePath = "Dockerfile"
context = "../.."

[deploy]
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10
EOF

echo "Sentry core services created!"