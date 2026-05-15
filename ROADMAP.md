# Smart Order Management System — Roadmap

> Spring Boot · Kafka · Microservices · Kubernetes · OpenTelemetry

---

## Phase 1 — Foundation (1–2 weeks)

### Project Setup

- [x] Initialize multi-module Maven project (parent POM + child modules)
- [x] Define common dependencies & BOM (Spring Boot 3.x, Java 21)
- [x] Set up .gitignore, README, and repo structure
- [x] Add Flyway for database migrations from day one

### Config Server

- [ ] Create spring-cloud-config-server module
- [ ] Set up Git-backed config repo (or local file-based for dev)
- [ ] Add configs for each future service (application-{service}.yml)
- [ ] Test config server startup and endpoint responses

### API Gateway

- [ ] Create Spring Cloud Gateway module
- [ ] Define routes for auth-service (and placeholder routes for future services)
- [ ] Add global CORS configuration
- [ ] Add request logging filter (middleware)
- [ ] Configure gateway to pull config from Config Server

### Auth Service

- [ ] Create auth-service module with Spring Security
- [ ] Design user table (id, email, password_hash, role, timestamps)
- [ ] Implement POST /auth/register (BCrypt password hashing)
- [ ] Implement POST /auth/login (return JWT access + refresh tokens)
- [ ] Implement POST /auth/refresh (refresh token rotation)
- [ ] Add role-based access (USER, ADMIN) with JWT claims
- [ ] Write JwtTokenProvider utility class
- [ ] Add JWT validation filter to API Gateway (global filter)
- [ ] Write unit tests for auth logic
- [ ] Write integration tests with Testcontainers (PostgreSQL)

### Docker Compose (v1)

- [ ] Write docker-compose.yml with PostgreSQL and Redis
- [ ] Add container for Config Server
- [ ] Add container for API Gateway
- [ ] Add container for Auth Service
- [ ] Verify full flow: register → login → hit protected endpoint via gateway

---

## Phase 2 — Core Business Services (2–3 weeks)

### Product / Catalog Service

- [ ] Create product-service module
- [ ] Design tables: products, categories (with FK relationships)
- [ ] Implement full CRUD endpoints for products
- [ ] Implement CRUD for categories
- [ ] Add pagination & sorting (Spring Data Pageable)
- [ ] Add filtering / search by name, category, price range
- [ ] Add Bean Validation on all request DTOs
- [ ] Add Redis caching on product reads (@Cacheable)
- [ ] Configure cache eviction on product updates
- [ ] Register routes in API Gateway
- [ ] Write integration tests with Testcontainers

### Inventory Service

- [ ] Create inventory-service module
- [ ] Design inventory table (product_id, quantity, reserved, warehouse)
- [ ] Implement GET /inventory/{productId} (available stock)
- [ ] Implement PUT /inventory/{productId}/reserve (reserve N units)
- [ ] Implement PUT /inventory/{productId}/release (release reserved units)
- [ ] Implement PUT /inventory/{productId}/restock
- [ ] Add optimistic locking (@Version) to prevent race conditions
- [ ] Register routes in API Gateway
- [ ] Write integration tests with Testcontainers

### Synchronous Communication

- [ ] Add RestClient / WebClient in Product Service to call Inventory Service
- [ ] Enrich GET /products/{id} response with real-time stock availability
- [ ] Add timeout configuration on inter-service calls
- [ ] Handle inventory service unavailability gracefully (fallback response)

### Docker Compose (v2)

- [ ] Add Product Service and Inventory Service to docker-compose.yml
- [ ] Add separate PostgreSQL databases per service (or schemas)
- [ ] Verify end-to-end: create product → check stock → cached response

---

## Phase 3 — Kafka & Event-Driven Architecture (2–3 weeks)

### Kafka Infrastructure

- [ ] Add Kafka + Zookeeper (or KRaft) to docker-compose.yml
- [ ] Add kafka-ui container for topic inspection
- [ ] Define topic naming convention (e.g. orders.created, inventory.reserved)
- [ ] Create shared event schema module (DTOs / Avro schemas for events)
- [ ] Configure Spring Kafka producer/consumer in each service

### Order Service

- [ ] Create order-service module
- [ ] Design tables: orders, order_items (with status enum / state machine)
- [ ] Implement POST /orders (place order → publish OrderCreated event)
- [ ] Implement GET /orders/{id} and GET /orders?userId=
- [ ] Implement order state machine: CREATED → CONFIRMED → SHIPPED → DELIVERED / CANCELLED
- [ ] Consume InventoryReserved → advance to CONFIRMED
- [ ] Consume InventoryInsufficient → advance to CANCELLED
- [ ] Consume PaymentCompleted → advance to SHIPPED
- [ ] Consume PaymentFailed → advance to CANCELLED
- [ ] Register routes in API Gateway
- [ ] Write integration tests with embedded Kafka (Testcontainers)

### Inventory Service (event-driven additions)

- [ ] Consume OrderCreated → attempt stock reservation
- [ ] Publish InventoryReserved on success
- [ ] Publish InventoryInsufficient on failure
- [ ] Handle duplicate OrderCreated messages (idempotency key)

### Payment Service

