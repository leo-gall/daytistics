import { createClient, User } from "jsr:@supabase/supabase-js@2";
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import * as Sentry from "npm:@sentry/deno";
import { initSentry, initResend } from "@daytistics/adapters";

initSentry();

Deno.serve(async (req) => {
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

    const resend = initResend();

    const { data, error } = await resend.emails.send({
      from: "Daytistics System <system@daytistics.com>",
      to: Deno.env.get("DATA_EXPORT_EMAIL")!,
      subject: "Data Export Request",
      html: `
        <p>Hello,</p>
        <p>User ${user!.email || "<i>anonymous</i>"} (${
        user?.id
      }) has requested an export of their data. Please deliver the data to them as soon as possible.</p>
        <p>Thank you!</p>
      `,
    });
    if (error) {
      Sentry.captureException(error);
      await Sentry.flush();
      return new Response(null, {
        status: 500,
        headers: { "Content-Type": "application/json" },
        statusText: "Failed to send email",
      });
    }

    return new Response(null, {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Cache-Control": "no-cache",
      },
      statusText: "Email sent",
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
