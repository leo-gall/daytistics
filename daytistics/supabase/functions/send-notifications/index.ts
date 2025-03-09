import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import * as OneSignal from "npm:@onesignal/node-onesignal";
import { initSentry } from "@shared/adapters";
import * as Sentry from "npm:@sentry/deno";

Deno.serve(async (req) => {
  initSentry();
  try {
    if (
      req.headers.get("Authorization") !==
      `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`
    ) {
      return new Response(
        JSON.stringify({
          error: "Unauthorized",
        }),
        {
          status: 401,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    const onesignal = new OneSignal.DefaultApi(
      OneSignal.createConfiguration({
        restApiKey: Deno.env.get("ONESIGNAL_API_KEY")!,
        userAuthKey: Deno.env.get("ONESIGNAL_USER_AUTH_KEY")!,
      })
    );

    const app = await onesignal.getApp(Deno.env.get("ONESIGNAL_APP_ID")!);

    const currentDate = new Date().toUTCString();
    const currentHHMM = currentDate
      .split(" ")[4]
      .split(":")
      .slice(0, 2)
      .join(":");

    const notification = new OneSignal.Notification();
    if (!app.id) {
      throw new Error("App ID is undefined");
    }
    notification.app_id = app.id;

    notification.contents = {
      en: "It's time to track your day!",
    };

    // required for Huawei
    notification.headings = {
      en: "Daily Reminder ⏰",
    };

    notification.filters = [
      {
        field: "tag",
        key: "daily_reminder_time",
        relation: "=",
        value: currentHHMM.toString(),
      },
    ];

    const notificationResponse = await onesignal.createNotification(
      notification
    );

    return new Response(
      JSON.stringify({
        message: "Notification sent!",
        currentHHMM,
        notificationResponse,
      }),
      {
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    Sentry.captureException(error);
    await Sentry.flush();
    return new Response(
      JSON.stringify({
        error: (error as Error).message,
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});
