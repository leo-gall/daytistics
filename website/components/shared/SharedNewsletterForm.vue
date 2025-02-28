<template>
  <form class="flex flex-col gap-3" @submit.prevent="subscribe">
    <StyledInput
      type="email"
      placeholder="Your email address"
      v-model="emailAddress"
    />
    <StyledButton type="submit">
      {{ waitlist ? "Join waitlist" : "Subscribe" }}
    </StyledButton>
    <p v-if="success" class="text-green-600 dark:text-green-400 text-center">
      {{ waitlist ? "You are on the waitlist!" : "Subscribed!" }}
    </p>
    <p
      v-else-if="success === false"
      class="text-red-600 dark:text-red-400 text-center"
    >
      Something went wrong. Please try again.
    </p>
  </form>
</template>

<script lang="ts" setup>
withDefaults(
  defineProps<{
    waitlist?: boolean;
  }>(),
  {
    waitlist: false,
  }
);

const { emailAddress, subscribe, success } = useEmailSubscription();

function useEmailSubscription() {
  const emailAddress = ref("");
  const success = ref<Boolean | null>(null);

  const subscribe = async () => {
    console.log("Subscribing with email address:", emailAddress.value);
    debugger;
    await $fetch("/api/subscribe", {
      method: "POST",
      body: { email_address: emailAddress.value },
      headers: {
        "Content-Type": "application/json",
      },
      onResponse: (response) => {
        success.value = response.response.ok;
      },
    });
  };

  return {
    emailAddress,
    subscribe,
    success,
  };
}
</script>
