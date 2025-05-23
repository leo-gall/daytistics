import { createClient, User } from "jsr:@supabase/supabase-js@2";
import * as Sentry from "npm:@sentry/deno";

export function initSentry(): void {
  Sentry.init({
    dsn: Deno.env.get("SENTRY_DENO_DSN")!,
    defaultIntegrations: false,
    tracesSampleRate: 1.0,
    environment: Deno.env.get("ENVIRONMENT")!.toLowerCase(),
  });
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
