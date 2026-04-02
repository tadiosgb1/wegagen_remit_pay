<template>
  <div>
    <!-- Success Toast -->
    <transition
      enter-active-class="transform transition duration-300 ease-out"
      enter-from-class="translate-x-full opacity-0"
      enter-to-class="translate-x-0 opacity-100"
      leave-active-class="transform transition duration-300 ease-in"
      leave-from-class="translate-x-0 opacity-100"
      leave-to-class="translate-x-full opacity-0"
    >
      <div
        v-if="toast.type === 'success'"
        class="z-50 fixed top-5 right-5 bg-green-500 text-white px-4 py-2 rounded shadow"
      >
        <strong class="font-bold">Success!</strong>
        <span class="block">{{ toast.message }}</span>
      </div>
    </transition>

    <!-- Error Toast -->
    <transition
      enter-active-class="transform transition duration-300 ease-out"
      enter-from-class="translate-x-full opacity-0"
      enter-to-class="translate-x-0 opacity-100"
      leave-active-class="transform transition duration-300 ease-in"
      leave-from-class="translate-x-0 opacity-100"
      leave-to-class="translate-x-full opacity-0"
    >
      <div
        v-if="toast.type === 'error'"
        class="z-50 fixed top-5 right-5 bg-red-500 text-white px-4 py-2 rounded shadow"
      >
        <strong class="font-bold">Error!</strong>
        <span class="block">{{ toast.message }}</span>
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
        v-if="toast.type === 'warning'"
        class="z-50 fixed top-5 right-5 bg-yellow-500 text-black px-4 py-2 rounded shadow"
      >
        <strong class="font-bold">Warning!</strong>
        <span class="block">{{ toast.message }}</span>
      </div>
    </transition>

    <!-- Login Toast -->
    <transition
      enter-active-class="transform transition duration-300 ease-out"
      enter-from-class="translate-y-full opacity-0"
      enter-to-class="translate-y-0 opacity-100"
      leave-active-class="transform transition duration-300 ease-in"
      leave-from-class="translate-y-0 opacity-100"
      leave-to-class="translate-y-full opacity-0"
    >
      <div
        v-if="toast.type === 'login'"
        class="fixed inset-0 flex items-center justify-center z-50"
      >
        <div class="bg-blue-500 text-white px-6 py-4 rounded shadow max-w-sm text-center">
          <strong class="font-bold">Success!</strong>
          <p class="mt-2">{{ toast.message }}</p>
        </div>
      </div>
    </transition>
  </div>
</template>

<script>
export default {
  data() {
    return {
      toast: {
        message: '',
        type: '',
      },
      timer: null,
    };
  },
  methods: {
    /**
     * Show a toast message
     * @param {string} message
     * @param {'success'|'error'|'warning'|'login'} type
     */
    showToast(message, type = 'success') {
      this.toast.message = message;
      this.toast.type = type;

      if (this.timer) clearTimeout(this.timer);

      this.timer = setTimeout(() => {
        this.toast.type = '';
        this.toast.message = '';
      }, 3000);
    },
  },
};
</script>
