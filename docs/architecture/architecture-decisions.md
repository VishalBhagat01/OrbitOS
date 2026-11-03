# ORBIT OS — Architecture Decisions

## 1. Architecture Style
Modular Monolith with independently runnable processes.

## 2. Backend
NestJS + TypeScript strict mode.

## 3. Agent Runtime
LangGraph.js + LangChain.js.

## 4. Workflow Orchestration
Temporal for durable business workflows.
LangGraph for agent-level execution graphs.

## 5. Event Architecture
NATS JetStream for asynchronous domain events.

Event naming:
domain.entity.action

Examples:
invoice.received
agent.created
workflow.started
approval.requested

All event contracts must be versioned.

## 6. Database
PostgreSQL + pgvector.

Drizzle ORM for database access.

Redis for caching and ephemeral coordination.

## 7. Multi-tenancy
Shared database.
Shared schema.
tenant_id on tenant-owned records.
PostgreSQL Row-Level Security.

Company-level authorization within each tenant.

## 8. Object Storage
MinIO for local development.
S3-compatible storage interface for production.

## 9. Observability
Pino + OpenTelemetry.

Every request and workflow should support:
- correlationId
- traceId
- tenantId
- actorId

## 10. Testing
Vitest + Testcontainers.

## 11. Infrastructure
Docker Compose for local development.

Kubernetes is not required during Phase 0.