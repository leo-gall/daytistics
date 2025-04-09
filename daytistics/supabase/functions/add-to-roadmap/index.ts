// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import * as Sentry from "npm:@sentry/deno";
import { initSentry, initSupabase } from "@shared/adapters";
import { validateZodSchema } from "@shared/validation";
import { z } from "npm:zod";
import { User } from "https://jsr.io/@supabase/supabase-js/2.48.1/src/index.ts";
import { addToRoadmap } from "@application/roadmap";

const AddToRoadmapObject = z.object({
  title: z.string(),
  description: z.string(),
});

Deno.serve(async (req) => {
  initSentry();

  try {
    const { user, error: supabaseInitError } = await initSupabase(req, {
      withAuth: true,
    });
    if (supabaseInitError) return supabaseInitError;

    const _body = await req.json();
    const { data: body, error: validateError } = await validateZodSchema(
      AddToRoadmapObject,
      _body,
    );
    if (validateError) return validateError;

    try {
      await addToRoadmap(body.title, body.description);
    } catch (error) {
      Sentry.captureException(error as Error);
      await Sentry.flush();
      return new Response(null, {
        status: 500,
        headers: { "Content-Type": "application/json" },
        statusText: (error as Error).message,
      });
    }

    return new Response(null, {
      status: 201,
      statusText: "Successfully added to roadmap",
      headers: {
        "Content-Type": "application/json",
      },
    });
  } catch (error) {
    Sentry.captureException(error as Error);
    await Sentry.flush();
    return new Response(null, {
      status: 500,
      headers: { "Content-Type": "application/json" },
      statusText: (error as Error).message,
    });
  }
});
