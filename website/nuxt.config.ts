// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: "2024-11-01",
  devtools: { enabled: true },
  components: { dirs: [{ path: "~/components", pathPrefix: false }] },
  modules: ["@nuxtjs/tailwindcss", "nuxt-swiper"],
  css: ["~/public/globals.css"],
  runtimeConfig: {
    public: {
      phase: process.env.PHASE as "development" | "testing" | "released",
      iosRelease: process.env.IOS_RELEASE === "true",
      androidRelease: process.env.ANDROID_RELEASE === "true",
      openPanelClientId: "",
    },
    emailOctopusListId: "",
    emailOctopusApiKey: "",
  },

  plugins: [{ src: "./plugins/openpanel", mode: "client" }],

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
});
