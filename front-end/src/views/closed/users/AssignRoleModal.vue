<template>
  <div v-if="user" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-[110] p-4">
    <div class="bg-white rounded-[2.5rem] shadow-2xl w-full max-w-md overflow-hidden animate-pop-in border border-slate-100">
      
      <div class="h-2 w-full bg-gradient-to-r from-amber-400 to-primary"></div>

      <div class="p-8">
        <!-- Header -->
        <div class="flex justify-between items-start mb-6">
          <div>
            <h2 class="text-2xl font-black text-slate-900 leading-none">Assign Roles</h2>
            <p class="text-[10px] font-black uppercase tracking-[0.2em] text-amber-500 mt-2 flex items-center gap-2">
              <i class="fas fa-shield-alt"></i> Access Control Mapping
            </p>
          </div>
          <button @click="$emit('close')" class="w-8 h-8 rounded-full bg-slate-50 flex items-center justify-center text-slate-400 hover:text-primary hover:bg-green-50 transition-all">
            <i class="fas fa-times text-xs"></i>
          </button>
        </div>

        <!-- User Info -->
        <div class="mb-8 p-4 bg-slate-50 rounded-2xl flex items-center gap-4 border border-slate-100">
          <div class="w-12 h-12 rounded-xl bg-slate-900 text-primary flex items-center justify-center font-black">
            {{ user.username }}
          </div>
          <div>
            <p class="text-[10px] font-black uppercase tracking-widest text-slate-400">Target User</p>
            <p class="text-sm font-black text-slate-700 uppercase tracking-tighter">{{ user.username }}</p>
          </div>
        </div>

        <!-- Roles Form -->
        <form @submit.prevent="submitRoles" class="space-y-6">
          <div class="space-y-2">
            <label class="text-[10px] font-black uppercase tracking-widest text-slate-400 ml-1">Select Security Roles</label>

            <div v-if="loadingRoles" class="py-6 text-center">
              <i class="fas fa-spinner animate-spin text-amber-500 text-lg"></i>
            </div>

            <div v-else class="max-h-60 overflow-y-auto border border-slate-100 rounded-2xl p-3 space-y-2 bg-slate-50">
              <div v-for="role in roles" :key="role.id" class="flex items-center gap-3">
                <input type="checkbox" :id="'role-'+role.id" :value="role.id" v-model="selectedRoleIds" class="w-4 h-4 accent-amber-500" />
                <label :for="'role-'+role.id" class="text-[12px] font-bold text-slate-700">{{ role.name }}</label>
              </div>
              <div v-if="roles.length === 0" class="text-red-400 text-[10px] font-bold mt-2 text-center">No roles found in registry.</div>
            </div>
          </div>

          <!-- Buttons -->
          <div class="flex gap-3 pt-4">
            <button type="button" @click="$emit('close')" class="flex-1 px-6 py-4 rounded-2xl font-black text-[10px] uppercase tracking-widest text-slate-400 hover:bg-slate-50 transition-colors">Cancel</button>
            <button type="submit" :disabled="loading || selectedRoleIds.length === 0" class="flex-[2] bg-slate-900 hover:bg-amber-500 text-white py-4 rounded-2xl font-black text-[10px] uppercase tracking-[0.2em] transition-all shadow-lg shadow-amber-500/10 active:scale-95 flex items-center justify-center gap-2 group disabled:opacity-50 disabled:cursor-not-allowed">
              <template v-if="!loading">Update Roles <i class="fas fa-key text-[8px] group-hover:rotate-12 transition-transform"></i></template>
              <template v-else><div class="w-3 h-3 border-2 border-white/20 border-t-white rounded-full animate-spin"></div></template>
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    user: { type: Object, required: true }
  },
  data() {
    return {
      roles: [],
      selectedRoleIds: [],
      loading: false,
      loadingRoles: false
    };
  },
  methods: {
    async fetchRoles() {
      this.loadingRoles = true;
      try {
        const response = await this.$apiGet('/roles', { page_size: 100 });
        this.roles = response.data || [];
        // Initialize selected roles if user already has some
        if (this.user.roles) {
          this.selectedRoleIds = this.user.roles.map(r => r.id);
        }
      } catch (e) {
        console.error("Error fetching roles:", e);
      } finally {
        this.loadingRoles = false;
      }
    },
    async submitRoles() {
      if (!this.user || this.selectedRoleIds.length === 0) return;
      this.loading = true;
      try {
        const payload = { roleIds: this.selectedRoleIds };
        await this.$apiPut(`/users/${this.user.id}/roles`,'', payload);
        this.$root.$refs.toast.showToast('Roles updated successfully', 'success');
        this.$emit('assigned');
        this.$emit('close');
      } catch (e) {
        console.error("Error updating roles:", e);
        this.$root.$refs.toast.showToast('Failed to update roles', 'error');
      } finally {
        this.loading = false;
      }
    }
  },
  mounted() {
    this.fetchRoles();
  }
};
</script>

<style scoped>
@keyframes popIn {
  from { opacity: 0; transform: scale(0.95) translateY(10px); }
  to { opacity: 1; transform: scale(1) translateY(0); }
}
.animate-pop-in { animation: popIn 0.3s ease-out; }
</style>