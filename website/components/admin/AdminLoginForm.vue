<template>
  <div>
    <h1 class="text-4xl font-bold text-gray-800 dark:text-white mb-10">
      Admin Login
    </h1>
    <form
      class="w-full max-w-md lg:text-start text-center flex flex-col items-center gap-3"
    >
      <StyledInput
        type="email"
        id="email"
        name="text"
        placeholder="Enter your token"
        class="w-full"
        required
      />
      <StyledButton type="submit" class="w-full">Login</StyledButton>
    </form>
  </div>
</template>
