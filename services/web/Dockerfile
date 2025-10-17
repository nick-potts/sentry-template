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

EXPOSE 9000

HEALTHCHECK --interval=30s --timeout=90s --retries=10 --start-period=10s \
  CMD /bin/bash -c 'exec 3<>/dev/tcp/127.0.0.1/9000 && echo -e "GET /_health/ HTTP/1.1\r\nhost: 127.0.0.1\r\n\r\n" >&3 && grep ok -s -m 1 <&3' || exit 1

ENTRYPOINT ["/etc/sentry/entrypoint.sh"]
CMD ["run", "web"]
