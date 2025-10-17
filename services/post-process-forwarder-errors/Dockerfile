FROM ghcr.io/getsentry/sentry:nightly

COPY shared/sentry /etc/sentry
COPY shared/geoip /geoip
COPY shared/certificates /usr/local/share/ca-certificates

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
