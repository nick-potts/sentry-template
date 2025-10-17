#!/bin/bash

# Create Redis service
cat > services/redis/Dockerfile << 'EOF'
FROM redis:6.2.20-alpine

COPY redis.conf /usr/local/etc/redis/redis.conf

EXPOSE 6379

HEALTHCHECK --interval=30s --timeout=90s --retries=10 --start-period=10s \
  CMD redis-cli ping || exit 1

CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]
EOF

cat > services/redis/railway.toml << 'EOF'
[build]
builder = "DOCKERFILE"
dockerfilePath = "Dockerfile"

[deploy]
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10
EOF

cp shared/redis.conf services/redis/

# Create Memcached service
cat > services/memcached/Dockerfile << 'EOF'
FROM memcached:1.6.26-alpine

EXPOSE 11211

HEALTHCHECK --interval=30s --timeout=90s --retries=10 --start-period=10s \
  CMD echo stats | nc 127.0.0.1 11211 || exit 1

CMD ["-I", "50M"]
EOF

cat > services/memcached/railway.toml << 'EOF'
[build]
builder = "DOCKERFILE"
dockerfilePath = "Dockerfile"

[deploy]
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10
EOF

# Create Kafka service
cat > services/kafka/Dockerfile << 'EOF'
FROM confluentinc/cp-kafka:7.6.6

ENV KAFKA_PROCESS_ROLES=broker,controller
ENV KAFKA_CONTROLLER_QUORUM_VOTERS=1001@127.0.0.1:29093
ENV KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER
ENV KAFKA_NODE_ID=1001
ENV CLUSTER_ID=MkU3OEVBNTcwNTJENDM2Qk
ENV KAFKA_LISTENERS=PLAINTEXT://[::]:29092,INTERNAL://[::]:9093,EXTERNAL://[::]:9092,CONTROLLER://[::]:29093
ENV KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://127.0.0.1:29092,INTERNAL://[::]:9093,EXTERNAL://[::]:9092
ENV KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=PLAINTEXT:PLAINTEXT,INTERNAL:PLAINTEXT,EXTERNAL:PLAINTEXT,CONTROLLER:PLAINTEXT
ENV KAFKA_INTER_BROKER_LISTENER_NAME=PLAINTEXT
ENV KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1
ENV KAFKA_OFFSETS_TOPIC_NUM_PARTITIONS=1
ENV KAFKA_LOG_RETENTION_HOURS=24
ENV KAFKA_MESSAGE_MAX_BYTES=50000000
ENV KAFKA_MAX_REQUEST_SIZE=50000000
ENV CONFLUENT_SUPPORT_METRICS_ENABLE=false
ENV KAFKA_LOG4J_LOGGERS=kafka.cluster=WARN,kafka.controller=WARN,kafka.coordinator=WARN,kafka.log=WARN,kafka.server=WARN,state.change.logger=WARN
ENV KAFKA_LOG4J_ROOT_LOGLEVEL=WARN
ENV KAFKA_TOOLS_LOG4J_LOGLEVEL=WARN

EXPOSE 9092 9093 29092 29093

HEALTHCHECK --interval=10s --timeout=10s --retries=30 \
  CMD nc -z localhost 9092 || exit 1
EOF

cat > services/kafka/railway.toml << 'EOF'
[build]
builder = "DOCKERFILE"
dockerfilePath = "Dockerfile"

[deploy]
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10
EOF

# Create ClickHouse service
cat > services/clickhouse/Dockerfile << 'EOF'
FROM altinity/clickhouse-server:25.3.6.10034.altinitystable

COPY config.xml /etc/clickhouse-server/config.d/sentry.xml
COPY default-password.xml /etc/clickhouse-server/users.d/default-password.xml

ENV MAX_MEMORY_USAGE_RATIO=0.3

EXPOSE 8123 9000

HEALTHCHECK --interval=10s --timeout=10s --retries=30 \
  CMD wget -nv -t1 --spider 'http://localhost:8123/' || exit 1
EOF

cat > services/clickhouse/railway.toml << 'EOF'
[build]
builder = "DOCKERFILE"
dockerfilePath = "Dockerfile"

[deploy]
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10
EOF

cp shared/clickhouse/*.xml services/clickhouse/

# Create SeaweedFS service
cat > services/seaweedfs/Dockerfile << 'EOF'
FROM chrislusf/seaweedfs:3.96_large_disk

ENV AWS_ACCESS_KEY_ID=sentry
ENV AWS_SECRET_ACCESS_KEY=sentry

EXPOSE 8080 8333 8888 9333

HEALTHCHECK --interval=30s --timeout=20s --retries=5 --start-period=60s \
  CMD wget -q -O- http://localhost:8080/healthz http://localhost:9333/cluster/healthz http://localhost:8333/healthz || exit 1

ENTRYPOINT ["weed"]
CMD ["server", "-dir=/data", "-filer=true", "-filer.port=8888", "-filer.port.grpc=18888", \
     "-filer.defaultReplicaPlacement=000", "-master=true", "-master.port=9333", \
     "-master.port.grpc=19333", "-metricsPort=9091", "-s3=true", "-s3.port=8333", \
     "-s3.port.grpc=18333", "-volume=true", "-volume.dir.idx=/data/idx", \
     "-volume.index=leveldbLarge", "-volume.max=0", "-volume.preStopSeconds=8", \
     "-volume.readMode=redirect", "-volume.port=8080", "-volume.port.grpc=18080", \
     "-ip=[::1]", "-ip.bind=[::]", "-webdav=false"]
EOF

cat > services/seaweedfs/railway.toml << 'EOF'
[build]
builder = "DOCKERFILE"
dockerfilePath = "Dockerfile"

[deploy]
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10
EOF

# Create SMTP service
cat > services/smtp/Dockerfile << 'EOF'
FROM registry.gitlab.com/egos-tech/smtp

EXPOSE 25

HEALTHCHECK NONE
EOF

cat > services/smtp/railway.toml << 'EOF'
[build]
builder = "DOCKERFILE"
dockerfilePath = "Dockerfile"

[deploy]
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10
EOF

echo "Infrastructure services created successfully!"