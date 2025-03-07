<template>
  <div
    class="min-h-screen flex flex-col-reverse lg:flex-row items-center justify-center px-4 gap-16 pt-36 lg:pt-0"
  >
    <HomePhone />
    <HomeReleaseIntro v-if="phase == 'released'" />
    <HomeDevelopmentIntro v-else-if="phase == 'development'" />
    <HomeTestingIntro v-else-if="phase == 'testing'" />
  </div>
  <SharedLegalLinks class="lg:pb-0 pb-36 mt-4" />
</template>

<script setup lang="ts">
const phase = useRuntimeConfig().public.phase;
</script>
