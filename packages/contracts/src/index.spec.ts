import { describe, expect, it } from "vitest";
import { eventEnvelopeSchema } from "./index";

describe("eventEnvelopeSchema", () => {
  it("accepts a versioned event envelope", () => {
    expect(() =>
      eventEnvelopeSchema.parse({
        eventId: "evt-1",
        eventType: "workflow.started",
        version: "v1",
        tenantId: "tenant-1",
        correlationId: "corr-1",
        timestamp: new Date(),
        payload: {},
      }),
    ).not.toThrow();
  });
});
