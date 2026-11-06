import {
  pgTable,
  pgEnum,
  uuid,
  varchar,
  text,
  jsonb,
  boolean,
  timestamp,
  uniqueIndex,
} from "drizzle-orm/pg-core";

import { tenants } from "./tenant.schema";
import { users } from "./user.schema";

export const agentStatusEnum = pgEnum(
  "agent_status",
  [
    "draft",
    "enabled",
    "disabled",
    "deprecated",
  ]
);

// Agent identity
export const agents = pgTable(
  "agents",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    tenantId: uuid("tenant_id")
      .notNull()
      .references(() => tenants.id),

    name: varchar("name", { length: 150 })
      .notNull(),

    slug: varchar("slug", { length: 150 })
      .notNull(),

    description: text("description"),

    status: agentStatusEnum("status")
      .default("draft")
      .notNull(),

    createdBy: uuid("created_by")
      .references(() => users.id),

    createdAt: timestamp("created_at", {
      withTimezone: true,
    }).defaultNow().notNull(),

    updatedAt: timestamp("updated_at", {
      withTimezone: true,
    }).defaultNow().notNull(),
  },
  (table) => [
    uniqueIndex("agents_tenant_slug_idx")
      .on(table.tenantId, table.slug),

    uniqueIndex("agents_tenant_id_id_idx")
      .on(table.tenantId, table.id),
  ]
);

// Agent versions
export const agentVersions = pgTable(
  "agent_versions",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    agentId: uuid("agent_id")
      .notNull()
      .references(() => agents.id, {
        onDelete: "cascade",
      }),

    version: varchar("version", {
      length: 50,
    }).notNull(),

    inputSchema: jsonb("input_schema")
      .$type<Record<string, unknown>>()
      .notNull(),

    outputSchema: jsonb("output_schema")
      .$type<Record<string, unknown>>()
      .notNull(),

    definition: jsonb("definition")
      .$type<Record<string, unknown>>()
      .notNull(),

    createdAt: timestamp("created_at", {
      withTimezone: true,
    }).defaultNow().notNull(),
  },
  (table) => [
    uniqueIndex("agent_version_unique_idx")
      .on(table.agentId, table.version),
  ]
);

// Agent capabilities
export const agentCapabilities = pgTable(
  "agent_capabilities",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    agentId: uuid("agent_id")
      .notNull()
      .references(() => agents.id, {
        onDelete: "cascade",
      }),

    capability: varchar("capability", {
      length: 150,
    }).notNull(),

    description: text("description"),

    createdAt: timestamp("created_at", {
      withTimezone: true,
    }).defaultNow().notNull(),
  },
  (table) => [
    uniqueIndex("agent_capability_unique_idx")
      .on(table.agentId, table.capability),
  ]
);

// Agent tool permissions
export const agentToolPermissions = pgTable(
  "agent_tool_permissions",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    agentId: uuid("agent_id")
      .notNull()
      .references(() => agents.id, {
        onDelete: "cascade",
      }),

    toolKey: varchar("tool_key", {
      length: 150,
    }).notNull(),

    permissionKey: varchar("permission_key", {
      length: 150,
    }).notNull(),

    enabled: boolean("enabled")
      .default(false)
      .notNull(),

    createdAt: timestamp("created_at", {
      withTimezone: true,
    }).defaultNow().notNull(),
  },
  (table) => [
    uniqueIndex("agent_tool_permission_unique_idx")
      .on(table.agentId, table.toolKey),
  ]
);