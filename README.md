# Smart Order Management System (SOMS)

A production-style microservices backend built with Spring Boot 3, Kafka, and Kubernetes.

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│   Client    │────▶│  API Gateway │────▶│ auth-service │
└─────────────┘     └──────┬───────┘     └──────────────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
       product-service  order-service  inventory-service
                              │
                         Kafka broker
                    ┌─────────┴─────────┐
                    ▼                   ▼
            payment-service   notification-service
```

## Modules

| Module | Description |
|---|---|
| `common` | Shared DTOs, exceptions, and utilities |
| `config-server` | Centralised Spring Cloud Config Server |
| `api-gateway` | Spring Cloud Gateway — routing & JWT filter |
| `auth-service` | Registration, login, JWT issuance |
| `product-service` | Product & category catalogue _(Phase 2)_ |
| `inventory-service` | Stock reservation & tracking _(Phase 2)_ |
| `order-service` | Order lifecycle state machine _(Phase 3)_ |
| `payment-service` | Payment processing via Kafka _(Phase 3)_ |
| `notification-service` | Event-driven notifications _(Phase 3)_ |

## Tech Stack

- **Java 21** · **Spring Boot 3.4** · **Spring Cloud 2024**
- **PostgreSQL** · **Flyway** · **Redis**
- **Apache Kafka** · **Testcontainers**
- **Docker Compose** · **Kubernetes** · **OpenTelemetry**

## Quick Start

### Prerequisites

- Java 21+
- Docker & Docker Compose
- Maven 3.9+

### Run locally

```bash
# Start infrastructure
docker compose up -d

# Build all modules
mvn clean install -DskipTests

# Start a service (example)
mvn -pl auth-service spring-boot:run
```

## Development Roadmap

See [ROADMAP.md](ROADMAP.md) for the full phased plan.
