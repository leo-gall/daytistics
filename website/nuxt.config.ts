// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: "2024-11-01",
  devtools: { enabled: true },
  components: { dirs: [{ path: "~/components", pathPrefix: false }] },
  modules: ["@nuxtjs/tailwindcss", "nuxt-swiper"],
  css: ["~/public/globals.css"],
  runtimeConfig: {
    public: {
      isAppReleased: process.env.NUXT_IS_APP_RELEASED == "true",
      posthogApiKey: process.env.NUXT_POSTHOG_API_KEY,
      posthogApiHost: process.env.NUXT_POSTHOG_API_HOST,
    },
    emailOctopusListId: process.env.NUXT_EMAIL_OCTOPUS_LIST_ID,
    emailOctopusApiKey: process.env.NUXT_EMAIL_OCTOPUS_API_KEY,
  },

  plugins: [{ src: "./plugins/posthog", mode: "client" }],

  app: {
    head: {
      link: [{ rel: "icon", type: "image/x-icon", href: "/favicon.svg" }],
      title: "Daytistics",
      bodyAttrs: {
        class: "bg-gray-50 dark:bg-gray-800 transition-colors duration-200",
      },
      meta: [
        {
          name: "description",
          content:
            "A mobile app to track your daily activities and well-being with powerful analytics. Transform your habits through data-driven insights.",
        },
        { name: "author", content: "Leo Gall" },
      ],
    },
  },

  nitro: {
    experimental: {
      tasks: true,
    },
    scheduledTasks: {
      "* * * * *": ["roadmap-watcher"],
    },
  },
});
