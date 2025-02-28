import posthog, { PostHog } from "posthog-js";

export default defineNuxtPlugin((nuxtApp) => {
  const { posthogApiHost, posthogApiKey } = useRuntimeConfig().public;

  const client = posthog.init(posthogApiKey as string, {
    api_host: posthogApiHost as string,
    loaded: (posthog) => {
      posthog.identify("unidentified-web-user");
    },
  });

  console.log(posthog);

  return {
    provide: {
      $posthog: client as PostHog,
    },
  };
});
