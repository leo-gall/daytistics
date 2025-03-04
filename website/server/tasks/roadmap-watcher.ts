export default defineTask({
  meta: {
    name: "roadmap-watcher",
    description: "Watch the roadmap for changes",
  },
  async run(event) {
    await $fetch("https://webhook.site/39d7b28b-6259-40d0-a83d-2adacd9606d5");
    return {
      result: {
        success: true,
      },
    };
  },
});
