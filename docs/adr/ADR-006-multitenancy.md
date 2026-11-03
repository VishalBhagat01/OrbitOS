# ADR-006: Shared-schema multi-tenancy

## Context
Multiple tenants share infrastructure while requiring database isolation.

## Decision
Use `tenant_id` as the PostgreSQL RLS isolation boundary and `company_id` as
an additional business authorization scope. Tenant context must come from
trusted authentication context, not arbitrary request input.

## Alternatives
Separate databases or schemas per tenant.

## Consequences
Operations remain manageable, but RLS policies and context propagation are mandatory.