- [ ] Create payment-service module
- [ ] Design payments table (order_id, amount, status, provider, timestamps)
- [ ] Consume InventoryReserved → simulate payment processing (random delay)
- [ ] Publish PaymentCompleted or PaymentFailed
- [ ] Implement GET /payments/{orderId} for payment status lookup
- [ ] Handle duplicate events idempotently

### Notification Service

- [ ] Create notification-service module
- [ ] Consume all order lifecycle events from Kafka
- [ ] Log simulated email/SMS notifications (or integrate with a free email API)
- [ ] Store notification history in DB
- [ ] Implement GET /notifications?userId= endpoint

### End-to-End Validation

- [ ] Place one order via REST and trace full async flow through Kafka UI
- [ ] Verify happy path: order → inventory reserved → payment → notification
- [ ] Verify failure path: order → inventory insufficient → cancellation → notification
- [ ] Verify payment failure: order → reserved → payment failed → stock released → notification

---

## Phase 4 — Resilience & Observability (1–2 weeks)

### Resilience4j

- [ ] Add circuit breaker on Gateway → downstream service calls
- [ ] Add circuit breaker on Order Service → Inventory Service (sync fallback)
- [ ] Configure retry with exponential backoff on transient failures
- [ ] Add rate limiting at the API Gateway level
- [ ] Add bulkhead isolation for critical endpoints
- [ ] Write tests that simulate downstream failures and verify fallbacks

### Distributed Tracing

- [ ] Add OpenTelemetry SDK to every service
- [ ] Add Jaeger container to docker-compose.yml
- [ ] Configure trace propagation across REST calls (W3C trace context)
- [ ] Configure trace propagation across Kafka messages (headers)
- [ ] Verify: place an order and view full trace in Jaeger UI
- [ ] Add custom spans for business-critical operations

### Centralized Logging

- [ ] Choose stack: ELK (Elasticsearch + Logstash + Kibana) or Grafana + Loki
- [ ] Add logging containers to docker-compose.yml
- [ ] Configure structured JSON logging in all services (Logback)
- [ ] Include traceId and spanId in every log line
- [ ] Create a dashboard to search logs across all services

### Health & Metrics

- [ ] Enable Spring Boot Actuator on all services (/health, /info, /metrics)
- [ ] Expose Prometheus metrics endpoint
- [ ] Add Prometheus + Grafana to docker-compose.yml
- [ ] Create Grafana dashboard: request rates, error rates, latencies per service
- [ ] Add custom business metrics (orders placed/min, payment success rate)

---

## Phase 5 — Advanced Patterns (2–3 weeks)

### Saga Pattern (Choreography)

- [ ] Map the full order saga with compensating transactions
- [ ] Implement compensation: PaymentFailed → publish InventoryRelease event
- [ ] Implement compensation: OrderCancelled → release inventory + refund payment
- [ ] Add saga status tracking (saga_log table in Order Service)
- [ ] Handle timeout scenarios (order stuck in CREATED for too long)
- [ ] Test: kill Payment Service mid-flow, restart, verify saga completes

### Transactional Outbox Pattern

- [ ] Add outbox table to Order Service (event_type, payload, published_at)
- [ ] Write order + outbox entry in a single DB transaction
- [ ] Option A: Polling publisher — background job reads outbox, publishes to Kafka
- [ ] Option B: Debezium CDC — streams outbox table changes to Kafka automatically
- [ ] Verify exactly-once semantics: no lost or duplicate events

### Dead Letter Queue & Error Handling

- [ ] Configure DLQ topics for each consumer group
- [ ] Route messages that fail after N retries to DLQ
- [ ] Build a simple admin endpoint to inspect / replay DLQ messages
- [ ] Add alerting (log-based) when messages land in DLQ

### Idempotency

- [ ] Add idempotency key to all Kafka event schemas
- [ ] Implement deduplication check in each consumer (processed_events table)
- [ ] Test: publish duplicate events and verify single processing

---

## Phase 6 — Containerization & CI/CD (1–2 weeks)

### Dockerfiles

- [ ] Write multi-stage Dockerfile for each service (build + runtime)
- [ ] Optimize image size (use Eclipse Temurin JRE slim base)
- [ ] Add .dockerignore to each module
- [ ] Verify all services build and run as containers independently

### Kubernetes Manifests

- [ ] Write Deployment + Service YAML for each microservice
- [ ] Create ConfigMaps for non-sensitive config
- [ ] Create Secrets for DB passwords, JWT secret, etc.
- [ ] Add Horizontal Pod Autoscaler (HPA) for Order Service
- [ ] Configure readiness and liveness probes (wired to Actuator)
- [ ] Write Ingress or Gateway API resource for external access

### CI/CD Pipeline

- [ ] Set up GitHub Actions workflow
- [ ] Step: compile and run unit tests
- [ ] Step: run integration tests with Testcontainers
- [ ] Step: build Docker images
- [ ] Step: push images to container registry (GHCR or Docker Hub)
- [ ] Step: (optional) deploy to K8s cluster with kubectl apply
- [ ] Add branch protection rules on main

### Final Validation

- [ ] Deploy entire system to a local Kind/Minikube cluster
- [ ] Run full end-to-end order flow on Kubernetes
- [ ] Verify tracing, logging, and metrics work in K8s environment
- [ ] Write project README with architecture diagram and setup instructions
- [ ] Record a demo walkthrough or write a blog post about the project
