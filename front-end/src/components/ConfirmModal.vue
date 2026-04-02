<!-- components/ConfirmModal.vue -->
<template>
  
  <div v-if="visible" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-10">
    <div class="bg-white rounded-lg shadow-md max-w-sm w-full p-6 text-center">
      <h2 class="text-orange-500 text-lg font-semibold mb-4">{{ title }}</h2>
      <p class="text-orange-400  mb-6">{{ message }}</p>
      <div class="flex justify-center space-x-4">
        <button @click="$emit('cancel')" class="px-4 py-2 rounded bg-orange-400 text-white hover:bg-orange-500">Cancel</button>
        <button @click="$emit('confirm')" class="px-4 py-2 rounded bg-orange-500 text-white hover:bg-orange-600">OK</button>
      </div>
    </div>
  </div>
</template>

<script>


export default {
  props: {
    visible: Boolean,
    title: String,
    message: String,
  },
  
};
</script>
