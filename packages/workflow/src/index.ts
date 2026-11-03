export interface WorkflowClientConfig {
  address: string;
  namespace: string;
  taskQueue: string;
}

export const defaultWorkflowClientConfig: WorkflowClientConfig = {
  address: process.env.TEMPORAL_ADDRESS ?? "localhost:7233",
  namespace: process.env.TEMPORAL_NAMESPACE ?? "default",
  taskQueue: process.env.TEMPORAL_TASK_QUEUE ?? "orbit",
};
