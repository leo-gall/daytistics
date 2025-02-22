import {
  createClient,
  SupabaseClient,
  User,
} from "jsr:@supabase/supabase-js@2";
import * as Sentry from "npm:@sentry/deno";
import { PostHog } from "npm:posthog-node";
import { Resend } from "npm:resend";

export function initSentry(): void {
  Sentry.init({
    dsn: Deno.env.get("SENTRY_DSN")!,
    defaultIntegrations: false,
    tracesSampleRate: 1.0,
    environment: Deno.env.get("ENVIRONMENT")!.toLowerCase(),
  });
}

export function initPosthog(): PostHog {
  return new PostHog(Deno.env.get("POSTHOG_API_KEY")!, {
    host: "https://eu.i.posthog.com",
  });
}

export function initResend() {
  return new Resend(Deno.env.get("RESEND_API_KEY")!);
}

export async function initSupabase(
  req: Request,
  options?: { withAuth?: boolean }
) {
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
  if (options?.withAuth) {
    try {
      user = (await supabase.auth.getUser(token)).data.user;
    } catch (error) {
      console.error("Error getting user from Supabase", error);
      return {
        supabase,
        user: null,
        error: new Response("Unauthorized", { status: 401 }),
      };
    }
  }

  return { supabase, user };
}
