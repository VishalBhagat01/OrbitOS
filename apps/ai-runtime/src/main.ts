import { z } from "zod";

const runtimeInput = z.object({ message: z.string().min(1) });
export function createRuntime(): { invoke(input: unknown): { message: string } } {
  return { invoke: (input) => runtimeInput.parse(input) };
}

console.log("ORBIT AI runtime ready");
