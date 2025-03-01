<template>
  <SharedBackHomeButton />

  <div class="min-h-screen py-16 px-4">
    <div class="max-w-3xl mx-auto">
      <h1 class="text-4xl font-bold mb-8 text-gray-800 dark:text-white">
        Account Deletion
      </h1>

      <div class="space-y-8 text-gray-600 dark:text-gray-300">
        <!-- With access to account section with multiple steps -->
        <section class="space-y-4">
          <h2
            class="text-2xl font-semibold mb-4 text-gray-700 dark:text-gray-100"
          >
            With Access to Account
          </h2>
          <p>
            If you have access to your account, you can delete it by following
            these steps:
          </p>
          <ol class="!list-decimal list-inside ml-3 space-y-2">
            <li>Open the Daytistics app and navigate to the profile page.</li>
            <li>
              Scroll down to the bottom of the page and tap on the "Delete
              account" button.
            </li>
            <li>
              After typing "DELETE" in the confirmation dialog, tap on the
              "Confirm" button.
            </li>
          </ol>
          <p>
            Should you encounter any difficulties or require assistance with
            deleting your account, please don't hesitate to contact us via
            <SharedContactEmail />.
          </p>
        </section>

        <!-- Without access to account section with multiple steps -->
        <section class="space-y-4">
          <h2
            class="text-2xl font-semibold mb-4 text-gray-700 dark:text-gray-100"
          >
            Without Access to Account
          </h2>
          <p>
            If you no longer have access to your account, you can request the
            deletion of your account by following these steps:
          </p>
          <ol class="!list-decimal list-inside ml-3 space-y-2">
            <li>
              Contact us via <SharedContactEmail /> and provide the email
              address and the OAuth provider (Google, Apple) associated with
              your account.
            </li>
            <li>
              If we can verify your identity, we will proceed with the deletion
              of your account and notify you once the process is completed.
              Please note that this process may take up to 7 days.
            </li>
          </ol>
        </section>

        <section class="space-y-4">
          <h2
            class="text-2xl font-semibold mb-4 text-gray-700 dark:text-gray-100"
          >
            Data Retention
          </h2>
          <p>
            After deleting your account, we won't retain any personal data
            associated with your account. However, we may retain anonymized data
            for analytical purposes. If you wish to have your data erased,
            please contact us at <SharedContactEmail />.
          </p>
        </section>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
useHead({
  title: "Daytistics - Account Deletion",
});
</script>
