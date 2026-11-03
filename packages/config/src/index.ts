import { z } from "zod";

export const environmentSchema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  PORT: z.coerce.number().int().positive().default(3000),
  DATABASE_URL: z.string().url().default("postgres://orbit:orbit@localhost:5432/orbit"),
  REDIS_URL: z.string().url().default("redis://localhost:6379"),
  NATS_URL: z.string().url().default("nats://localhost:4222"),
  TEMPORAL_ADDRESS: z.string().default("localhost:7233"),
  MINIO_ENDPOINT: z.string().default("http://localhost:9000"),
  LOG_LEVEL: z.string().default("info"),
  OTEL_EXPORTER_OTLP_ENDPOINT: z.string().url().optional(),
});

export type Environment = z.infer<typeof environmentSchema>;

export function loadEnvironment(input: NodeJS.ProcessEnv = process.env): Environment {
  return environmentSchema.parse(input);
}
