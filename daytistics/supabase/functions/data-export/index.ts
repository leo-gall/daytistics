import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import * as Sentry from "npm:@sentry/deno";
import { initSentry, initSupabase } from "@shared/adapters";
import * as Conversations from "@application/conversations";
import * as Daytistics from "@application/daytistics";
import { SupabaseClient, User } from "jsr:@supabase/supabase-js@2.48.1";

Deno.serve(async (req) => {
  initSentry();

  try {
    const {
      user,
      error: supabaseInitError,
      supabase,
    } = await initSupabase(req, {
      withAuth: true,
    });
    if (supabaseInitError) return supabaseInitError;

    const tableData = await fetchTableData(supabase, { user: user! });

    return new Response(JSON.stringify({ tables: tableData, user: user }), {
      status: 200,
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

async function fetchTableData(
  supabase: SupabaseClient,
  options: {
    user: User;
  },
) {
  const conversations = await Conversations.fetchConversations(
    options.user,
    supabase,
    { encrypted: false },
  );

  const daytistics = await Daytistics.fetchDaytistics(supabase);

  const userSettings = await supabase.from("user_settings").select("*");

  return {
    conversations,
    daytistics,
    userSettings: userSettings.data,
  };
}
