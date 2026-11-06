-- ORBIT OS - Phase 1 database foundation
-- PostgreSQL 16+ / pgvector-compatible
--
-- IMPORTANT:
-- 1. This is a fresh-install initial migration. Do not run it on a database
--    where the earlier 0000_nervous_gunslinger.sql migration was already applied.
-- 2. If the earlier migration has NOT been applied, replace it with this file
--    and update the Drizzle migration journal through drizzle-kit generate.
-- 3. Run as a schema-migration owner. The application role must NOT be a
--    superuser and must NOT have BYPASSRLS.
-- 4. Set app.current_tenant transaction-locally after verifying membership.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ---------------------------------------------------------------------------
-- ENUMS
-- ---------------------------------------------------------------------------

CREATE TYPE public.tenant_status AS ENUM ('active', 'suspended', 'disabled');
CREATE TYPE public.user_status AS ENUM ('active', 'inactive', 'suspended');
CREATE TYPE public.membership_status AS ENUM ('invited', 'active', 'suspended');
CREATE TYPE public.role_scope AS ENUM ('tenant', 'company');
CREATE TYPE public.agent_status AS ENUM ('draft', 'enabled', 'disabled', 'deprecated');

-- ---------------------------------------------------------------------------
-- CORE IDENTITY AND TENANCY
-- Users are global identities. TenantMembership grants access to a tenant.
-- ---------------------------------------------------------------------------

CREATE TABLE public.tenants (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name varchar(255) NOT NULL,
    slug varchar(100) NOT NULL,
    status public.tenant_status NOT NULL DEFAULT 'active',
    settings jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT tenants_slug_unique UNIQUE (slug)
);

CREATE TABLE public.users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email varchar(255) NOT NULL,
    password_hash varchar(255) NOT NULL,
    full_name varchar(255) NOT NULL,
    status public.user_status NOT NULL DEFAULT 'active',
    email_verified boolean NOT NULL DEFAULT false,
    mfa_enabled boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT users_email_unique UNIQUE (email)
);

CREATE TABLE public.tenant_memberships (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    status public.membership_status NOT NULL DEFAULT 'invited',
    joined_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT tenant_memberships_tenant_fk
        FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT,
    CONSTRAINT tenant_memberships_user_fk
        FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE RESTRICT,
    CONSTRAINT tenant_memberships_tenant_user_unique UNIQUE (tenant_id, user_id),
    CONSTRAINT tenant_memberships_tenant_id_id_unique UNIQUE (tenant_id, id)
);

-- ---------------------------------------------------------------------------
-- COMPANIES AND MEMBERSHIPS
-- ---------------------------------------------------------------------------

CREATE TABLE public.companies (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL,
    name varchar(255) NOT NULL,
    legal_name varchar(255) NOT NULL,
    registration_number varchar(100),
    gstin varchar(15),
    financial_year_start_month integer NOT NULL DEFAULT 4,
    currency varchar(3) NOT NULL DEFAULT 'INR',
    timezone varchar(100) NOT NULL DEFAULT 'Asia/Kolkata',
    settings jsonb NOT NULL DEFAULT '{}'::jsonb,
    is_active boolean NOT NULL DEFAULT true,
    created_by uuid,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT companies_tenant_fk
        FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT,
    CONSTRAINT companies_creator_membership_fk
        FOREIGN KEY (tenant_id, created_by)
        REFERENCES public.tenant_memberships(tenant_id, user_id)
        ON DELETE RESTRICT,
    CONSTRAINT companies_financial_year_month_check
        CHECK (financial_year_start_month BETWEEN 1 AND 12),
    CONSTRAINT companies_tenant_id_id_unique UNIQUE (tenant_id, id)
);

CREATE TABLE public.company_memberships (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL,
    company_id uuid NOT NULL,
    user_id uuid NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    joined_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT company_memberships_company_tenant_fk
        FOREIGN KEY (tenant_id, company_id)
        REFERENCES public.companies(tenant_id, id) ON DELETE CASCADE,
    CONSTRAINT company_memberships_tenant_user_fk
        FOREIGN KEY (tenant_id, user_id)
        REFERENCES public.tenant_memberships(tenant_id, user_id) ON DELETE CASCADE,
    CONSTRAINT company_memberships_unique
        UNIQUE (tenant_id, company_id, user_id),
    CONSTRAINT company_memberships_tenant_id_id_unique UNIQUE (tenant_id, id)
);

-- ---------------------------------------------------------------------------
-- RBAC
-- Permissions are global catalogue entries. Roles and assignments are
-- tenant-scoped. RolePermissions carries tenant_id to support direct RLS.
-- ---------------------------------------------------------------------------

CREATE TABLE public.permissions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    key varchar(150) NOT NULL,
    description text,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT permissions_key_unique UNIQUE (key)
);

