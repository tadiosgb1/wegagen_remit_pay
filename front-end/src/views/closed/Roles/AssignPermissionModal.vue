<template>
  <div class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-[110] p-4">
    <div class="bg-white rounded-[2.5rem] shadow-2xl w-full max-w-md overflow-hidden animate-pop-in border border-slate-100">
      <div class="h-2 w-full bg-gradient-to-r from-indigo-400 to-primary"></div>

      <div class="p-8">
        <!-- HEADER -->
        <div class="flex justify-between items-start mb-6">
          <div>
            <h2 class="text-2xl font-black text-slate-900 leading-none">Assign Permission</h2>
            <p class="text-[10px] font-black uppercase tracking-[0.2em] text-indigo-500 mt-2 flex items-center gap-2">
              <i class="fas fa-shield-alt"></i> Permission Mapping
            </p>
          </div>
          <button @click="$emit('close')" class="w-8 h-8 rounded-full bg-slate-50 flex items-center justify-center text-slate-400 hover:text-primary">
            <i class="fas fa-times text-xs"></i>
          </button>
        </div>

        <!-- ROLE INFO -->
        <div class="mb-8 p-4 bg-slate-50 rounded-2xl flex items-center gap-4 border border-slate-100">
          <div class="w-12 h-12 rounded-xl bg-slate-900 text-primary flex items-center justify-center font-black">
            {{ role.name }}
          </div>
          <div>
            <p class="text-[10px] font-black uppercase tracking-widest text-slate-400">Target Role</p>
            <p class="text-sm font-black text-slate-700 uppercase tracking-tighter">{{ role.name }}</p>
          </div>
        </div>

        <!-- FORM -->
        <form @submit.prevent="submitAssignment" class="space-y-6">
          <div class="space-y-2">
            <label class="text-[10px] font-black uppercase tracking-widest text-slate-400 ml-1">
              Select System Permissions
            </label>

            <div class="max-h-64 overflow-y-auto border border-slate-100 rounded-2xl p-3 bg-slate-50">
              <div v-for="p in permissions" :key="p.id" class="flex items-center gap-2 mb-2">
                <input type="checkbox" :value="p.id" v-model="selectedPermissions" class="w-4 h-4">
                <span class="text-sm font-bold text-slate-700">{{ p.code }}</span>
              </div>
            </div>
          </div>

          <div class="flex gap-3 pt-4">
            <button type="button" @click="$emit('close')" class="flex-1 px-6 py-4 rounded-2xl font-black text-[10px] uppercase tracking-widest text-slate-400 hover:bg-slate-50">
              Cancel
            </button>
            <button type="submit" :disabled="loading || selectedPermissions.length===0" class="flex-[2] bg-slate-900 hover:bg-indigo-500 text-white py-4 rounded-2xl font-black text-[10px] uppercase tracking-[0.2em] transition-all flex items-center justify-center gap-2">
              <template v-if="!loading">
                Grant Permission <i class="fas fa-check-circle"></i>
              </template>
              <template v-else>
                <div class="w-3 h-3 border-2 border-white/20 border-t-white rounded-full animate-spin"></div>
              </template>
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: { role: { type: Object, required: true } },
  data() {
    return {
      loading: false,
      permissions: [],
      selectedPermissions: [] // ✅ store selected permission IDs
    };
  },
  methods: {
    async fetchPermissions() {
      try {
        const response = await this.$apiGet('/permissions', { page_size: 100 });
        this.permissions = response.data || [];
      } catch (e) {
        console.error(e);
      }
    },

    async submitAssignment() {
      if (this.selectedPermissions.length === 0) return;
      this.loading = true;
      try {
        const payload = {
          permissionIds: this.selectedPermissions
        };

        // POST to /api/roles/{roleId}/permissions
        await this.$apiPut(`/roles/${this.role.id}/permissions`, '',payload);

        this.$root.$refs.toast.showToast('Permissions granted successfully', 'success');
        this.$emit('assigned'); // emit event to parent to refresh data
        this.$emit('close');
      } catch (e) {
        console.error(e);
      } finally {
        this.loading = false;
      }
    }
  },
  mounted() {
    this.fetchPermissions();
  }
};
</script>