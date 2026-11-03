import { proxyActivities } from "@temporalio/workflow";

const { healthActivity } = proxyActivities<{ healthActivity(): Promise<string> }>({ startToCloseTimeout: "1 minute" });
export async function orbitWorkflow(): Promise<string> {
  return healthActivity();
}
