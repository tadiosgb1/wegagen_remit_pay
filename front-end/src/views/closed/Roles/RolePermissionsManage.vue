<template>
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
    <div class="bg-white rounded-xl shadow-2xl w-full max-w-md p-6 text-sm">
      
      <!-- Header -->
      <div class="flex justify-between items-center mb-4 border-b pb-2">
        <h2 class="text-lg font-semibold text-gray-800">Manage Permissions for {{ role.name }}</h2>
        <button @click="$emit('close')" class="text-gray-400 hover:text-gray-600">&times;</button>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="text-center py-4 text-gray-500">Loading permissions...</div>

      <!-- Permissions Form -->
      <form v-else @submit.prevent="submitForm" class="space-y-4">
        <div v-for="perm in permissions" :key="perm.id" class="flex items-center gap-2">
          <input 
            type="checkbox" 
            :id="'perm-' + perm.id" 
            :value="perm.id" 
            v-model="selectedPermissionIds" 
            class="w-4 h-4 text-primary border-gray-300 rounded focus:ring-primary"
          />
          <label :for="'perm-' + perm.id" class="text-gray-700">{{ perm.name }}</label>
        </div>

        <!-- Actions -->
        <div class="flex justify-end gap-3 pt-2">
          <button type="button" @click="$emit('close')" class="px-4 py-2 border rounded-lg">Cancel</button>
          <button type="submit" class="px-4 py-2 bg-primary text-white rounded-lg hover:bg-dprimary transition">
            Save
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  props: { role: Object },

  data() {
    return {
      permissions: [],
      selectedPermissionIds: [],
      loading: false,
    };
  },

  methods: {
    async fetchPermissions() {
      this.loading = true;
      try {
        // Fetch all permissions
        const allRes = await this.$apiGet("/permissions", { page: 1, page_size: 1000 });
        this.permissions = allRes.data || [];

        // Fetch permissions of this role
        const rolePermRes = await this.$apiGet(`/role-permissions/role/${this.role.id}/permissions`);


        console.log("rolePermRes",rolePermRes.data);


        const rolePermIds = rolePermRes.data.map(p => p.id);

        // Pre-check permissions assigned to this role
        this.selectedPermissionIds = rolePermIds;
      } catch (e) {
        console.error(e);
      } finally {
        this.loading = false;
      }
    },

    async submitForm() {
      try {
        const payload = {
          role_id: this.role.id,
          add_permission_ids: this.selectedPermissionIds, // we’ll send all selected
          remove_permission_ids: this.permissions
            .map(p => p.id)
            .filter(id => !this.selectedPermissionIds.includes(id))
        };

        const res = await this.$apiPatch("/role-permissions/manage", '',payload);
        if (res) {
          this.$root.$refs.toast.showToast("Permissions updated successfully", "success");
        }

        this.$emit("saved");
        this.$emit("close");
      } catch (e) {
        console.error(e);
      }
    }
  },

  mounted() {
    this.fetchPermissions();
  }
}
</script>