import {
  pgTable,
  pgEnum,
  uuid,
  varchar,
  boolean,
  timestamp,
} from "drizzle-orm/pg-core";

export const userStatusEnum = pgEnum("user_status", [
  "active",
  "inactive",
  "suspended",
]);

export const users = pgTable("users", {
  id: uuid("id").defaultRandom().primaryKey(),

  email: varchar("email", { length: 255 })
    .notNull()
    .unique(),

  passwordHash: varchar("password_hash", {
    length: 255,
  }).notNull(),

  fullName: varchar("full_name", {
    length: 255,
  }).notNull(),

  status: userStatusEnum("status")
    .default("active")
    .notNull(),

  emailVerified: boolean("email_verified")
    .default(false)
    .notNull(),

  mfaEnabled: boolean("mfa_enabled")
    .default(false)
    .notNull(),

  createdAt: timestamp("created_at", {
    withTimezone: true,
  }).defaultNow().notNull(),

  updatedAt: timestamp("updated_at", {
    withTimezone: true,
  }).defaultNow().notNull(),
});