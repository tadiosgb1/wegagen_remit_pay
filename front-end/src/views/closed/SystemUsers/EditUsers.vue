<template>
  <div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">

    <!-- Modal -->
    <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md p-6 text-sm">

      <!-- Header -->
      <div class="flex justify-between items-center mb-5 border-b pb-3">
        <h2 class="text-lg font-semibold text-gray-800">
          Edit User
        </h2>

        <button
          @click="$emit('close')"
          class="text-gray-400 hover:text-dprimary text-xl"
        >
          &times;
        </button>
      </div>

      <!-- Form -->
      <form @submit.prevent="submitForm" class="space-y-4">

        <!-- First Name -->
        <div>
          <label class="label">First Name</label>
          <input v-model="form.first_name" type="text" required class="input" />
        </div>

        <!-- Last Name -->
        <div>
          <label class="label">Last Name</label>
          <input v-model="form.last_name" type="text" required class="input" />
        </div>

        <!-- Email -->
        <div>
          <label class="label">Email</label>
          <input v-model="form.email" type="email" required class="input" />
        </div>

        <!-- Phone -->
        <div>
          <label class="label">Phone Number</label>
          <input v-model="form.phone_number" type="text" required class="input" />
        </div>

        <!-- Actions -->
        <div class="flex justify-end gap-3 pt-4">

          <button
            type="button"
            @click="$emit('close')"
            class="px-4 py-2 border border-gray-300 rounded-lg text-gray-600 hover:bg-gray-100 transition"
          >
            Cancel
          </button>

          <button
            type="submit"
            class="px-4 py-2 bg-primary hover:bg-dprimary text-white rounded-lg shadow-md transition"
          >
            Update
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
        first_name: this.data?.first_name || "",
        last_name: this.data?.last_name || "",
        email: this.data?.email || "",
        phone_number: this.data?.phone_number || "",
      },
    };
  },

  methods: {
    async submitForm() {
      try {
        const payload = { ...this.form };

        // Optional: remove empty PIN (so it doesn't overwrite)
        if (!payload.pin) {
          delete payload.pin;
        }

        const res = await this.$apiPatch("/users", this.data.id, payload);

        if (res) {
          this.$root.$refs.toast.showToast("User updated successfully", "success");
        }

        this.$emit("saved");
        this.$emit("close");

      } catch (e) {
        console.error(e);
        this.$root.$refs.toast.showToast("Update failed", "error");
      }
    },
  },
};
</script>

<style scoped>
/* Reusable Input */
.input {
  @apply w-full border border-gray-300 rounded-lg px-4 py-2 text-sm
         focus:outline-none focus:ring-2 focus:ring-primary
         focus:border-primary transition;
}

/* Label */
.label {
  @apply block mb-1 text-sm font-medium text-gray-700;
}
</style>