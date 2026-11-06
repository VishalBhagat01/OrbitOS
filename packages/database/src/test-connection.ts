import { config } from "dotenv";
import { resolve } from "path";

async function testConnection() {

  // Load .env from ORBIT root
  const envPath = resolve(process.cwd(), "../../.env");

  const envResult = config({ path: envPath });

  if (envResult.error) {
    throw new Error(`Failed to load .env from ${envPath}`);
  }

  console.log("Environment loaded:", Boolean(process.env.DATABASE_URL));

  // Dynamic import: happens AFTER dotenv initialization
  const { pool } = await import("./client.js");

  try {
    const result = await pool.query(`
      SELECT
        current_database() AS database,
        current_user AS user,
        version() AS version
    `);

    console.log("\nDatabase connected successfully!");
    console.log(result.rows[0]);

  } catch (error) {
    console.error("Database connection failed:", error);
    process.exitCode = 1;

  } finally {
    await pool.end();
  }
}

testConnection();