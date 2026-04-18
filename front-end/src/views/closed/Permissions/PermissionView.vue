<template>
  <div class="p-6 bg-gray-50 min-h-screen text-sm text-gray-800 relative">
    
    <!-- Loading -->
    <Loading :visible="loading" message="Loading Permission..." />

    <!-- Header -->
    <div class="flex items-center justify-between mb-6 border-b pb-4 border-gray-200">
      <h1 class="text-lg font-bold text-gray-800">Permissions</h1>

      <button
        @click="openAddModal"
        class="bg-primary hover:bg-dprimary text-white px-4 py-2 rounded-lg font-medium shadow-md flex items-center space-x-1 text-sm"
      >
        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
        </svg>
        <span>Add Permission</span>
      </button>
    </div>

    <!-- Search -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-6 gap-4">
      <input
        v-model="searchQuery"
        @input="fetchItems(1)"
        type="text"
        placeholder="Search..."
        class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-primary shadow-sm"
      />

      <div class="flex items-center gap-2 text-sm text-gray-600">
        <label>Show</label>
        <select
          v-model="pageSize"
          @change="fetchItems(1)"
          class="border border-gray-300 rounded-lg px-2 py-1 text-sm bg-white focus:ring-primary"
        >
          <option v-for="size in [5,10,20,50,100]" :key="size" :value="size">
            {{ size }}
          </option>
        </select>
        <span>entries</span>
      </div>
    </div>

    <!-- TABLE -->
    <div class="bg-white rounded-xl border border-gray-200 hidden md:block">
      <div class="overflow-x-auto">
        <table class="min-w-full text-sm divide-y divide-gray-200">

          <thead class="bg-gray-100 text-gray-700 uppercase text-xs font-semibold">
            <tr>
              <th class="px-6 py-3 text-left">#</th>
              <th class="px-6 py-3 text-left">Name</th>
              <th class="px-6 py-3 text-left">Codename</th>
              <th class="px-6 py-3 text-left">Module</th>
              <th class="px-6 py-3 text-center">Actions</th>
            </tr>
          </thead>

          <tbody class="divide-y divide-gray-200">
            <tr
              v-for="(item, index) in items"
              :key="item.id"
              class="hover:bg-primary/5 transition"
            >
              <td class="px-6 py-4">{{ index + 1 }}</td>

              <td class="px-6 py-4 font-medium text-gray-800">
                {{ item.name }}
              </td>

              <td class="px-6 py-4 text-gray-600">
                {{ item.codename }}
              </td>

              <td class="px-6 py-4">
                <span class="px-2 py-1 text-xs rounded-lg bg-secondary/20 text-secondary font-medium">
                  {{ item.content_type }}
                </span>
              </td>

              <td class="px-6 py-4 text-center space-x-3">
            

                <button @click="editItem(item)" class="text-primary hover:text-blue-700">
                  <i class="fas fa-edit"></i>
                </button>

                <button @click="openDeleteModal(item.id)" class="text-red-500 hover:text-red-700">
                  <i class="fas fa-trash"></i>
                </button>
              </td>
            </tr>

            <tr v-if="items.length === 0">
              <td colspan="5" class="text-center py-6 text-gray-400 italic">
                No data found.
              </td>
            </tr>
          </tbody>

        </table>
      </div>
    </div>

    <!-- MOBILE -->
    <div class="md:hidden space-y-4">
      <div
        v-for="(item, index) in items"
        :key="item.id"
        class="bg-white border rounded-xl shadow p-4"
      >
        <div class="flex justify-between mb-3">
          <h2 class="font-bold text-gray-800">
            Permission #{{ index + 1 }}
          </h2>

          <div class="flex gap-3">
          

            <button @click="editItem(item)" class="text-primry">
              <i class="fas fa-edit"></i>
            </button>

            <button @click="openDeleteModal(item.id)" class="text-red-500">
              <i class="fas fa-trash"></i>
            </button>
          </div>
        </div>

        <div class="text-gray-700 space-y-1">
          <div><strong>Name:</strong> {{ item.name }}</div>
          <div><strong>Codename:</strong> {{ item.codename }}</div>
          <div>
            <strong>Module:</strong>
            <span class="ml-1 px-2 py-1 text-xs rounded bg-secondary/20 text-secondary">
              {{ item.content_type }}
            </span>
          </div>
        </div>
      </div>

      <p v-if="items.length === 0" class="text-center text-gray-400 italic">
        No data found.
      </p>
    </div>

    <!-- PAGINATION -->
    <div class="flex justify-between mt-6 text-sm text-gray-600">
      <span>
        Showing {{ (currentPage - 1) * pageSize + 1 }}
        to {{ Math.min(currentPage * pageSize, count) }}
        of {{ count }}
      </span>

      <div class="flex gap-2">
        <button
          @click="fetchItems(currentPage - 1)"
          :disabled="!previousPage"
          class="px-3 py-1 border rounded-lg hover:bg-gray-100 disabled:opacity-50"
        >
          ← Previous
        </button>

        <span class="px-3 py-1 bg-primary text-white rounded-lg">
          {{ currentPage }}
        </span>

        <button
          @click="fetchItems(currentPage + 1)"
          :disabled="!nextPage"
          class="px-3 py-1 border rounded-lg hover:bg-gray-100 disabled:opacity-50"
        >
          Next →
        </button>
      </div>
    </div>

    <!-- MODALS -->
    <add-permission
      v-if="showModal && !editMode"
      :data="selectedItem"
      @close="showModal=false"
      @saved="fetchItems"
    />

    <edit-permission
      v-if="showModal && editMode"
      :data="selectedItem"
      @close="showModal=false"
      @saved="fetchItems"
    />

    <delete-confirm-modal
      :visible="deleteModalVisible"
      title="Delete Permission"
      message="Are you sure you want to delete this Permission?"
      @confirm="confirmDelete"
      @cancel="deleteModalVisible=false"
    />

  </div>
</template>

<script>
import AddPermission from "./AddPermission.vue";
import EditPermission from "./EditPermission.vue";
import Loading from "@/components/Loading.vue";
import DeleteConfirmModal from "@/components/DeleteConfirmModal.vue";

export default {
  components: { AddPermission, EditPermission, Loading, DeleteConfirmModal },

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
        const res = await this.$apiGet("/permissions", {
          page,
          page_size: this.pageSize,
          search: this.searchQuery,
        });

        this.items = res.data;
        this.count = res.count;
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
      this.selectedItem = null;
      this.showModal = true;
    },

    editItem(item) {
      this.editMode = true;
      this.selectedItem = item;
      this.showModal = true;
    },

    viewDetails(id) {
      this.$router.push({ name: "Permission-detail", params: { id } });
    },

    openDeleteModal(id) {
      this.deleteId = id;
      this.deleteModalVisible = true;
    },

    async confirmDelete() {
      const res = await this.$apiDelete("/permissions", this.deleteId);

      if (res) {
        this.$root.$refs.toast.showToast("Deleted successfully", "success");
      }

      this.deleteModalVisible = false;
      this.fetchItems(this.currentPage);
    },
  },

  mounted() {
    this.fetchItems();
  },
};
</script>