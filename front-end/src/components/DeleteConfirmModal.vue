<template>
  <div v-if="visible" class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-30 z-50">
    <div class="bg-white rounded-xl shadow-lg w-80 p-6 text-center">
      <h2 class="text-lg font-bold text-green-600 mb-4">{{ title }}</h2>
      <p class="text-gray-700 mb-6">{{ message }}</p>
      <div class="flex justify-center gap-4">
        <button @click="$emit('cancel')" class="px-4 py-2 rounded-lg border border-gray-300 hover:bg-gray-100 transition">Cancel</button>
        <button @click="$emit('confirm')" class="px-4 py-2 rounded-lg bg-green-500 text-white hover:bg-green-600 transition">Confirm</button>
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
