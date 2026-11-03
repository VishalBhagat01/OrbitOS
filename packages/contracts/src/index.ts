import { z } from "zod";

export const workflowStates = ["PENDING", "RUNNING", "WAITING_APPROVAL", "COMPLETED", "FAILED", "CANCELLED"] as const;
export type WorkflowState = (typeof workflowStates)[number];
export const approvalStates = ["REQUESTED", "GRANTED", "REJECTED", "EXPIRED"] as const;
export type ApprovalState = (typeof approvalStates)[number];

export const eventEnvelopeSchema = z.object({
  eventId: z.string().min(1),
  eventType: z.string().regex(/^[a-z][a-z0-9-]*(\.[a-z][a-z0-9-]*){1,2}$/),
  version: z.literal("v1"),
  tenantId: z.string().min(1),
  correlationId: z.string().min(1),
  timestamp: z.coerce.date(),
  payload: z.unknown(),
});
export type EventEnvelope = z.infer<typeof eventEnvelopeSchema>;

export interface AgentDefinition {
  id: string;
  description: string;
  capabilities: readonly string[];
  tools: readonly string[];
  permissions: readonly string[];
  inputSchema: z.ZodType;
  outputSchema: z.ZodType;
  execution: { timeoutMs: number; maxRetries: number };
}

export interface ApiError {
  code: string;
  message: string;
  details?: unknown;
  correlationId: string;
}
