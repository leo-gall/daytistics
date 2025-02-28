<template>
  <button
    :type="type || 'button'"
    @click="emit('click')"
    class="px-4 py-2 bg-primary text-white rounded-md shadow-lg hover:-translate-y-0.5 transform transition-transform"
  >
    <slot />
  </button>
</template>

<script lang="ts" setup>
const emit = defineEmits(["click"]);

defineProps<{
  type?: "button" | "submit" | "reset";
}>();
</script>
