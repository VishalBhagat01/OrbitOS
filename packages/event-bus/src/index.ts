export interface EventBus {
  publish(subject: string, payload: Uint8Array): Promise<void>;
  close(): Promise<void>;
}

export interface EventBusConfig {
  servers: string;
  stream: string;
}
