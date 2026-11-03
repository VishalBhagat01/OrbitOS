import { describe, expect, it } from "vitest";
import { AppController } from "./app.controller";

describe("AppController", () => {
  it("returns a healthy service response", () => {
    const response = new AppController().health();
    expect(response.service).toBe("orbit-api");
    expect(response.status).toBe("ok");
  });
});
