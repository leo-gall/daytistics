import { z } from "npm:zod";

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

export async function hasThrownGraphQLError(res_: Response): Promise<boolean> {
  const res = res_.clone();
  const json = await res.json();
  return json.errors && json.errors.length > 0;
}
