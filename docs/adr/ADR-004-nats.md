# ADR-004: NATS JetStream

## Context
Modules need asynchronous events with local operational simplicity.

## Decision
Use NATS JetStream for event delivery.

## Alternatives
Use a hosted broker or direct synchronous calls.

## Consequences
Event streams are durable while remaining lightweight locally.
