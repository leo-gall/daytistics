import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import * as Sentry from "npm:@sentry/deno";
import { createClient, User } from "jsr:@supabase/supabase-js@2";
import { fetchConversations } from "@daytistics/database";
import { validateZodSchema } from "@daytistics/utils";
import { initSentry } from "@daytistics/adapters";
import { z } from "npm:zod";

initSentry();

const fetchConversationsSchema = z.object({
  amount: z.number().optional(),
  offset: z.number().optional(),
});

Deno.serve(async (req) => {
  const body = validateZodSchema(fetchConversationsSchema, await req.json());

  try {
    const authHeader = req.headers.get("Authorization")!;
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
      {
        global: { headers: { Authorization: authHeader } },
      }
    );

    const token = authHeader.replace("Bearer ", "");
    let user: User | null = null;
    try {
      user = (await supabase.auth.getUser(token)).data.user;
    } catch {
      return new Response(
        JSON.stringify({ error: "Invalid or missing token" }),
        {
          status: 401,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    let conversations = await fetchConversations(user!, supabase, {
      encrypted: false,
      offset: body.offset,
      amount: body.amount,
    });

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
