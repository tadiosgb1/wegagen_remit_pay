<template>
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
    <div class="bg-white rounded-xl shadow-2xl w-full max-w-md p-6 text-sm">
      
      <!-- Header -->
      <div class="flex justify-between items-center mb-4 border-b pb-2">
        <h2 class="text-lg font-semibold text-gray-800">
          Assign Role to {{ user.first_name }} {{ user.last_name }}
        </h2>
        <button @click="$emit('close')" class="text-gray-400 hover:text-gray-600">&times;</button>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="text-center py-4 text-gray-500">
        Loading roles...
      </div>

      <!-- Roles -->
      <form v-else @submit.prevent="submitForm" class="space-y-4">

        <!-- ✅ RADIO (single select) -->
        <div v-for="role in roles" :key="role.id" class="flex items-center gap-2">
          <input 
            type="radio"
            name="role"
            :id="'role-' + role.id"
            :value="role.id"
            v-model="selectedRoleId"
            class="w-4 h-4 text-primary border-gray-300 focus:ring-primary"
          />
          <label :for="'role-' + role.id" class="text-gray-700">
            {{ role.name }}
          </label>
        </div>

        <!-- Actions -->
        <div class="flex justify-end gap-3 pt-2">
          <button type="button" @click="$emit('close')" class="px-4 py-2 border rounded-lg">
            Cancel
          </button>

          <button type="submit"
            :disabled="!selectedRoleId"
            class="px-4 py-2 bg-primary text-white rounded-lg hover:bg-dprimary transition disabled:opacity-50">
            Save
          </button>
        </div>

      </form>
    </div>
  </div>
</template>

<script>
export default {
  props: { user: Object },

  data() {
    return {
      roles: [],
      selectedRoleId: null, // ✅ single value
      loading: false,
    };
  },

  methods: {

    async fetchRoles() {
      this.loading = true;
      try {
        // all roles
        const allRoles = await this.$apiGet("/roles", { page: 1, page_size: 1000 });
        this.roles = allRoles.data || [];

        // current assigned role
        const assignedRes = await this.$apiGet(`/user-role/${this.user.id}/roles`);

        // ✅ assume backend returns ONE role
        if (assignedRes && assignedRes.length > 0) {
          this.selectedRoleId = assignedRes[0].id;
        }

      } catch (e) {
        console.error(e);
      } finally {
        this.loading = false;
      }
    },

    async submitForm() {
      try {
        const payload = {
          user_id: this.user.id,
          role_id: this.selectedRoleId
        };

        const res = await this.$apiPost(`/user-roles`, payload);

        if (res) {
          this.$root.$refs.toast.showToast("Role assigned successfully", "success");
        }

        this.$emit("saved");
        this.$emit("close");

      } catch (e) {
        console.error(e);
      }
    },

  },

  mounted() {
    this.fetchRoles();
  },
};
</script>