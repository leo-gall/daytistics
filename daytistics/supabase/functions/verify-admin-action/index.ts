import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { z } from "npm:zod";
import { validateZodSchema } from "@shared/validation";
import { createAdminToken, verifyAdminToken } from "@application/admin";

const CreateAdminLoginObject = z.object({
  permissions: z.array(z.string()),
});

Deno.serve(async (req) => {
  try {
    if (
      req.headers.get("Authorization") !=
      "Bearer " + Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")
    ) {
      return new Response(null, {
        status: 401,
        statusText: "Unauthorized",
      });
    }

    const requestBody = await req.json();
    const { error, data: body } = validateZodSchema(
      CreateAdminLoginObject,
      requestBody
    );
    if (error) return error;

    const token = await createAdminToken(body.permissions);
    const data = await verifyAdminToken(token);

    return new Response(JSON.stringify({ token }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: (error as Error).message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
