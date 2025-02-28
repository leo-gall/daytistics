<template>
  <input
    class="border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
    :type="type"
    v-model="value"
    :placeholder="placeholder || ''"
    @input="$emit('input', value)"
  />
</template>

<script lang="ts" setup>
defineProps<{
  type: string;
  placeholder?: string;
}>();

const value = ref("");
</script>
