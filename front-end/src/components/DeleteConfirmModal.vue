<template>
  <div
    v-if="visible"
    class="fixed inset-0 flex items-center justify-center bg-black/40 z-50 p-4"
  >
    <!-- Modal -->
    <div class="bg-white rounded-2xl shadow-2xl w-full max-w-sm p-6 text-center">

      <!-- Title -->
      <h2 class="text-lg font-bold text-primary mb-3">
        {{ title }}
      </h2>

      <!-- Message -->
      <p class="text-gray-600 mb-6">
        {{ message }}
      </p>

      <!-- Actions -->
      <div class="flex justify-center gap-4">

        <!-- Cancel -->
        <button
          @click="$emit('cancel')"
          class="px-4 py-2 rounded-lg border border-gray-300 text-gray-600 hover:bg-gray-100 transition"
        >
          Cancel
        </button>

        <!-- Confirm -->
        <button
          @click="$emit('confirm')"
          class="px-4 py-2 rounded-lg bg-primary text-white hover:bg-dprimary shadow-md transition"
        >
          Confirm
        </button>

      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    visible: { type: Boolean, default: false },
    title: { type: String, default: "Confirm Action" },
    message: { type: String, default: "Are you sure?" },
  },
};
</script>