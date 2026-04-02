<template>
  <div class="p-6 bg-slate-50 min-h-screen font-sans text-slate-800 relative">
    <Loading :visible="loading" message="Syncing Role Hierarchy..." />

    <div class="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
      <div>
        <h1 class="text-2xl font-black text-slate-900 tracking-tight">System Roles</h1>
        <p class="text-slate-500 text-[10px] font-black uppercase tracking-[0.2em] mt-1 flex items-center gap-2">
           <span class="w-2 h-2 rounded-full bg-primary animate-pulse"></span>
           Identity & Access Management
        </p>
      </div>
      
      <button @click="openAddModal" class="bg-primary hover:bg-dprimary text-slate-900 px-6 py-4 rounded-2xl font-black shadow-lg shadow-primary/20 flex items-center justify-center space-x-2 text-[10px] uppercase tracking-widest transition-all active:scale-95">
        <i class="fas fa-plus-circle text-sm"></i>
        <span>Add New Role</span>
      </button>
    </div>

    <div class="bg-white p-4 rounded-[2rem] shadow-sm border border-slate-100 mb-6 flex flex-col md:flex-row md:items-center justify-between gap-4">
      <div class="relative flex-1 max-w-md group">
        <i class="fas fa-search absolute left-4 top-1/2 -translate-y-1/2 text-slate-300 group-focus-within:text-primary transition-colors text-xs"></i>
        <input v-model="searchQuery" @input="fetchItems(1)" type="text" placeholder="Search roles..." class="w-full pl-11 pr-4 py-3 bg-slate-50 border-none rounded-xl focus:ring-2 focus:ring-primary/10 outline-none text-[13px] font-bold text-slate-700 transition-all" />
      </div>
    </div>

    <div class="bg-white rounded-[2.5rem] shadow-xl shadow-slate-200/50 border border-slate-100 overflow-hidden hidden md:block">
      <table class="w-full text-left border-collapse">
        <thead>
          <tr class="bg-slate-50 border-b border-slate-100">
            <th class="px-8 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400"># Index</th>
            <th class="px-8 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Role Name</th>
            <th class="px-8 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Description</th>
            <th class="px-8 py-5 text-center text-[10px] font-black uppercase tracking-widest text-slate-400">Actions</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-50">
          <tr v-for="(item, index) in items" :key="item.id" class="hover:bg-slate-50/80 transition-colors group">
            <td class="px-8 py-5 font-mono text-[10px] text-slate-300">{{ String(index + 1).padStart(2, '0') }}</td>
            <td class="px-8 py-5 font-black text-xs text-slate-700 uppercase">{{ item.name }}</td>
            <td class="px-8 py-5 text-xs text-slate-500 italic">{{ item.description || 'N/A' }}</td>
            <td class="px-8 py-5">
              <div class="flex items-center justify-center gap-1">
                <button @click="fetchRolePermissions(item)" title="View Permissions" class="w-9 h-9 flex items-center justify-center rounded-xl text-slate-300 hover:text-indigo-500 hover:bg-indigo-50 transition-all">
                  <i class="fas fa-lock text-sm"></i>
                </button>

                <button @click="openPermissionModal(item)" title="Assign Permission" class="w-9 h-9 flex items-center justify-center rounded-xl text-slate-300 hover:text-emerald-500 hover:bg-emerald-50 transition-all">
                  <i class="fas fa-shield-check text-sm"></i>
                </button>

                <button @click="editItem(item)" class="w-9 h-9 flex items-center justify-center rounded-xl text-slate-300 hover:text-dprimary transition-all"><i class="fas fa-edit text-sm"></i></button>
                <button @click="openDeleteModal(item.id)" class="w-9 h-9 flex items-center justify-center rounded-xl text-slate-300 hover:text-red-500 transition-all"><i class="fas fa-trash-alt text-sm"></i></button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <AddRole v-if="showModal && !editMode" @close="showModal=false" @saved="fetchItems"/>
    <EditRole v-if="showModal && editMode" :data="selectedItem" @close="showModal=false" @saved="fetchItems"/>
    
    <assign-permission-modal 
      v-if="showPermissionModal" 
      :role="selectedItem" 
      @close="showPermissionModal = false" 
      @assigned="fetchItems" 
    />

    <div v-if="showPermissionView" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-[200] p-4">
      <div class="bg-white rounded-[2.5rem] p-8 w-full max-w-sm shadow-2xl animate-pop-in border-t-4 border-indigo-500">
        <h3 class="text-xl font-black text-slate-900 mb-2">Role Permissions</h3>
        <p class="text-[10px] font-black text-slate-400 uppercase mb-6">Role: {{ selectedItem.name }}</p>
        
        <div v-if="loadingPerms" class="py-10 text-center"><i class="fas fa-spinner animate-spin text-indigo-500"></i></div>
        <div v-else class="space-y-2 max-h-60 overflow-y-auto">
          <div v-for="perm in assignedPermissions" :key="perm.id" class="p-3 bg-indigo-50/50 border border-indigo-100 rounded-xl text-[10px] font-black uppercase text-indigo-700 flex items-center gap-3">
            <i class="fas fa-check-circle text-indigo-400"></i> {{ perm.name }}
          </div>
          <div v-if="assignedPermissions.length === 0" class="text-center py-4 text-slate-400 text-xs italic">No permissions assigned.</div>
        </div>

        <button @click="showPermissionView = false" class="mt-8 w-full py-4 bg-slate-900 text-white rounded-2xl font-black text-[10px] uppercase tracking-widest">Close</button>
      </div>
    </div>

    <delete-confirm-modal :visible="deleteModalVisible" @confirm="confirmDelete" @cancel="deleteModalVisible=false" />
  </div>
