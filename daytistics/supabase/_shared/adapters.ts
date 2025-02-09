import * as Sentry from "npm:@sentry/deno";
import { PostHog } from "npm:posthog-node";

export function initSentry(): void {
  Sentry.init({
    dsn: "https://7bb526cf1cedaeead0825d5990734c57@o4508760945000448.ingest.de.sentry.io/4508760947884112",
    defaultIntegrations: false,
    tracesSampleRate: 1.0,
  });
}

export function initPosthog(): PostHog {
  return new PostHog(Deno.env.get("POSTHOG_API_KEY")!, {
    host: "https://eu.i.posthog.com",
  });
}
