FROM memcached:1.6.26-alpine

EXPOSE 11211

HEALTHCHECK --interval=30s --timeout=90s --retries=10 --start-period=10s \
  CMD echo stats | nc 127.0.0.1 11211 || exit 1

CMD ["-I", "50M"]
