<template>
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
    <div class="bg-white rounded-xl shadow-2xl w-full max-w-sm p-6 text-sm">

      <!-- Header -->
      <div class="flex justify-between items-center mb-4 border-b pb-2">
        <h2 class="text-lg font-semibold text-primary">Edit Role</h2>
        <button @click="$emit('close')" class="text-gray-400 hover:text-gray-600 transition">&times;</button>
      </div>

      <!-- Form -->
      <form @submit.prevent="submitForm" class="space-y-4">

        <!-- Name -->
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Name</label>
          <input
            v-model="form.name"
            type="text"
            required
            class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-primary shadow-sm transition duration-150"
          />
        </div>

        <!-- Description -->
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Description</label>
          <input
            v-model="form.description"
            type="text"
            required
            class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-primary shadow-sm transition duration-150"
          />
        </div>

        <!-- Action Buttons -->
        <div class="flex justify-end gap-3 pt-2">
          <button
            type="button"
            @click="$emit('close')"
            class="px-4 py-2 border rounded-lg hover:bg-gray-100 transition"
          >
            Cancel
          </button>
          <button
            type="submit"
            class="px-4 py-2 bg-primary text-white rounded-lg hover:bg-dprimary transition"
          >
            Edit
          </button>
        </div>

      </form>
    </div>
  </div>
</template>

<script>
export default {
  props: { data: Object },
  data() {
    return {
      form: {
        name: this.data?.name || '',
        description: this.data?.description || ''
      }
    };
  },
  methods: {
    async submitForm() {
      try {
        // Always perform PUT for editing
        const res = await this.$apiPatch("/roles", this.data.id, this.form);
        if(res){
          this.$root.$refs.toast.showToast('Role updated successfully', 'success');
        }
        this.$emit("saved");
        this.$emit("close");
      } catch (e) { 
        console.error(e); 
      }
    }
  }
}
</script>