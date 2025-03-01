<template>
  <div
    class="min-h-screen flex flex-col-reverse lg:flex-row items-center justify-center px-4 gap-16 pt-36 lg:pt-0"
  >
    <SharedBackHomeButton />

    <div class="flex flex-col text-center gap-3">
      <h1 class="text-4xl font-bold text-gray-800 dark:text-white">
        This page doesn't exist.
      </h1>
      <div class="flex flex-col gap-5 items-center" v-if="isAppReleased">
        <p class="text-gray-600 dark:text-gray-300 max-w-lg mx-auto">
          We know that you're looking for something, but it's not here. Maybe
          you can find it in our app. Download it now and start tracking your
          daily activities and well-being with powerful analytics. Transform
          your habits through data-driven insights.
        </p>

        <SharedAppDownloads />
      </div>
      <div class="flex flex-col gap-5 items-center" v-else>
        <p class="text-gray-600 dark:text-gray-300 max-w-lg mx-auto">
          We know that you're looking for something, but it's not here. Maybe we
          will send it to you in the future. Subscribe to our newsletter to stay
          updated!
        </p>

        <SharedNewsletterForm class="w-full" :waitlist="true" />
      </div>

      <SharedLegalLinks class="lg:pb-0 pb-36" />
    </div>
  </div>
</template>

<script setup lang="ts">
const isAppReleased = useRuntimeConfig().public.isAppReleased;
</script>
