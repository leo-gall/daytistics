import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import * as Sentry from "npm:@sentry/deno";
import * as Conversations from "@application/conversations";
import { validateZodSchema } from "@shared/validation";
import { initSentry, initSupabase } from "@shared/adapters";
import { z } from "npm:zod";

const QuerySchema = z.object({
  amount: z.coerce.number().int().nonnegative().optional().default(10),
  offset: z.coerce.number().int().nonnegative().optional().default(0),
});

Deno.serve(async (req) => {
  try {
    initSentry();

    const {
      supabase,
      user,
      error: supabaseInitError,
    } = await initSupabase(req, { withAuth: true });
    if (supabaseInitError) return supabaseInitError;

    const validatedQuery = validateZodSchema(
      QuerySchema,
      new URL(req.url).searchParams
    );
    if (validatedQuery.error) return validatedQuery.error;

    const conversations = await Conversations.fetchConversations(
      user!,
      supabase,
      {
        encrypted: false,
        offset: validatedQuery.data.offset,
        amount: validatedQuery.data.amount,
      }
    );

    return new Response(JSON.stringify(conversations), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    Sentry.captureException(error);
    await Sentry.flush();
    return new Response(JSON.stringify({ error: (error as Error).message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
