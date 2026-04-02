
<template>
  <div class="p-6 bg-gray-50 min-h-screen text-sm text-gray-800 relative">
    <!-- Loading -->
    <Loading :visible="loading" message="Loading transactions..." />

    <!-- Page Header -->
    <div class="flex items-center justify-between mb-6 border-b pb-4 border-gray-200">
      <h1 class="text-lg font-bold text-gray-800">Transactions</h1>
      <button @click="openAddModal" class="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-lg font-medium shadow-md flex items-center space-x-1 text-sm">
        <svg class="h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
        </svg>
        <span>Add Transactions</span>
      </button>
    </div>

    <!-- Search + Page Size -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-6 gap-4">
      <input v-model="searchQuery" @input="fetchItems(1)" type="text" placeholder="Search..."
        class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
      <div class="flex items-center gap-2 text-sm text-gray-600">
        <label>Show</label>
        <select v-model="pageSize" @change="fetchItems(1)" class="border border-gray-300 rounded-lg px-2 py-1 text-sm bg-white focus:ring-green-500 focus:border-green-500">
          <option v-for="size in [5,10,20,50,100]" :key="size" :value="size">{{ size }}</option>
        </select>
        <span>entries</span>
      </div>
    </div>

    <!-- Desktop Table -->
    <div class="bg-white overflow-hidden rounded-xl border border-gray-200 hidden md:block">
      <div class="overflow-x-auto">
        <table class="min-w-full text-sm divide-y divide-gray-200">
          <thead class="bg-gray-100 text-gray-700 uppercase text-xs font-semibold">
            <tr>
              <th class="px-6 py-3 text-left">#</th>
              <th class="px-6 py-3 text-left">Reference_no</th><th class="px-6 py-3 text-left">Sender_id</th><th class="px-6 py-3 text-left">Amount_original</th><th class="px-6 py-3 text-left">Currency</th><th class="px-6 py-3 text-left">Exchange_rate</th><th class="px-6 py-3 text-left">Amount_etb</th><th class="px-6 py-3 text-left">Status</th><th class="px-6 py-3 text-left">Payment_method</th><th class="px-6 py-3 text-left">Delivery_method</th><th class="px-6 py-3 text-left">Receiver_full_name</th><th class="px-6 py-3 text-left">Receiver_phone</th><th class="px-6 py-3 text-left">Receiver_email</th><th class="px-6 py-3 text-left">Bank_name</th><th class="px-6 py-3 text-left">Account_number</th>
              <th class="px-6 py-3 text-center">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="(item, index) in items" :key="item.id" class="hover:bg-green-50 transition duration-150">
              <td class="px-6 py-4">{{ index + 1 }}</td>
              <td class="px-6 py-4 whitespace-nowrap">{{ item.reference_no }}</td><td class="px-6 py-4 whitespace-nowrap">{{ item.sender_id }}</td><td class="px-6 py-4 whitespace-nowrap">{{ item.amount_original }}</td><td class="px-6 py-4 whitespace-nowrap">{{ item.currency }}</td><td class="px-6 py-4 whitespace-nowrap">{{ item.exchange_rate }}</td><td class="px-6 py-4 whitespace-nowrap">{{ item.amount_etb }}</td><td class="px-6 py-4 whitespace-nowrap">{{ item.status }}</td><td class="px-6 py-4 whitespace-nowrap">{{ item.payment_method }}</td><td class="px-6 py-4 whitespace-nowrap">{{ item.delivery_method }}</td><td class="px-6 py-4 whitespace-nowrap">{{ item.receiver_full_name }}</td><td class="px-6 py-4 whitespace-nowrap">{{ item.receiver_phone }}</td><td class="px-6 py-4 whitespace-nowrap">{{ item.receiver_email }}</td><td class="px-6 py-4 whitespace-nowrap">{{ item.bank_name }}</td><td class="px-6 py-4 whitespace-nowrap">{{ item.account_number }}</td>
              <td class="px-6 py-4 text-center space-x-3">
                <button @click="viewDetails(item.id)" class="text-green-500 hover:text-green-700"><i class="fas fa-eye"></i></button>
                <button @click="editItem(item)" class="text-blue-500 hover:text-blue-700"><i class="fas fa-edit"></i></button>
                <button @click="openDeleteModal(item.id)" class="text-red-500 hover:text-red-700"><i class="fas fa-trash"></i></button>
              </td>
            </tr>
            <tr v-if="items.length === 0">
              <td colspan="16" class="text-center py-6 text-gray-400 italic">No data found.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Mobile Cards -->
    <div class="md:hidden space-y-4">
      <div v-for="(item, index) in items" :key="item.id" class="bg-white border border-gray-200 rounded-xl shadow p-4">
        <div class="flex justify-between mb-3">
          <h2 class="font-bold text-gray-800">Transactions #{{ index + 1 }}</h2>
          <div class="flex gap-3 text-sm">
            <button @click="viewDetails(item.id)" class="text-green-500 hover:text-green-700"><i class="fas fa-eye"></i></button>
            <button @click="editItem(item)" class="text-blue-500 hover:text-blue-700"><i class="fas fa-edit"></i></button>
            <button @click="openDeleteModal(item.id)" class="text-red-500 hover:text-red-700"><i class="fas fa-trash"></i></button>
          </div>
        </div>
        <div class="grid grid-cols-2 gap-y-1 text-sm text-gray-700">
          
            <div class="col-span-2">
              <span class="font-medium text-gray-600">Reference_no:</span>
              {{ item.reference_no }}
            </div>
            <div class="col-span-2">
              <span class="font-medium text-gray-600">Sender_id:</span>
              {{ item.sender_id }}
            </div>
            <div class="col-span-2">
              <span class="font-medium text-gray-600">Amount_original:</span>
              {{ item.amount_original }}
            </div>
            <div class="col-span-2">
              <span class="font-medium text-gray-600">Currency:</span>
              {{ item.currency }}
            </div>
            <div class="col-span-2">
              <span class="font-medium text-gray-600">Exchange_rate:</span>
              {{ item.exchange_rate }}
            </div>
            <div class="col-span-2">
              <span class="font-medium text-gray-600">Amount_etb:</span>
              {{ item.amount_etb }}
            </div>
            <div class="col-span-2">
              <span class="font-medium text-gray-600">Status:</span>
              {{ item.status }}
            </div>
            <div class="col-span-2">
              <span class="font-medium text-gray-600">Payment_method:</span>
              {{ item.payment_method }}
            </div>
            <div class="col-span-2">
              <span class="font-medium text-gray-600">Delivery_method:</span>
              {{ item.delivery_method }}
            </div>
            <div class="col-span-2">
              <span class="font-medium text-gray-600">Receiver_full_name:</span>
              {{ item.receiver_full_name }}
            </div>
            <div class="col-span-2">
              <span class="font-medium text-gray-600">Receiver_phone:</span>
              {{ item.receiver_phone }}
            </div>
            <div class="col-span-2">
              <span class="font-medium text-gray-600">Receiver_email:</span>
              {{ item.receiver_email }}
            </div>
            <div class="col-span-2">
              <span class="font-medium text-gray-600">Bank_name:</span>
              {{ item.bank_name }}
            </div>
            <div class="col-span-2">
              <span class="font-medium text-gray-600">Account_number:</span>
              {{ item.account_number }}
            </div>
        </div>
      </div>
      <p v-if="items.length === 0" class="text-center text-gray-400 py-6 italic">No data found.</p>
    </div>

    <!-- Pagination -->
    <div class="flex items-center justify-between mt-6 text-sm text-gray-600">
      <span>
        Showing {{ (currentPage - 1) * pageSize + 1 }} 
        to {{ Math.min(currentPage * pageSize, count) }} 
        of {{ count }} total entries
      </span>
      <div class="flex items-center gap-2">
        <button @click="fetchItems(currentPage - 1)" :disabled="!previousPage"
          class="px-3 py-1 border border-gray-300 rounded-lg hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed transition duration-150">← Previous</button>
        <span class="px-3 py-1 bg-green-600 text-white rounded-lg font-medium">{{ currentPage }}</span>
        <button @click="fetchItems(currentPage + 1)" :disabled="!nextPage"
          class="px-3 py-1 border border-gray-300 rounded-lg hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed transition duration-150">Next →</button>
      </div>
    </div>

    <!-- Add/Edit Modal -->
    <add-transactions v-if="showModal && !editMode" :data="selectedItem" @close="showModal=false" @saved="fetchItems"/>
    <edit-transactions v-if="showModal && editMode" :data="selectedItem" @close="showModal=false" @saved="fetchItems"/>

    <!-- Delete Confirmation Modal -->
    <delete-confirm-modal 
      :visible="deleteModalVisible"
      title="Delete Transactions"
      message="Are you sure you want to delete this transactions?"
      @confirm="confirmDelete"
      @cancel="deleteModalVisible=false"
    />
  </div>
