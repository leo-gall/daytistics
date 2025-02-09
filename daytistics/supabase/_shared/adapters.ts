import * as Sentry from "npm:@sentry/deno";
import { PostHog } from "npm:posthog-node";

export function initSentry(): void {
  Sentry.init({
    dsn: Deno.env.get("SENTRY_DSN")!,
    defaultIntegrations: false,
    tracesSampleRate: 1.0,
  });
}

export function initPosthog(): PostHog {
  return new PostHog(Deno.env.get("POSTHOG_API_KEY")!, {
    host: "https://eu.i.posthog.com",
  });
}
