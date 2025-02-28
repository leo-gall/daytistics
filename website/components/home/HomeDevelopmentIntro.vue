<template>
  <div class="w-full max-w-md lg:text-start text-center">
    <img
      src="/svg/logo.svg"
      alt="Daytistics Logo"
      class="glow w-44 h-44 -mt-8 mb-4 lg:relative lg:-left-8 lg:mx-0 mx-auto"
    />

    <h1 class="text-3xl font-bold mb-4 text-gray-800 dark:text-white">
      Daytistics
    </h1>

    <p class="text-gray-600 dark:text-gray-300 mb-4">
      A mobile app to track your daily activities and well-being with powerful
      analytics. Transform your habits through data-driven insights.
    </p>

    <p class="text-gray-600 dark:text-gray-300 mb-8">
      We are currently in development, but you can subscribe to our newsletter
      below to stay updated! Before and after the release of the app, you will
      receive emails from which you can unsubscribe at any time.
    </p>

    <SharedNewsletterForm :waitlist="true" />
  </div>
</template>