</template>

<script>
import AddTransactions from "./AddTransactions.vue";
import EditTransactions from "./EditTransactions.vue";
import Loading from "@/components/Loading.vue";
import DeleteConfirmModal from "@/components/DeleteConfirmModal.vue";

export default {
  components: { AddTransactions, EditTransactions, Loading, DeleteConfirmModal },

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
      const params = { page: this.currentPage, page_size: this.pageSize, search: this.searchQuery };
      try {
        const response = await this.$apiGet('/transactions', params);
        this.items = response.data;
        this.count = response.count || 0;
        this.nextPage = response.next || null;
        this.previousPage = response.previous || null;
      } catch(e) { console.error(e); }
      finally { this.loading = false; }
    },

    openAddModal() { this.editMode = false; this.selectedItem = null; this.showModal = true; },
    editItem(item) { this.editMode = true; this.selectedItem = item; this.showModal = true; },
    
    // Navigate using static route name
    viewDetails(id) { 
      this.$router.push({ name: 'Transactions-detail', params: { id } });
    },

    openDeleteModal(id) { this.deleteId = id; this.deleteModalVisible = true; },

    // Delete with toast
    async confirmDelete() {
      const res = await this.$apiDelete('/transactions', this.deleteId);
      if(res) {
        this.$root.$refs.toast.showToast('Transactions deleted successfully', 'success');
      }
      this.deleteModalVisible = false;
      this.fetchItems(this.currentPage);
    },
  },

  mounted() { this.fetchItems(); }
};
</script>
