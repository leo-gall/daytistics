<template>
  <div
    class="flex gap-4 items-center justify-center lg:items-start lg:justify-start"
  >
    <!-- Google Play Button -->
    <a
      v-if="androidRelease"
      href="https://play.google.com/store/apps/details?id=com.daytistics.daytistics"
      class="flex items-center bg-[#34A853] text-white px-4 py-2.5 rounded-md font-sans text-base hover:-translate-y-0.5 transform transition-transform"
    >
      <svg
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="white"
        xmlns="http://www.w3.org/2000/svg"
        class="mr-2"
      >
        <path
          d="M3.6 1.8C3.1 2 2.9 2.4 2.9 3V21C2.9 21.6 3.2 22 3.6 22.2L14.1 12.7V12.6L3.6 1.8Z"
        ></path>
        <path
          d="M17.9 14.7L14.1 12L3.6 22.2C3.9 22.4 4.3 22.4 4.7 22.4C5.1 22.4 5.5 22.3 5.8 22.1L17.9 14.7Z"
        ></path>
        <path
          d="M20.2 13.5C21.1 12.9 21.1 11.1 20.2 10.5L18.4 9.4L14.1 12L18.4 14.6L20.2 13.5Z"
        ></path>
        <path
          d="M5.8 1.8C5.5 1.7 5.1 1.6 4.7 1.6C4.3 1.6 3.9 1.7 3.6 1.8L14.1 12L17.9 9.3L5.8 1.8Z"
        ></path>
      </svg>
      Play Store
    </a>
    <!-- App Store Button -->
    <a
      v-if="iosRelease"
      href="https://apps.apple.com/de/app/daytistics/id6742466141?l=en-GB"
      class="flex items-center bg-black text-white px-4 py-2.5 rounded-md font-sans text-base hover:-translate-y-0.5 transform transition-transform"
    >
      <svg
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="white"
        xmlns="http://www.w3.org/2000/svg"
        class="mr-2"
      >
        <path
          d="M18.9 13.6C18.9 10.8 21.3 9.3 21.4 9.2C20 7 17.7 6.7 16.8 6.7C14.8 6.5 13 8 12.1 8C11.2 8 9.6 6.8 8 6.8C5.8 6.8 3.7 8.3 2.7 10.3C0.9 14.1 2.9 19 4.7 21.3C5.7 22.6 6.9 24 8.3 24C9.6 24 10 23.2 11.6 23.2C13.2 23.2 13.6 24 14.9 24C16.3 24 17.5 22.7 18.5 21.5C19.7 20 20.3 18.6 20.4 18.5C20.3 18.5 18.9 17.8 18.9 13.6ZM15.7 3.5C16.5 2.5 17 1.1 16.8 0C15.6 0.1 14.2 0.9 13.4 1.9C12.7 2.7 12 4.1 12.2 5.3C13.4 5.4 14.8 4.7 15.7 3.5Z"
        ></path>
      </svg>
      App Store
    </a>
  </div>
</template>

<script lang="ts" setup>
const iosRelease = useRuntimeConfig().public.iosRelease;
const androidRelease = useRuntimeConfig().public.androidRelease;
</script>