CREATE TABLE public.roles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL,
    company_id uuid,
    name varchar(100) NOT NULL,
    description text,
    scope public.role_scope NOT NULL DEFAULT 'tenant',
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT roles_tenant_fk
        FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT,
    CONSTRAINT roles_company_tenant_fk
        FOREIGN KEY (tenant_id, company_id)
        REFERENCES public.companies(tenant_id, id) ON DELETE RESTRICT,
    CONSTRAINT roles_scope_company_check CHECK (
        (scope = 'tenant' AND company_id IS NULL)
        OR
        (scope = 'company' AND company_id IS NOT NULL)
    ),
    CONSTRAINT roles_tenant_id_id_unique UNIQUE (tenant_id, id)
);

CREATE TABLE public.role_permissions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL,
    role_id uuid NOT NULL,
    permission_id uuid NOT NULL,
    CONSTRAINT role_permissions_role_tenant_fk
        FOREIGN KEY (tenant_id, role_id)
        REFERENCES public.roles(tenant_id, id) ON DELETE CASCADE,
    CONSTRAINT role_permissions_permission_fk
        FOREIGN KEY (permission_id)
        REFERENCES public.permissions(id) ON DELETE CASCADE,
    CONSTRAINT role_permissions_unique UNIQUE (tenant_id, role_id, permission_id),
    CONSTRAINT role_permissions_tenant_id_id_unique UNIQUE (tenant_id, id)
);

CREATE TABLE public.user_roles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role_id uuid NOT NULL,
    company_id uuid,
    assigned_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT user_roles_tenant_user_fk
        FOREIGN KEY (tenant_id, user_id)
        REFERENCES public.tenant_memberships(tenant_id, user_id) ON DELETE CASCADE,
    CONSTRAINT user_roles_tenant_role_fk
        FOREIGN KEY (tenant_id, role_id)
        REFERENCES public.roles(tenant_id, id) ON DELETE CASCADE,
    CONSTRAINT user_roles_tenant_company_fk
        FOREIGN KEY (tenant_id, company_id)
        REFERENCES public.companies(tenant_id, id) ON DELETE CASCADE,
    CONSTRAINT user_roles_unique
        UNIQUE NULLS NOT DISTINCT (tenant_id, user_id, role_id, company_id),
    CONSTRAINT user_roles_tenant_id_id_unique UNIQUE (tenant_id, id)
);

-- A role assignment must match the role's declared scope and company.
CREATE FUNCTION public.enforce_user_role_scope()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    assigned_scope public.role_scope;
    assigned_company_id uuid;
BEGIN
    SELECT scope, company_id
      INTO assigned_scope, assigned_company_id
      FROM public.roles
     WHERE tenant_id = NEW.tenant_id
       AND id = NEW.role_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Role % does not exist in tenant %', NEW.role_id, NEW.tenant_id
            USING ERRCODE = '23503';
    END IF;

    IF assigned_scope = 'tenant' AND NEW.company_id IS NOT NULL THEN
        RAISE EXCEPTION 'Tenant-scoped role cannot be assigned to a company'
            USING ERRCODE = '23514';
    END IF;

    IF assigned_scope = 'company'
       AND NEW.company_id IS DISTINCT FROM assigned_company_id THEN
        RAISE EXCEPTION 'Company-scoped role must be assigned to its configured company'
            USING ERRCODE = '23514';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER user_roles_scope_guard
BEFORE INSERT OR UPDATE OF tenant_id, role_id, company_id
ON public.user_roles
FOR EACH ROW EXECUTE FUNCTION public.enforce_user_role_scope();

-- ---------------------------------------------------------------------------
-- AGENT REGISTRY
-- Agent child tables carry tenant_id so RLS can be applied directly.
-- ---------------------------------------------------------------------------

CREATE TABLE public.agents (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL,
    name varchar(150) NOT NULL,
    slug varchar(150) NOT NULL,
    description text,
    status public.agent_status NOT NULL DEFAULT 'draft',
    created_by uuid,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT agents_tenant_fk
        FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT,
    CONSTRAINT agents_creator_membership_fk
        FOREIGN KEY (tenant_id, created_by)
        REFERENCES public.tenant_memberships(tenant_id, user_id) ON DELETE RESTRICT,
    CONSTRAINT agents_tenant_slug_unique UNIQUE (tenant_id, slug),
    CONSTRAINT agents_tenant_id_id_unique UNIQUE (tenant_id, id)
);

CREATE TABLE public.agent_versions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL,
    agent_id uuid NOT NULL,
    version varchar(50) NOT NULL,
    input_schema jsonb NOT NULL,
    output_schema jsonb NOT NULL,
    definition jsonb NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT agent_versions_agent_tenant_fk
        FOREIGN KEY (tenant_id, agent_id)
        REFERENCES public.agents(tenant_id, id) ON DELETE CASCADE,
    CONSTRAINT agent_versions_unique UNIQUE (tenant_id, agent_id, version),
    CONSTRAINT agent_versions_tenant_id_id_unique UNIQUE (tenant_id, id)
);

