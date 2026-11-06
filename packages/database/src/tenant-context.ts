import { sql } from "drizzle-orm";
import { db } from "./client";

export type DbTransaction = Parameters<
  Parameters<typeof db.transaction>[0]
>[0];

export async function withTenantContext<T>(
  tenantId: string,
  callback: (tx: DbTransaction) => Promise<T>
): Promise<T> {

  if (!tenantId) {
    throw new Error("Tenant ID is required");
  }

  return db.transaction(async (tx) => {

    await tx.execute(sql`
      SELECT set_config(
        'app.current_tenant',
        ${tenantId},
        true
      )
    `);

    return callback(tx);
  });
}