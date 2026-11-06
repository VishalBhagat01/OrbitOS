import {
  pgTable,
  pgEnum,
  uuid,
  varchar,
  text,
  timestamp,
  uniqueIndex,
} from "drizzle-orm/pg-core";

import { tenants } from "./tenant.schema";
import { users } from "./user.schema";
import { companies } from "./company.schema";

export const roleScopeEnum = pgEnum("role_scope", [
  "tenant",
  "company",
]);

// Roles
export const roles = pgTable(
  "roles",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    tenantId: uuid("tenant_id")
      .notNull()
      .references(() => tenants.id),

    companyId: uuid("company_id")
      .references(() => companies.id),

    name: varchar("name", { length: 100 })
      .notNull(),

    description: text("description"),

    scope: roleScopeEnum("scope")
      .default("tenant")
      .notNull(),

    createdAt: timestamp("created_at", {
      withTimezone: true,
    }).defaultNow().notNull(),
  },
  (table) => [
    uniqueIndex("roles_tenant_id_id_idx")
      .on(table.tenantId, table.id),
  ]
);

// Permissions
export const permissions = pgTable("permissions", {
  id: uuid("id").defaultRandom().primaryKey(),

  key: varchar("key", { length: 150 })
    .notNull()
    .unique(),

  description: text("description"),

  createdAt: timestamp("created_at", {
    withTimezone: true,
  }).defaultNow().notNull(),
});

// Role-Permission relationship
export const rolePermissions = pgTable(
  "role_permissions",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    roleId: uuid("role_id")
      .notNull()
      .references(() => roles.id, {
        onDelete: "cascade",
      }),

    permissionId: uuid("permission_id")
      .notNull()
      .references(() => permissions.id, {
        onDelete: "cascade",
      }),
  },
  (table) => [
    uniqueIndex("role_permission_unique_idx")
      .on(table.roleId, table.permissionId),
  ]
);

// User-Role relationship
export const userRoles = pgTable(
  "user_roles",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    tenantId: uuid("tenant_id")
      .notNull()
      .references(() => tenants.id),

    userId: uuid("user_id")
      .notNull()
      .references(() => users.id),

    roleId: uuid("role_id")
      .notNull()
      .references(() => roles.id),

    companyId: uuid("company_id")
      .references(() => companies.id),

    assignedAt: timestamp("assigned_at", {
      withTimezone: true,
    }).defaultNow().notNull(),
  },
  (table) => [
    uniqueIndex("user_role_unique_idx")
      .on(
        table.tenantId,
        table.userId,
        table.roleId,
        table.companyId
      ),
  ]
);