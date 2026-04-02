<template>
  <div class="p-6 bg-slate-50 min-h-screen font-sans text-slate-800 relative">
    <Loading :visible="loading" message="Syncing User Directory..." />

    <!-- HEADER -->
    <div class="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
      <div>
        <h1 class="text-2xl font-black text-slate-900 tracking-tight">User Directory</h1>
        <p class="text-slate-500 text-[10px] font-black uppercase tracking-[0.2em] mt-1 flex items-center gap-2">
          <span class="w-2 h-2 rounded-full bg-primary animate-pulse"></span>
          Alpha Message Integrator Users
        </p>
      </div>
      <button 
        @click="openAddModal" 
        class="bg-primary hover:bg-dprimary text-slate-900 px-6 py-4 rounded-2xl font-black shadow-lg shadow-primary/20 flex items-center justify-center space-x-2 text-[10px] uppercase tracking-widest transition-all active:scale-95"
      >
        <i class="fas fa-user-plus text-sm"></i>
        <span>Add New User</span>
      </button>
    </div>

    <!-- USERS TABLE (Desktop) -->
    <div class="bg-white rounded-[2.5rem] shadow-xl shadow-slate-200/50 border border-slate-100 overflow-hidden hidden md:block">
      <table class="w-full text-left border-collapse">
        <thead>
          <tr class="bg-slate-50 border-b border-slate-100">
            <th class="px-8 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">#</th>
            <th class="px-8 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Identity</th>
            <th class="px-8 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Contact Details</th>
            <th class="px-8 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Security</th>
            <th class="px-8 py-5 text-center text-[10px] font-black uppercase tracking-widest text-slate-400">Management</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-50">
          <tr v-for="(item, index) in items" :key="item.id" class="hover:bg-slate-50/80 transition-colors group">
            <td class="px-8 py-5 text-[10px] font-mono font-black text-slate-300">
              {{ String((currentPage - 1) * pageSize + (index + 1)).padStart(2, '0') }}
            </td>
            <td class="px-8 py-5">
              <div class="flex items-center gap-3">
                <div class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center text-primary font-black text-[10px]">
                  {{ item.username }}
                </div>
                <span class="text-xs font-black text-slate-700 uppercase tracking-tighter">{{ item.username }}</span>
              </div>
            </td>
            <td class="px-8 py-5">
              <div class="flex flex-col">
                <span class="text-xs font-bold text-slate-600">{{ item.email }}</span>
                <span class="text-[10px] text-slate-400 font-mono tracking-tighter">{{ item.phone }}</span>
              </div>
            </td>
            <td class="px-8 py-5">
              <code class="text-[10px] bg-slate-100 px-2 py-1 rounded text-slate-400 font-mono">********</code>
            </td>
            <td class="px-8 py-5">
              <div class="flex items-center justify-center gap-1">
                <button @click="viewDetails(item.id)" title="User Profile" class="w-9 h-9 flex items-center justify-center rounded-xl text-slate-300 hover:text-primary hover:bg-primary/10 transition-all">
                  <i class="fas fa-eye text-sm"></i>
                </button>

                <button @click="viewAssignedRoles(item)" title="View Assigned Roles" class="w-9 h-9 flex items-center justify-center rounded-xl text-slate-300 hover:text-indigo-500 hover:bg-indigo-50 transition-all">
                  <i class="fas fa-id-badge text-sm"></i>
                </button>

                <button @click="openRoleModal(item)" title="Assign Role" class="w-9 h-9 flex items-center justify-center rounded-xl text-slate-300 hover:text-amber-500 hover:bg-amber-50 transition-all">
                  <i class="fas fa-user-shield text-sm"></i>
                </button>

                <button @click="editItem(item)" title="Edit User" class="w-9 h-9 flex items-center justify-center rounded-xl text-slate-300 hover:text-dprimary hover:bg-primary/10 transition-all">
                  <i class="fas fa-edit text-sm"></i>
                </button>

                <button @click="openDeleteModal(item.id)" title="Delete User" class="w-9 h-9 flex items-center justify-center rounded-xl text-slate-300 hover:text-red-500 hover:bg-red-50 transition-all">
                  <i class="fas fa-trash-alt text-sm"></i>
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- MODALS -->
    <add-users v-if="showAddUserModal" :data="selectedItem" @close="showAddUserModal=false" @saved="fetchItems"/>
    <edit-users v-if="showEditUserModal" :data="selectedItem" @close="showEditUserModal=false" @saved="fetchItems"/>
    <assign-role-modal v-if="showAssignRoleModal && selectedItem" :user="selectedItem" @close="showAssignRoleModal=false" @assigned="fetchItems"/>

    <!-- VIEW ASSIGNED ROLES -->
    <div v-if="showRoleView && selectedItem" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-[200] p-4">
      <div class="bg-white rounded-[2.5rem] p-8 w-full max-w-sm shadow-2xl animate-pop-in border-t-4 border-indigo-500">
        <h3 class="text-xl font-black text-slate-900 mb-2">Assigned Roles</h3>
        <p class="text-[10px] font-black text-slate-400 uppercase mb-6 tracking-widest">Target: {{ selectedItem.username }}</p>

        <div v-if="loadingRoles" class="py-10 text-center"><i class="fas fa-spinner animate-spin text-indigo-500"></i></div>
        <div v-else class="space-y-2 max-h-60 overflow-y-auto">
          <div v-for="role in userAssignedRoles" :key="role.id" class="p-3 bg-indigo-50/50 border border-indigo-100 rounded-xl text-[10px] font-black uppercase text-indigo-700 flex items-center justify-between">
            {{ role.name }}
            <i class="fas fa-shield-alt opacity-30"></i>
          </div>
          <div v-if="userAssignedRoles.length === 0" class="text-center py-4 text-slate-400 text-xs italic">No roles found.</div>
        </div>

        <button @click="showRoleView = false" class="mt-8 w-full py-4 bg-slate-900 text-white rounded-2xl font-black text-[10px] uppercase tracking-widest hover:bg-slate-800 transition-all">Close Details</button>
      </div>
    </div>
  </div>
