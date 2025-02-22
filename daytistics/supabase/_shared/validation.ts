import { User } from "jsr:@supabase/supabase-js@2";
import { z } from "npm:zod";
import { PostHog } from "npm:posthog-node";

export function validateZodSchema<T>(schema: z.ZodType<T>, data: unknown) {
  try {
    return { data: schema.parse(data), error: null };
  } catch (error) {
    return {
      data: null,
      error: new Response(JSON.stringify({ error: (error as Error).message }), {
        status: 422,
      }),
    };
  }
}
