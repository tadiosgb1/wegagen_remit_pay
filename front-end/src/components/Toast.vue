<template>
  <div>
    <transition
      enter-active-class="transform transition duration-300 ease-out"
      enter-from-class="translate-x-full opacity-0"
      enter-to-class="translate-x-0 opacity-100"
      leave-active-class="transform transition duration-300 ease-in"
      leave-from-class="translate-x-0 opacity-100"
      leave-to-class="translate-x-full opacity-0"
    >
      <div
        v-if="showSuccessToast"
        class="z-20 flex fixed bottom-96 right-5 items-center p-4 mb-4 text-sm text-green-500 bg-blue-50 border border-green-300 rounded-lg"
        role="alert"
      >
        <svg
          aria-hidden="true"
          class="w-5 h-5 mr-3"
          fill="currentColor"
          viewBox="0 0 20 20"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            fill-rule="evenodd"
            d="M16.707 5.293a1 1 0 00-1.414 0L9 11.586 6.707 9.293a1 1 0 00-1.414 1.414l3 3a1 1 0 001.414 0l7-7a1 1 0 000-1.414z"
            clip-rule="evenodd"
          ></path>
        </svg>
        <span class="font-medium"></span> {{ successToastMessage }}
      </div>
    </transition>
    <transition
      enter-active-class="transform transition duration-300 ease-out"
      enter-from-class="translate-x-full opacity-0"
      enter-to-class="translate-x-0 opacity-100"
      leave-active-class="transform transition duration-300 ease-in"
      leave-from-class="translate-x-0 opacity-100"
      leave-to-class="translate-x-full opacity-0"
    >
      <div
        v-if="showErrorToast"
        class="z-20 fixed top-5 right-5 bg-red-500 text-white px-4 py-2 rounded-lg shadow-lg"
        role="alert"
      >
        <strong class="font-bold">Error!</strong>
        <span class="block sm:inline">{{ errorToastMessage }}</span>
      </div>
    </transition>

    <!-- Warning Toast -->
    <transition
      enter-active-class="transform transition duration-300 ease-out"
      enter-from-class="translate-x-full opacity-0"
      enter-to-class="translate-x-0 opacity-100"
      leave-active-class="transform transition duration-300 ease-in"
      leave-from-class="translate-x-0 opacity-100"
      leave-to-class="translate-x-full opacity-0"
    >
      <div
        v-if="showWarningToast"
        class="z-20 fixed top-5 right-5 bg-yellow-500 text-black px-4 py-2 rounded-lg shadow-lg"
        role="alert"
      >
        <strong class="font-bold">Warning!</strong>
        <span class="block sm:inline">{{ warningToastMessage }}</span>
      </div>
    </transition>

    <div v-if="showLoginToast">
      <!-- Optional overlay for modal effect -->
      <div
        class="fixed inset-0 bg-black bg-opacity-50 z-10"
        @click="closeToast"
      ></div>

      <transition
        enter-active-class="transform transition duration-300 ease-out"
        enter-from-class="translate-y-full opacity-0"
        enter-to-class="translate-y-0 opacity-100"
        leave-active-class="transform transition duration-300 ease-in"
        leave-from-class="translate-y-0 opacity-100"
        leave-to-class="translate-y-full opacity-0"
      >
        <div
          class="z-20 fixed inset-0 flex items-center justify-center"
          role="alert"
        >
          <div
            class="bg-blue-500 text-white px-6 py-4 rounded-lg shadow-lg text-center max-w-md"
          >
            <strong class="font-bold">Success!</strong>
            <p class="mt-2">{{ loginToastMessage }}</p>
          </div>
        </div>
      </transition>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      successToastMessage: "",
      errorToastMessage: "",
      warningToastMessage: "",
      showSuccessToast: false,
      showErrorToast: false,
      showWarningToast: false,
      showLoginToast: false,
    };
  },
  methods: {
    showSuccessToastMessage(message) {
      this.successToastMessage = message;
      this.showSuccessToast = true;
      setTimeout(() => {
        this.showSuccessToast = false;
      }, 3000);
    },
    showErrorToastMessage(message) {
      this.errorToastMessage = message;
      this.showErrorToast = true;
      setTimeout(() => {
        this.showErrorToast = false;
      }, 3000);
    },
    showWarningToastMessage(message) {
      this.warningToastMessage = message;
      this.showWarningToast = true;
      setTimeout(() => {
        this.showWarningToast = false;
      }, 3000);
    },
    showLoginToastMessage(message) {
      this.loginToastMessage = message;
      this.showLoginToast = true;
      setTimeout(() => {
        this.showLoginToast = false;
      }, 3000);
    },
  },
};
</script>

<style scoped>
.toast-transition-enter-active,
.toast-transition-leave-active {
  transition: all 0.3s ease;
}

.toast-transition-enter,
.toast-transition-leave-to {
  transform: translateX(100%);
  opacity: 0;
}
</style>
