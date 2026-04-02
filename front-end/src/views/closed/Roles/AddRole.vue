<template>
  <div class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-[100] p-4">
    <div class="bg-white rounded-[2.5rem] shadow-2xl w-full max-w-md overflow-hidden animate-pop-in border border-slate-100">
      
      <div class="h-2 w-full bg-gradient-to-r from-primary to-dprimary"></div>

      <div class="p-8">
        <div class="flex justify-between items-start mb-8">
          <div>
            <h2 class="text-2xl font-black text-slate-900 font-sans leading-none">Add New Role</h2>
            <p class="text-[10px] font-black uppercase tracking-[0.2em] text-primary mt-2 flex items-center gap-2">
              <i class="fas fa-user-shield"></i> Identity Definition
            </p>
          </div>
          <button @click="$emit('close')" class="w-8 h-8 rounded-full bg-slate-50 flex items-center justify-center text-slate-400 hover:text-primary hover:bg-green-50 transition-all">
            <i class="fas fa-times text-xs"></i>
          </button>
        </div>

        <form @submit.prevent="submitForm" class="space-y-6">
          <div class="space-y-2">
            <label class="text-[10px] font-black uppercase tracking-widest text-slate-400 ml-1">Role Designation (Name)</label>
            <div class="relative group">
              <i class="fas fa-id-badge absolute left-4 top-1/2 -translate-y-1/2 text-slate-300 group-focus-within:text-dprimary transition-colors text-xs"></i>
              <input 
                v-model="form.name" 
                type="text" 
                required 
                placeholder="e.g. System Administrator"
                class="w-full pl-11 pr-4 py-3.5 bg-slate-50 border-2 border-slate-50 rounded-2xl focus:bg-white focus:ring-0 focus:border-primary outline-none transition-all text-sm font-bold text-slate-800 placeholder:text-slate-300" 
              />
            </div>
          </div>

          <div class="space-y-2">
            <label class="text-[10px] font-black uppercase tracking-widest text-slate-400 ml-1">Functional Description</label>
            <div class="relative group">
              <i class="fas fa-align-left absolute left-4 top-4 text-slate-300 group-focus-within:text-dprimary transition-colors text-xs"></i>
              <textarea 
                v-model="form.description" 
                required 
                rows="3"
                placeholder="Describe the scope of this role..."
                class="w-full pl-11 pr-4 py-3.5 bg-slate-50 border-2 border-slate-50 rounded-2xl focus:bg-white focus:ring-0 focus:border-primary outline-none transition-all text-sm font-bold text-slate-800 placeholder:text-slate-300"
              ></textarea>
            </div>
          </div>

          <div class="flex gap-3 pt-4">
            <button 
              type="button" 
              @click="$emit('close')" 
              class="flex-1 px-6 py-4 rounded-2xl font-black text-[10px] uppercase tracking-widest text-slate-400 hover:bg-slate-50 transition-colors"
            >
              Cancel
            </button>
            <button 
              type="submit" 
              :disabled="loading"
              class="flex-[2] bg-slate-900 hover:bg-primary text-white py-4 rounded-2xl font-black text-[10px] uppercase tracking-[0.2em] transition-all shadow-lg shadow-primary/20 active:scale-95 flex items-center justify-center gap-2 group"
            >
              <template v-if="!loading">
                Create Role <i class="fas fa-plus text-[8px] group-hover:scale-125 transition-transform"></i>
              </template>
              <template v-else>
                <div class="w-3 h-3 border-2 border-white/20 border-t-white rounded-full animate-spin"></div>
                Processing...
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
  props: { data: Object },
  data() {
    return {
      loading: false,
      form: {
        name: this.data?.name || '',
        description: this.data?.description || ''
      }
    };
  },
  methods: {
    async submitForm() {
      this.loading = true;
      try {
        const res = await this.$apiPost("/roles", this.form);
        if (res) {
          this.$root.$refs.toast.showToast('Role created successfully', 'success');
          this.$emit("saved");
          this.$emit("close");
        }
      } catch (e) { 
        console.error(e);
        this.$root.$refs.toast.showToast('Failed to create role', 'error');
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style scoped>
@keyframes popIn {
  from { opacity: 0; transform: scale(0.95) translateY(10px); }
  to { opacity: 1; transform: scale(1) translateY(0); }
}
.animate-pop-in { animation: popIn 0.3s ease-out; }
</style>