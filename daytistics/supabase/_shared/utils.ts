import { z } from "npm:zod";

export function validateZodSchema<T>(schema: z.ZodType<T>, data: unknown): T {
  try {
    return schema.parse(data);
  } catch (error) {
    throw new Error(`Validation failed: ${error}`);
  }
}
