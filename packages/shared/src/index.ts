export const SERVICE_VERSION = "1.0.0";

export interface HealthResponse {
  service: string;
  status: "ok";
  version: string;
  timestamp: string;
}
