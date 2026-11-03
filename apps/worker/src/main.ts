import { createWorker } from "./workers/index.js";

async function bootstrap(): Promise<void> {
  const worker = await createWorker();
  await worker.run();
}

void bootstrap();
