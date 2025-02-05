import {
  createClient,
  SupabaseClient,
  UserResponse,
} from "jsr:@supabase/supabase-js@2";
import * as Sentry from "npm:@sentry/deno";

export async function requireAuthWrapper(
  req: Request,
  callback: (supabase: SupabaseClient, user: UserResponse) => Promise<Response>
): Promise<Response> {
  const authHeader = req.headers.get("Authorization")!;
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    {
      global: { headers: { Authorization: authHeader } },
    }
  );

  const token = authHeader.replace("Bearer ", "");
  const user = await supabase.auth.getUser(token);

  return await callback(supabase, user);
}

export async function catchExceptionWrapper(
  callback: () => Promise<Response>
): Promise<Response> {
  Sentry.init({
    dsn: "https://7bb526cf1cedaeead0825d5990734c57@o4508760945000448.ingest.de.sentry.io/4508760947884112",
    defaultIntegrations: false,
    tracesSampleRate: 1.0,
  });

  try {
    return await callback();
  } catch (error) {
    Sentry.captureException(error);
    await Sentry.flush();
    if (error instanceof Error) {
      return new Response(JSON.stringify({ error: error.message }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    } else {
      return new Response(JSON.stringify({ error: "Unknown error" }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }
  }
}
