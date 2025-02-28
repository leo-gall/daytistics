<template>
  <NuxtLink :to="to" class="text-primary hover:underline" :target="target">
    <slot />
  </NuxtLink>
</template>

<script lang="ts" setup>
defineProps<{
  to: string;
  target?: string;
}>();
</script>
