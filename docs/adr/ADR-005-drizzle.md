# ADR-005: Drizzle ORM

## Context
Database access should remain typed and SQL-transparent.

## Decision
Use Drizzle ORM for PostgreSQL access and migrations.

## Alternatives
Use a heavier data mapper.

## Consequences
Schema and queries stay close to PostgreSQL semantics.
