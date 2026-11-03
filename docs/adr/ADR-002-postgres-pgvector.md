# ADR-002: PostgreSQL and pgvector

## Context
Relational data and vector search are needed before graph-specific workloads.

## Decision
Use PostgreSQL with pgvector before introducing a graph database.

## Alternatives
Add a graph database in Phase 0.

## Consequences
Fewer services and one transactional data boundary.
