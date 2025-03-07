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
      We are currently in the first testing phase. If you join our waiting list,
      you will have the opportunity to test the app before the public release.
      You will also receive emails with updates and can unsubscribe at any time.
    </p>
    <p class="text-gray-600 dark:text-gray-300 mb-8">
      Please note that it might take a while until you receive an invitation to
      test the app, because we have to add each tester manually. We will send
      you an email as soon as we have added you to the testing list.
    </p>

    <SharedNewsletterForm :waitlist="true" />
  </div>
</template>
