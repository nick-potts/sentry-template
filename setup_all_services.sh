#!/bin/bash

# Remove old Dockerfiles we don't need
rm -f services/postgres/Dockerfile
rm -f services/pgbouncer/Dockerfile
rm -f services/memcached/Dockerfile
rm -f services/kafka/Dockerfile
rm -f services/smtp/Dockerfile
rm -f services/seaweedfs/Dockerfile

# PostgreSQL - use image directly
cat > services/postgres/railway.toml << 'EOF'
[deploy]
image = "postgres:14.19-bookworm"
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10

[variables]
POSTGRES_HOST_AUTH_METHOD = "trust"
POSTGRES_USER = "postgres"
POSTGRES_DB = "sentry"
EOF

# PgBouncer
cat > services/pgbouncer/railway.toml << 'EOF'
[deploy]
image = "edoburu/pgbouncer:v1.24.1-p1"
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10

[variables]
DB_USER = "postgres"
DB_HOST = "${{Postgres.RAILWAY_PRIVATE_DOMAIN}}"
DB_NAME = "postgres"
AUTH_TYPE = "trust"
POOL_MODE = "transaction"
ADMIN_USERS = "postgres,sentry"
MAX_CLIENT_CONN = "10000"
EOF

# Redis - needs config file, so use Dockerfile
cat > services/redis/railway.toml << 'EOF'
[build]
builder = "DOCKERFILE"
dockerfilePath = "./services/redis/Dockerfile"

[deploy]
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10
EOF

# Memcached
cat > services/memcached/railway.toml << 'EOF'
[deploy]
image = "memcached:1.6.26-alpine"
startCommand = "memcached -I 50M"
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10
EOF

# Kafka
cat > services/kafka/railway.toml << 'EOF'
[deploy]
image = "confluentinc/cp-kafka:7.6.6"
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10

[variables]
KAFKA_PROCESS_ROLES = "broker,controller"
KAFKA_CONTROLLER_QUORUM_VOTERS = "1001@127.0.0.1:29093"
KAFKA_CONTROLLER_LISTENER_NAMES = "CONTROLLER"
KAFKA_NODE_ID = "1001"
CLUSTER_ID = "MkU3OEVBNTcwNTJENDM2Qk"
KAFKA_LISTENERS = "PLAINTEXT://[::]:29092,INTERNAL://[::]:9093,EXTERNAL://[::]:9092,CONTROLLER://[::]:29093"
KAFKA_ADVERTISED_LISTENERS = "PLAINTEXT://127.0.0.1:29092,INTERNAL://[::]:9093,EXTERNAL://[::]:9092"
KAFKA_LISTENER_SECURITY_PROTOCOL_MAP = "PLAINTEXT:PLAINTEXT,INTERNAL:PLAINTEXT,EXTERNAL:PLAINTEXT,CONTROLLER:PLAINTEXT"
KAFKA_INTER_BROKER_LISTENER_NAME = "PLAINTEXT"
KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR = "1"
KAFKA_OFFSETS_TOPIC_NUM_PARTITIONS = "1"
KAFKA_LOG_RETENTION_HOURS = "24"
KAFKA_MESSAGE_MAX_BYTES = "50000000"
KAFKA_MAX_REQUEST_SIZE = "50000000"
CONFLUENT_SUPPORT_METRICS_ENABLE = "false"
KAFKA_LOG4J_LOGGERS = "kafka.cluster=WARN,kafka.controller=WARN,kafka.coordinator=WARN,kafka.log=WARN,kafka.server=WARN,state.change.logger=WARN"
KAFKA_LOG4J_ROOT_LOGLEVEL = "WARN"
KAFKA_TOOLS_LOG4J_LOGLEVEL = "WARN"
EOF

# ClickHouse - needs config files
cat > services/clickhouse/railway.toml << 'EOF'
[build]
builder = "DOCKERFILE"
dockerfilePath = "./services/clickhouse/Dockerfile"

[deploy]
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10

[variables]
MAX_MEMORY_USAGE_RATIO = "0.3"
EOF

# SeaweedFS
cat > services/seaweedfs/railway.toml << 'EOF'
[deploy]
image = "chrislusf/seaweedfs:3.96_large_disk"
startCommand = "weed server -dir=/data -filer=true -filer.port=8888 -filer.port.grpc=18888 -filer.defaultReplicaPlacement=000 -master=true -master.port=9333 -master.port.grpc=19333 -metricsPort=9091 -s3=true -s3.port=8333 -s3.port.grpc=18333 -volume=true -volume.dir.idx=/data/idx -volume.index=leveldbLarge -volume.max=0 -volume.preStopSeconds=8 -volume.readMode=redirect -volume.port=8080 -volume.port.grpc=18080 -ip=[::1] -ip.bind=[::] -webdav=false"
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10

