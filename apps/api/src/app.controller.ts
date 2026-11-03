import { Controller, Get } from "@nestjs/common";
import { SERVICE_VERSION, type HealthResponse } from "@orbit/shared";

@Controller("api/v1")
export class AppController {
  @Get("health")
  health(): HealthResponse {
    return {
      service: "orbit-api",
      status: "ok",
      version: SERVICE_VERSION,
      timestamp: new Date().toISOString(),
    };
  }
}
