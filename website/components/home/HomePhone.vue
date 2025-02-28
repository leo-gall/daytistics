<template>
  <div class="iphone shadow-2xl">
    <div class="notch"></div>
    <div class="screen">
      <ClientOnly>
        <swiper-container ref="swiperRef" class="w-full h-full">
          <swiper-slide
            v-for="(img, index) in images"
            :key="index"
            class="flex justify-center items-center"
          >
            <img
              :src="img.src"
              :alt="img.alt"
              class="w-full h-full object-cover"
            />
          </swiper-slide>
          <!-- Swiper Pagination -->
          <div class="swiper-pagination"></div>
        </swiper-container>
      </ClientOnly>
    </div>
  </div>
</template>

<script setup lang="ts">
const swiperRef = ref(null);
const images = [
  { src: "/png/dashboard.png", alt: "Daytistics Dashboard" },
  { src: "/png/chat.png", alt: "Daytistics Chat" },
  { src: "/png/activities.png", alt: "Daytistics Activities" },
  { src: "/png/wellbeing.png", alt: "Daytistics Well-being" },
];

const swiper = useSwiper(swiperRef, {
  loop: true,
  pagination: { el: ".swiper-pagination", clickable: true },
});
</script>

<style scoped>
.iphone {
  @apply lg:w-[375px] w-[360px] h-[667px] bg-gray-900 rounded-[50px] relative overflow-hidden border-2 border-gray-900;
}
.notch {
  @apply absolute top-0 left-1/2 w-[210px] h-[30px] bg-gray-900 -translate-x-1/2 rounded-b-[24px];
}
.screen {
  @apply w-full h-full bg-white rounded-[40px] overflow-hidden;
}
</style>
