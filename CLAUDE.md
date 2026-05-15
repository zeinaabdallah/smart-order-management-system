# CLAUDE.md — Project Conventions for SOMS

This file tells Claude Code how to behave when reviewing PRs, implementing features,
or answering questions in this repository.

## Project Overview

Smart Order Management System (SOMS) — a microservices backend built with:
- Java 21, Spring Boot 3.x, Spring Cloud
- Apache Kafka for async event-driven communication
- PostgreSQL (per-service databases), Redis (caching)
- Spring Cloud Gateway (API Gateway), Spring Cloud Config (centralized config)
- Docker Compose (local dev), Kubernetes (deployment)

## Architecture Rules

- **Each microservice owns its database.** No shared tables, no cross-service DB queries.
- **Inter-service communication** is async via Kafka events (preferred) or sync via REST (when necessary).
- **All external traffic** enters through the API Gateway. No service exposes its port publicly.
- **JWT auth** is validated at the Gateway. Individual services trust the Gateway's forwarded headers.

## Module Structure

```
soms/
├── config-server/
├── api-gateway/
├── auth-service/
├── product-service/
├── inventory-service/
├── order-service/
├── payment-service/
├── notification-service/
└── common/              # Shared DTOs, event schemas, utilities
```

## Code Conventions

### Java
- Use Java 21 features where appropriate (records, pattern matching, sealed classes)
- Constructor injection only (no @Autowired on fields)
- Use `@Valid` on all controller request bodies
- Return `ResponseEntity<>` from controllers, not raw objects
- Use DTOs for API input/output — never expose entity classes directly
- Package by feature, not by layer (e.g., `order.controller`, `order.service`, `order.repository`)

### REST API
- Follow REST naming conventions: plural nouns, no verbs in paths
- Use proper HTTP status codes (201 for creation, 204 for delete, 409 for conflicts)
- Paginated endpoints use Spring's `Pageable` with default page size 20
- All endpoints return consistent error responses: `{ "error": "...", "message": "...", "status": 400 }`

### Kafka
- Topic naming: `{domain}.{event}` (e.g., `orders.created`, `inventory.reserved`)
- All events include: `eventId` (UUID), `timestamp`, `correlationId`
- Consumers must be idempotent (check `processed_events` table before processing)
- Failed messages go to DLQ after 3 retries

### Database
- Flyway manages all schema migrations
- Migration naming: `V{number}__{description}.sql`
- Use optimistic locking (`@Version`) on contended entities (inventory, orders)
- Timestamps use `Instant` in Java, `TIMESTAMPTZ` in PostgreSQL

### Testing
- Unit tests for service layer logic
- Integration tests with Testcontainers (PostgreSQL, Kafka, Redis)
- Controller tests with `@WebMvcTest` + MockMvc
- Test class naming: `{ClassName}Test` for unit, `{ClassName}IT` for integration

## PR Review Guidelines

When reviewing PRs, prioritize:
1. **Correctness** — Does it work? Are edge cases handled?
2. **Security** — Auth checks, input validation, no secrets in code
3. **Consistency** — Does it follow the conventions above?
4. **Testability** — Are there sufficient tests? Are they meaningful?
5. **Kafka reliability** — Idempotency, error handling, DLQ routing

Don't nitpick formatting — that's what the linter is for.