[variables]
AWS_ACCESS_KEY_ID = "sentry"
AWS_SECRET_ACCESS_KEY = "sentry"
EOF

# SMTP
cat > services/smtp/railway.toml << 'EOF'
[deploy]
image = "registry.gitlab.com/egos-tech/smtp"
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10

[variables]
MAILNAME = "${{SENTRY_MAIL_HOST}}"
EOF

# Symbolicator
cat > services/symbolicator/railway.toml << 'EOF'
[deploy]
image = "ghcr.io/getsentry/symbolicator:nightly"
startCommand = "run -c /etc/symbolicator/config.yml"
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10
EOF

# Symbolicator Cleanup
cat > services/symbolicator-cleanup/railway.toml << 'EOF'
[deploy]
image = "ghcr.io/getsentry/symbolicator:nightly"
startCommand = "cleanup -c /etc/symbolicator/config.yml --repeat 1h"
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10
EOF

# Relay
cat > services/relay/railway.toml << 'EOF'
[deploy]
image = "ghcr.io/getsentry/relay:nightly"
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10
EOF

# Vroom
cat > services/vroom/railway.toml << 'EOF'
[deploy]
image = "ghcr.io/getsentry/vroom:nightly"
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10

[variables]
SENTRY_KAFKA_BROKERS_PROFILING = "${{Kafka.RAILWAY_PRIVATE_DOMAIN}}:9092"
SENTRY_KAFKA_BROKERS_OCCURRENCES = "${{Kafka.RAILWAY_PRIVATE_DOMAIN}}:9092"
SENTRY_BUCKET_PROFILES = "file:///var/vroom/sentry-profiles"
SENTRY_SNUBA_HOST = "http://${{SnubaApi.RAILWAY_PRIVATE_DOMAIN}}:1218"
EOF

# TaskBroker
cat > services/taskbroker/railway.toml << 'EOF'
[deploy]
image = "ghcr.io/getsentry/taskbroker:nightly"
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10

[variables]
TASKBROKER_KAFKA_CLUSTER = "${{Kafka.RAILWAY_PRIVATE_DOMAIN}}:9092"
TASKBROKER_KAFKA_DEADLETTER_CLUSTER = "${{Kafka.RAILWAY_PRIVATE_DOMAIN}}:9092"
TASKBROKER_DB_PATH = "/opt/sqlite/taskbroker-activations.sqlite"
EOF

# Uptime Checker
cat > services/uptime-checker/railway.toml << 'EOF'
[deploy]
image = "ghcr.io/getsentry/uptime-checker:nightly"
startCommand = "run"
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10

[variables]
UPTIME_CHECKER_RESULTS_KAFKA_CLUSTER = "${{Kafka.RAILWAY_PRIVATE_DOMAIN}}:9092"
UPTIME_CHECKER_REDIS_HOST = "redis://${{Redis.RAILWAY_PRIVATE_DOMAIN}}:6379"
UPTIME_CHECKER_ALLOW_INTERNAL_IPS = "false"
UPTIME_CHECKER_FAILURE_RETRIES = "1"
EOF

# Snuba API
cat > services/snuba-api/railway.toml << 'EOF'
[deploy]
image = "ghcr.io/getsentry/snuba:nightly"
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10

[variables]
SNUBA_SETTINGS = "self_hosted"
CLICKHOUSE_HOST = "${{Clickhouse.RAILWAY_PRIVATE_DOMAIN}}"
DEFAULT_BROKERS = "${{Kafka.RAILWAY_PRIVATE_DOMAIN}}:9092"
REDIS_HOST = "${{Redis.RAILWAY_PRIVATE_DOMAIN}}"
UWSGI_MAX_REQUESTS = "10000"
UWSGI_DISABLE_LOGGING = "true"
EOF

# Web service - main Sentry
cat > services/web/railway.toml << 'EOF'
[deploy]
image = "ghcr.io/getsentry/sentry:nightly"
startCommand = "run web"
restartPolicyType = "ALWAYS"
restartPolicyMaxRetries = 10

[variables]
PYTHONUSERBASE = "/data/custom-packages"
SENTRY_CONF = "/etc/sentry"
SNUBA = "http://${{SnubaApi.RAILWAY_PRIVATE_DOMAIN}}:1218"
VROOM = "http://${{Vroom.RAILWAY_PRIVATE_DOMAIN}}:8085"
SENTRY_EVENT_RETENTION_DAYS = "90"
EOF

echo "All services configured!"