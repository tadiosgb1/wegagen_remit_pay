<template>
  <div class="p-6 bg-gray-50 min-h-screen text-sm text-gray-800 relative">

    <!-- Loading -->
    <Loading :visible="loading" message="Loading Users..." />

    <!-- Header -->
    <div class="flex items-center justify-between mb-6 border-b pb-4 border-gray-200">
      <h1 class="text-lg font-bold text-gray-800">Users</h1>
      <button
        @click="openAddModal"
        class="bg-primary hover:bg-dprimary text-white px-4 py-2 rounded-lg font-medium shadow-md flex items-center gap-1"
      >
        <i class="fas fa-plus"></i>
        Add User
      </button>
    </div>

    <!-- Search + Page Size -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-6 gap-4">
      <input
        v-model="searchQuery"
        @input="fetchItems(1)"
        type="text"
        placeholder="Search..."
        class="border border-gray-300 rounded-lg px-4 py-2 w-full sm:max-w-xs focus:ring-2 focus:ring-primary"
      />
      <div class="flex items-center gap-2">
        <label>Show</label>
        <select v-model="pageSize" @change="fetchItems(1)" class="border px-2 py-1 rounded-lg">
          <option v-for="size in [5,10,20,50]" :key="size" :value="size">{{ size }}</option>
        </select>
        <span>entries</span>
      </div>
    </div>

    <!-- Desktop Table -->
    <div class="bg-white rounded-xl border hidden md:block">
      <div class="overflow-x-auto">
        <table class="min-w-full text-sm">
          <thead class="bg-gray-100 text-xs uppercase">
            <tr>
              <th class="px-6 py-3 text-left">#</th>
              <th class="px-6 py-3 text-left">Full Name</th>
              <th class="px-6 py-3 text-left">Email</th>
              <th class="px-6 py-3 text-left">Phone</th>
              <th class="px-6 py-3 text-center">Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(item, index) in items"
              :key="item.id"
              class="border-t hover:bg-primary/10 transition"
            >
              <td class="px-6 py-4">{{ (currentPage - 1) * pageSize + index + 1 }}</td>
              <td class="px-6 py-4 font-medium">{{ item.first_name }} {{ item.last_name }}</td>
              <td class="px-6 py-4">{{ item.email }}</td>
              <td class="px-6 py-4">{{ item.phone_number }}</td>
              <td class="px-6 py-4 text-center space-x-3">

                <!-- Assign Roles -->
                <button @click="assignRoles(item)" class="text-yellow-500 hover:text-yellow-700 transition">
                  <i class="fas fa-user-shield"></i>
                </button>

                <!-- Edit -->
                <button @click="editItem(item)" class="text-primary hover:text-dprimary transition">
                  <i class="fas fa-edit"></i>
                </button>

                <!-- Delete -->
                <button @click="openDeleteModal(item.id)" class="text-red-500 hover:text-red-600 transition">
                  <i class="fas fa-trash"></i>
                </button>

              </td>
            </tr>
            <tr v-if="items.length === 0">
              <td colspan="5" class="text-center py-6 text-gray-400 italic">No data found.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Mobile Cards -->
    <div class="md:hidden space-y-4">
      <div v-for="(item, index) in items" :key="item.id" class="bg-white border rounded-xl shadow p-4">
        <div class="flex justify-between mb-2">
          <h2 class="font-bold">User #{{ (currentPage - 1) * pageSize + index + 1 }}</h2>
          <div class="flex gap-3">
            <button @click="assignRoles(item)" class="text-yellow-500">
              <i class="fas fa-user-shield"></i>
            </button>
            <button @click="editItem(item)" class="text-primary">
              <i class="fas fa-edit"></i>
            </button>
            <button @click="openDeleteModal(item.id)" class="text-red-500">
              <i class="fas fa-trash"></i>
            </button>
          </div>
        </div>
        <p><strong>Name:</strong> {{ item.first_name }} {{ item.last_name }}</p>
        <p><strong>Email:</strong> {{ item.email }}</p>
        <p><strong>Phone:</strong> {{ item.phone_number }}</p>
      </div>
      <p v-if="items.length === 0" class="text-center text-gray-400 py-6 italic">No data found.</p>
    </div>

    <!-- Pagination -->
    <div class="flex justify-between mt-6 text-sm">
      <span>
        Showing {{ (currentPage - 1) * pageSize + 1 }}
        to {{ Math.min(currentPage * pageSize, count) }}
        of {{ count }}
      </span>
      <div class="flex gap-2">
        <button @click="fetchItems(currentPage - 1)" :disabled="!previousPage" class="px-3 py-1 border rounded disabled:opacity-50">Prev</button>
        <span class="px-3 py-1 bg-primary text-white rounded">{{ currentPage }}</span>
        <button @click="fetchItems(currentPage + 1)" :disabled="!nextPage" class="px-3 py-1 border rounded disabled:opacity-50">Next</button>
      </div>
    </div>

    <!-- Modals -->
    <add-users v-if="showModal && !editMode" @close="showModal=false" @saved="fetchItems"/>
    <edit-users v-if="showModal && editMode" :data="selectedItem" @close="showModal=false" @saved="fetchItems"/>

    <!-- Assign Roles Modal -->
    <user-assign-role
      v-if="showAssignRoleModal"
      :user="selectedUser"
      @close="showAssignRoleModal=false"
      @saved="fetchItems"
    />

    <delete-confirm-modal
      :visible="deleteModalVisible"
      title="Delete User"
      message="Are you sure?"
      @confirm="confirmDelete"
      @cancel="deleteModalVisible=false"
    />
  </div>
</template>

<script>
import AddUsers from "./AddUsers.vue";
import EditUsers from "./EditUsers.vue";
import UserAssignRole from "./UserAssignRole.vue";
import Loading from "@/components/Loading.vue";
import DeleteConfirmModal from "@/components/DeleteConfirmModal.vue";

export default {
  components: { AddUsers, EditUsers, UserAssignRole, Loading, DeleteConfirmModal },

  data() {
    return {
      items: [],
      count: 0,
      nextPage: null,
      previousPage: null,
      currentPage: 1,
      pageSize: 10,
      searchQuery: "",
      showModal: false,
      editMode: false,
      selectedItem: null,
      selectedUser: null,
      showAssignRoleModal: false,
      loading: false,
      deleteModalVisible: false,
      deleteId: null,
    };
  },

  methods: {
    async fetchItems(page = 1) {
      this.loading = true;
      this.currentPage = page;
      try {
        const res = await this.$apiGet("/users", {
          page: this.currentPage,
          page_size: this.pageSize,
          search: this.searchQuery,
        });
        this.items = res.data || [];
        this.count = res.count || 0;
        this.nextPage = res.next;
        this.previousPage = res.previous;
      } catch (e) {
        console.error(e);
      } finally {
        this.loading = false;
      }
    },

    openAddModal() {
      this.editMode = false;
      this.showModal = true;
    },

    editItem(item) {
      this.editMode = true;
      this.selectedItem = item;
      this.showModal = true;
    },

    assignRoles(user) {
      this.selectedUser = user;
      this.showAssignRoleModal = true;
    },

    openDeleteModal(id) {
      this.deleteId = id;
      this.deleteModalVisible = true;
    },

    async confirmDelete() {
      await this.$apiDelete("/users", this.deleteId);
      this.deleteModalVisible = false;
      this.fetchItems(this.currentPage);
    },
  },

  mounted() {
    this.fetchItems();
  },
};
</script>