</template>
<script>
import AddRole from "./AddRole.vue";
import EditRole from "./EditRole.vue";
import AssignPermissionModal from "./AssignPermissionModal.vue";
import Loading from "@/components/Loading.vue";
import DeleteConfirmModal from "@/components/DeleteConfirmModal.vue";

export default {
  components: {
    AddRole,
    EditRole,
    AssignPermissionModal,
    Loading,
    DeleteConfirmModal
  },

  data() {
    return {
      items: [],
      selectedItem: null,
      loading: false,

      // modals
      showModal: false,
      editMode: false,
      showPermissionModal: false,
      showPermissionView: false,
      deleteModalVisible: false,

      // delete
      deleteId: null,

      // permissions
      assignedPermissions: [],
      loadingPerms: false,

      // pagination
      currentPage: 1,
      pageSize: 10,
      count: 0,

      // search
      searchQuery: ""
    };
  },

  methods: {
    // =========================
    // FETCH ROLES
    // =========================
    async fetchItems(page = 1) {
      this.loading = true;
      try {
        const res = await this.$apiGet("/roles", {
          page,
          page_size: this.pageSize,
          search: this.searchQuery
        });

        this.items = res.data || [];
        this.count = res.count || 0;
        this.currentPage = page;

      } catch (e) {
        console.error("Fetch roles error:", e);
      } finally {
        this.loading = false;
      }
    },

    // =========================
    // ADD ROLE
    // =========================
    openAddModal() {
      this.editMode = false;
      this.selectedItem = null;
      this.showModal = true;
    },

    // =========================
    // EDIT ROLE
    // =========================
    editItem(item) {
      this.editMode = true;
      this.selectedItem = item;
      this.showModal = true;
    },

    // =========================
    // DELETE ROLE
    // =========================
    openDeleteModal(id) {
      this.deleteId = id;
      this.deleteModalVisible = true;
    },

    async confirmDelete() {
      try {
        await this.$apiDelete(`/roles/${this.deleteId}`);

        this.deleteModalVisible = false;
        this.deleteId = null;

        this.fetchItems(this.currentPage);

      } catch (e) {
        console.error("Delete error:", e);
      }
    },

    // =========================
    // VIEW PERMISSIONS
    // =========================
    async fetchRolePermissions(role) {
      this.selectedItem = role;
      this.showPermissionView = true;
      this.loadingPerms = true;

      try {
        const res = await this.$apiGet(`/role-permissions/${role.id}`);
        this.assignedPermissions = res.data?.permissions || res.data || [];
      } catch (e) {
        console.error("Permission fetch error:", e);
      } finally {
        this.loadingPerms = false;
      }
    },

    // =========================
    // ASSIGN PERMISSION
    // =========================
    openPermissionModal(role) {
      this.selectedItem = role;
      this.showPermissionModal = true;
    }
  },

  mounted() {
    this.fetchItems();
  }
};
</script>