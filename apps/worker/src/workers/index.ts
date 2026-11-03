import { NativeConnection, Worker } from "@temporalio/worker";
import * as activities from "../activities/index.js";

export async function createWorker(): Promise<Worker> {
  const connection = await NativeConnection.connect({
    address: process.env.TEMPORAL_ADDRESS ?? "localhost:7233",
  });
  return Worker.create({
    connection,
    workflowsPath: require.resolve("../workflows/index.js"),
    activities,
    taskQueue: process.env.TEMPORAL_TASK_QUEUE ?? "orbit",
  });
}
