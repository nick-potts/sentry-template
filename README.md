# Sentry Railway Monorepo

This is a monorepo structure for deploying Sentry on Railway with all services properly configured for Railway's networking and deployment model.

## Structure

```
sentry-template/
├── services/
│   ├── postgres/       # PostgreSQL database
│   ├── redis/          # Redis cache
│   ├── kafka/          # Kafka message broker
│   ├── clickhouse/     # ClickHouse analytics DB
│   ├── web/            # Sentry web application
│   ├── nginx/          # Nginx reverse proxy
│   ├── snuba-api/      # Snuba API service
│   └── ...             # Other services
├── shared/             # Shared configurations
│   ├── sentry/         # Sentry config files
│   ├── config/         # Shared config files
│   └── scripts/        # Shared scripts
└── railway.json        # Railway project configuration
```

## Deployment on Railway

1. Create a new Railway project
2. Connect this GitHub repository
3. Railway will detect the monorepo structure
4. For each service, set the "Root Directory" in service settings:
   - `services/postgres` for PostgreSQL
   - `services/redis` for Redis
   - `services/web` for Sentry Web
   - etc.

## Service Communication

All services communicate via Railway's private IPv6 network:
- Use `${{SERVICE_NAME.RAILWAY_PRIVATE_DOMAIN}}` for internal communication
- Services are only accessible internally unless explicitly exposed

## Environment Variables

Each service gets its environment variables from:
1. Railway's service variables (database URLs, etc.)
2. Shared configuration files in `/shared`
3. Service-specific `railway.toml` files

## Key Services

### Core Infrastructure
- **PostgreSQL**: Main database
- **Redis**: Cache and queues
- **Kafka**: Event streaming
- **ClickHouse**: Analytics database

### Sentry Services
- **Web**: Main Sentry application
- **Workers**: Background job processors
- **Consumers**: Event consumers
- **Snuba**: Event storage and retrieval

### Supporting Services
- **Nginx**: Reverse proxy and load balancer
- **Symbolicator**: Debug symbol processing
- **Relay**: Event ingestion