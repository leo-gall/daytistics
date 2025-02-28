/** @type {import('tailwindcss').Config} */
export default {
  darkMode: "class",
  content: [
    "./components/**/*.{js,vue,ts}",
    "./layouts/**/*.vue",
    "./pages/**/*.vue",
    "./plugins/**/*.{js,ts}",
    "./nuxt.core.{js,ts}",
  ],
  theme: {
    extend: {
      colors: {
        primary: "var(--color-primary)",
      },
      fonts: {
        figtree: ["Figtree", "sans-serif"],
      },
    },
  },
};
