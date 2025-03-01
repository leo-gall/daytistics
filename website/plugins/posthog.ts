import posthog from "posthog-js";
export default defineNuxtPlugin((nuxtApp) => {
  const runtimeConfig = useRuntimeConfig();
  const posthogClient = posthog.init(
    runtimeConfig.public.posthogApiKey as string,
    {
      api_host: runtimeConfig.public.posthogApiHost as string,
      capture_pageview: false, // we add manual pageview capturing below
      loaded: (posthog) => {
        if (import.meta.env.MODE === "development") posthog.debug();
        posthog.identify(`anonymous-${import.meta.env.MODE}-web-user`);
      },
    }
  );

  // Make sure that pageviews are captured with each route change
  const router = useRouter();
  router.afterEach((to) => {
    nextTick(() => {
      posthog.capture("$pageview", {
        current_url: to.fullPath,
      });
    });
  });

  return {
    provide: {
      posthog: () => posthogClient,
    },
  };
});
