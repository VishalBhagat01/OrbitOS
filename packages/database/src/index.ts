export interface DatabaseConfig {
  connectionString: string;
}

export function createDatabaseConfig(connectionString = process.env.DATABASE_URL): DatabaseConfig {
  if (!connectionString) {
    throw new Error("DATABASE_URL is required");
  }
  return { connectionString };
}
