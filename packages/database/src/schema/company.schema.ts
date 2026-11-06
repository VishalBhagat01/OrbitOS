import {
  pgTable,
  uuid,
  varchar,
  integer,
  jsonb,
  timestamp,
  boolean,
  uniqueIndex,
} from "drizzle-orm/pg-core";

import { tenants } from "./tenant.schema";
import { users } from "./user.schema";

export const companies = pgTable(
  "companies",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    tenantId: uuid("tenant_id")
      .notNull()
      .references(() => tenants.id, {
        onDelete: "restrict",
      }),

    name: varchar("name", { length: 255 })
      .notNull(),

    legalName: varchar("legal_name", {
      length: 255,
    }).notNull(),

    registrationNumber: varchar(
      "registration_number",
      { length: 100 }
    ),

    gstin: varchar("gstin", { length: 15 }),

    financialYearStartMonth: integer(
      "financial_year_start_month"
    ).default(4).notNull(),

    currency: varchar("currency", {
      length: 3,
    }).default("INR").notNull(),

    timezone: varchar("timezone", {
      length: 100,
    }).default("Asia/Kolkata").notNull(),

    settings: jsonb("settings")
      .$type<Record<string, unknown>>()
      .default({})
      .notNull(),

    isActive: boolean("is_active")
      .default(true)
      .notNull(),

    createdBy: uuid("created_by")
      .references(() => users.id, {
        onDelete: "set null",
      }),

    createdAt: timestamp("created_at", {
      withTimezone: true,
    }).defaultNow().notNull(),

    updatedAt: timestamp("updated_at", {
      withTimezone: true,
    }).defaultNow().notNull(),
  },
  (table) => [
    uniqueIndex("companies_tenant_id_id_idx")
      .on(table.tenantId, table.id),
  ]
);

export const companyMemberships = pgTable(
  "company_memberships",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    tenantId: uuid("tenant_id")
      .notNull()
      .references(() => tenants.id),

    companyId: uuid("company_id")
      .notNull()
      .references(() => companies.id),

    userId: uuid("user_id")
      .notNull()
      .references(() => users.id),

    isActive: boolean("is_active")
      .default(true)
      .notNull(),

    joinedAt: timestamp("joined_at", {
      withTimezone: true,
    }).defaultNow().notNull(),
  },
  (table) => [
    uniqueIndex("company_membership_unique_idx")
      .on(table.tenantId, table.companyId, table.userId),
  ]
);