CREATE TABLE public.agent_capabilities (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL,
    agent_id uuid NOT NULL,
    capability varchar(150) NOT NULL,
    description text,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT agent_capabilities_agent_tenant_fk
        FOREIGN KEY (tenant_id, agent_id)
        REFERENCES public.agents(tenant_id, id) ON DELETE CASCADE,
    CONSTRAINT agent_capabilities_unique UNIQUE (tenant_id, agent_id, capability),
    CONSTRAINT agent_capabilities_tenant_id_id_unique UNIQUE (tenant_id, id)
);

CREATE TABLE public.agent_tool_permissions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL,
    agent_id uuid NOT NULL,
    tool_key varchar(150) NOT NULL,
    permission_key varchar(150) NOT NULL,
    enabled boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT agent_tool_permissions_agent_tenant_fk
        FOREIGN KEY (tenant_id, agent_id)
        REFERENCES public.agents(tenant_id, id) ON DELETE CASCADE,
    CONSTRAINT agent_tool_permissions_permission_fk
        FOREIGN KEY (permission_key)
        REFERENCES public.permissions(key) ON DELETE RESTRICT,
    CONSTRAINT agent_tool_permissions_unique UNIQUE (tenant_id, agent_id, tool_key),
    CONSTRAINT agent_tool_permissions_tenant_id_id_unique UNIQUE (tenant_id, id)
);

-- ---------------------------------------------------------------------------
-- INDEXES
-- ---------------------------------------------------------------------------

CREATE INDEX tenant_memberships_user_idx ON public.tenant_memberships(user_id);
CREATE INDEX companies_tenant_idx ON public.companies(tenant_id);
CREATE INDEX company_memberships_user_idx ON public.company_memberships(tenant_id, user_id);
CREATE INDEX roles_tenant_idx ON public.roles(tenant_id);
CREATE INDEX role_permissions_permission_idx ON public.role_permissions(permission_id);
CREATE INDEX user_roles_user_idx ON public.user_roles(tenant_id, user_id);
CREATE INDEX agents_tenant_idx ON public.agents(tenant_id);
CREATE INDEX agent_versions_agent_idx ON public.agent_versions(tenant_id, agent_id);
CREATE INDEX agent_capabilities_agent_idx ON public.agent_capabilities(tenant_id, agent_id);
CREATE INDEX agent_tool_permissions_agent_idx ON public.agent_tool_permissions(tenant_id, agent_id);

-- ---------------------------------------------------------------------------
-- ROW LEVEL SECURITY
-- app.current_tenant must be set transaction-locally only after the API has
-- authenticated the user and verified active tenant membership.
-- ---------------------------------------------------------------------------

CREATE FUNCTION public.current_tenant_id()
RETURNS uuid
LANGUAGE sql
STABLE
AS $$
    SELECT NULLIF(current_setting('app.current_tenant', true), '')::uuid;
$$;

ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenants FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON public.tenants
    USING (id = public.current_tenant_id())
    WITH CHECK (id = public.current_tenant_id());

ALTER TABLE public.tenant_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenant_memberships FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON public.tenant_memberships
    USING (tenant_id = public.current_tenant_id())
    WITH CHECK (tenant_id = public.current_tenant_id());

ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.companies FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON public.companies
    USING (tenant_id = public.current_tenant_id())
    WITH CHECK (tenant_id = public.current_tenant_id());

ALTER TABLE public.company_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.company_memberships FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON public.company_memberships
    USING (tenant_id = public.current_tenant_id())
    WITH CHECK (tenant_id = public.current_tenant_id());

ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON public.roles
    USING (tenant_id = public.current_tenant_id())
    WITH CHECK (tenant_id = public.current_tenant_id());

ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON public.role_permissions
    USING (tenant_id = public.current_tenant_id())
    WITH CHECK (tenant_id = public.current_tenant_id());

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON public.user_roles
    USING (tenant_id = public.current_tenant_id())
    WITH CHECK (tenant_id = public.current_tenant_id());

ALTER TABLE public.agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.agents FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON public.agents
    USING (tenant_id = public.current_tenant_id())
    WITH CHECK (tenant_id = public.current_tenant_id());

ALTER TABLE public.agent_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.agent_versions FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON public.agent_versions
    USING (tenant_id = public.current_tenant_id())
    WITH CHECK (tenant_id = public.current_tenant_id());

ALTER TABLE public.agent_capabilities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.agent_capabilities FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON public.agent_capabilities
    USING (tenant_id = public.current_tenant_id())
    WITH CHECK (tenant_id = public.current_tenant_id());

ALTER TABLE public.agent_tool_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.agent_tool_permissions FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON public.agent_tool_permissions
    USING (tenant_id = public.current_tenant_id())
    WITH CHECK (tenant_id = public.current_tenant_id());

-- Users and permissions are global identity/catalogue tables. They are not
-- tenant-filtered here; tenant access is mediated through memberships and
-- application authorization. Never expose password_hash to clients.

COMMIT;
