<template>
  <header class="relative bg-gray-800 text-white">
    <!-- Navbar -->
    <nav class="flex items-center justify-between px-4 py-2">
      <div class="text-xl font-bold">MyWebsite</div>
      <button @click="toggleMobileMenu" class="lg:hidden">
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
        </svg>
      </button>
      <div :class="{'block': isMobileMenuOpen, 'hidden': !isMobileMenuOpen}" class="lg:flex space-x-6">
        <a href="#home" class="hover:text-gray-400">Home</a>
        <a href="#about" class="hover:text-gray-400">About</a>
        <a href="#products" class="hover:text-gray-400">Products</a>
        <a href="#services" class="hover:text-gray-400">Services</a>
        <a href="#news" class="hover:text-gray-400">News</a>
        <a href="#contact" class="hover:text-gray-400">Contact</a>
      </div>
    </nav>

    <!-- Carousel -->
    <div class="relative">
      <div class="absolute top-1/2 left-1/4 transform -translate-x-1/2 -translate-y-1/2 text-white text-3xl font-semibold z-10 opacity-80">Your Transparent Text</div>
      <img src="../assets//img/banamall.jpg" alt="Floating Image" class="absolute top-1/4 right-10 transform -translate-y-1/2 w-32 h-32 z-20 rounded-full shadow-lg" />

      <!-- Carousel Slides -->
      <div class="relative">
        <div class="swiper-container overflow-hidden">
          <div class="swiper-wrapper transition-transform ease-in-out duration-500" :style="carouselStyle">
            <div class="swiper-slide">
              <img src="../assets/img/church1.jpg" alt="Church 1" class="w-full h-64 object-cover" />
            </div>
            <div class="swiper-slide">
              <img src="../assets/img/church2.jpg" alt="Church 2" class="w-full h-64 object-cover" />
            </div>
            <div class="swiper-slide">
              <img src="../assets/img/church3.jpg" alt="Church 3" class="w-full h-64 object-cover" />
            </div>
          </div>
        </div>

        <!-- Left and Right Navigation Buttons -->
        <button @click="moveToPrevious" class="absolute top-1/2 left-2 transform -translate-y-1/2 bg-black text-white p-2 rounded-full z-20">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
          </svg>
        </button>
        <button @click="moveToNext" class="absolute top-1/2 right-2 transform -translate-y-1/2 bg-black text-white p-2 rounded-full z-20">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
          </svg>
        </button>
      </div>
    </div>
  </header>
</template>

<script>
export default {
  data() {
    return {
      currentSlide: 0,
      totalSlides: 3,
      isMobileMenuOpen: false,
      autoSlideInterval: null,
    };
  },
  computed: {
    carouselStyle() {
      return {
        transform: `translateX(-${this.currentSlide * 100}%)`,
      };
    },
  },
  methods: {
    toggleMobileMenu() {
      this.isMobileMenuOpen = !this.isMobileMenuOpen;
    },
    moveToPrevious() {
      this.currentSlide = (this.currentSlide - 1 + this.totalSlides) % this.totalSlides;
    },
    moveToNext() {
      this.currentSlide = (this.currentSlide + 1) % this.totalSlides;
    },
    startAutoSlide() {
      this.autoSlideInterval = setInterval(() => {
        this.moveToNext();
      }, 3000); // Change slide every 3 seconds
    },
    stopAutoSlide() {
      clearInterval(this.autoSlideInterval);
    },
  },
  mounted() {
    this.startAutoSlide();
  },
  beforeDestroy() {
    this.stopAutoSlide();
  },
};
</script>

<style scoped>
/* Add any custom styles here */
</style>