</template>

<script>
import AddUsers from "./AddUsers.vue";
import EditUsers from "./EditUsers.vue";
import AssignRoleModal from "./AssignRoleModal.vue"; 
import Loading from "@/components/Loading.vue";
import DeleteConfirmModal from "@/components/DeleteConfirmModal.vue";

export default {
  components: { AddUsers, EditUsers, AssignRoleModal, Loading, DeleteConfirmModal },
  data() {
    return {
      items: [],
      count: 0,
      pageSize: 10,
      currentPage: 1,
      searchQuery: "",
      loading: false,

      // MODALS
      showAddUserModal: false,
      showEditUserModal: false,
      showAssignRoleModal: false,
      showRoleView: false,
      selectedItem: null,
      userAssignedRoles: [],
      loadingRoles: false,

      deleteModalVisible: false,
      deleteId: null,
    };
  },
  methods: {
    openAddModal() { this.selectedItem = null; this.showAddUserModal = true; },
    editItem(user) { this.selectedItem = user; this.showEditUserModal = true; },
    openRoleModal(user) { this.selectedItem = user; this.showAssignRoleModal = true; },

    async viewAssignedRoles(user) {
      if (!user) return;
      this.selectedItem = user;
      this.showRoleView = true;
      this.loadingRoles = true;
      try {
        const res = await this.$apiGet(`/user/${user.id}`);
        this.userAssignedRoles = res.data.roles || [];
      } catch(e) { console.error(e); }
      finally { this.loadingRoles = false; }
    },

    async fetchItems(page = 1) {
      this.loading = true;
      this.currentPage = page;
      try {
        const res = await this.$apiGet('/users', { page, page_size: this.pageSize, search: this.searchQuery });
        this.items = res.data || [];
        this.count = res.count || 0;
        this.nextPage = res.next || null;
        this.previousPage = res.previous || null;
      } catch(e) { console.error(e); }
      finally { this.loading = false; }
    },

    viewDetails(id) { this.$router.push({ name: 'Users-detail', params: { id } }); },
    openDeleteModal(id) { this.deleteId = id; this.deleteModalVisible = true; },
    async confirmDelete() {
      const res = await this.$apiDelete('/users', this.deleteId);
      if(res) { this.$root.$refs.toast.showToast('User removed', 'success'); }
      this.deleteModalVisible = false;
      this.fetchItems(this.currentPage);
    },
  },
  mounted() { this.fetchItems(); }
};
</script>