<template>
  <div class="p-6 bg-gray-50 min-h-screen text-sm text-gray-800 relative">
    
    <Loading :visible="loading" message="Loading KYC..." />

    <!-- Header -->
    <div class="flex items-center justify-between mb-6 border-b pb-4 border-gray-200">
      <h1 class="text-lg font-bold">KYC</h1>

      <!-- <button @click="openAddModal"
        class="bg-primary hover:bg-primary text-white px-4 py-2 rounded-lg flex items-center space-x-1">
        <span>Add KYC</span>
      </button> -->
    </div>

 

    <!-- Search -->
    <div class="flex justify-between mb-6">
      <input v-model="searchQuery" @input="fetchItems(1)"
        class="border px-4 py-2 rounded-lg w-60"
        placeholder="Search..." />

      <select v-model="pageSize" @change="fetchItems(1)"
        class="border px-2 py-1 rounded-lg">
        <option v-for="size in [5,10,20,50,100]" :key="size" :value="size">{{ size }}</option>
      </select>
    </div>

    <!-- TABLE -->
    <div class="bg-white rounded-xl border hidden md:block">
      <table class="min-w-full text-sm">
        <thead class="bg-gray-100 text-xs uppercase">
          <tr>
            <th class="p-3">#</th>
            <th>Id Type</th>
            <th>Dob</th>
            <th>Address</th>
            <th>City</th>
            <th>Country</th>
            <th>ID Photo</th>
            <th>Selfie</th>
            <th>User</th>
            <th>Status</th>
            <th class="text-center">Actions</th>
          </tr>
        </thead>

        <tbody>
          <tr v-for="(item, index) in items" :key="item.id" class="border-t">
            
            <td class="p-3">{{ index + 1 }}</td>
            <td>{{ item.id_type }}</td>
            <td>{{ item.dob }}</td>
            <td>{{ item.address }}</td>
            <td>{{ item.city }}</td>
            <td>{{ item.country }}</td>

            <!-- ✅ ID PHOTO -->
            <td>
              <img
                v-if="item.id_photo_path"
                :src="item.id_photo_path"
                class="w-16 h-16 object-cover rounded border"
              />
            </td>

            <!-- ✅ SELFIE -->
            <td>
              <img
                v-if="item.selfie_photo_path"
                :src="item.selfie_photo_path"
                class="w-16 h-16 object-cover rounded border"
              />
            </td>

            <td>{{ item.user }}</td>

            <!-- STATUS -->
            <td>
              <span
                :class="item.verified ? 'text-primary' : 'text-red-500'"
                class="font-semibold">
                {{ item.verified ? 'Verified' : 'Unverified' }}
              </span>
            </td>

            <!-- ACTIONS -->
            <td class="text-center space-x-2">

              <button @click="viewDetails(item.id)" class="text-primary">👁</button>
              <button @click="openDeleteModal(item.id)" class="text-red-500">🗑</button>
              <!-- ✅ VERIFY -->
              <button
                v-if="!item.verified"
                @click="verifyKYC(item.id, true)"
                class="text-primary font-bold">
                ✔
              </button>

              <!-- ✅ UNVERIFY -->
              <button
                v-if="item.verified"
                @click="unverifyKYC(item.id, false)"
                class="text-yellow-600 font-bold">
                ✖
              </button>

            </td>
          </tr>

          <tr v-if="items.length === 0">
            <td colspan="11" class="text-center py-6 text-gray-400">No data</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- PAGINATION -->
    <div class="flex justify-between mt-6">
      <span>
        Showing {{ (currentPage - 1) * pageSize + 1 }}
        to {{ Math.min(currentPage * pageSize, count) }}
        of {{ count }}
      </span>

      <div class="space-x-2">
        <button @click="fetchItems(currentPage - 1)" :disabled="!previousPage">Prev</button>
        <button @click="fetchItems(currentPage + 1)" :disabled="!nextPage">Next</button>
      </div>
    </div>

    <!-- MODALS -->
    <AddKYC v-if="showModal && !editMode" @close="showModal=false" @saved="fetchItems"/>
    <EditKYC v-if="showModal && editMode" :data="selectedItem" @close="showModal=false" @saved="fetchItems"/>

    <delete-confirm-modal
      :visible="deleteModalVisible"
      @confirm="confirmDelete"
      @cancel="deleteModalVisible=false"
    />

  </div>
</template>

<script>
import AddKYC from "./AddKYC.vue";
import EditKYC from "./EditKYC.vue";
import Loading from "@/components/Loading.vue";
import DeleteConfirmModal from "@/components/DeleteConfirmModal.vue";

export default {
  components: { AddKYC, EditKYC, Loading, DeleteConfirmModal },

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
        const res = await this.$apiGet("/kyc", {
          page,
          page_size: this.pageSize,
          search: this.searchQuery
        });

        this.items = res.data;
        this.count = res.count;
        this.nextPage = res.next;
        this.previousPage = res.previous;

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

    viewDetails(id) {
      this.$router.push({ name: "KYC-detail", params: { id } });
    },

    openDeleteModal(id) {
      this.deleteId = id;
      this.deleteModalVisible = true;
    },

    async confirmDelete() {
      await this.$apiDelete("/kyc", this.deleteId);
      this.deleteModalVisible = false;
      this.fetchItems(this.currentPage);
    },

    // ✅ VERIFY / UNVERIFY
 async verifyKYC(id, status) {


  console.log(id);


  const payload={
     //verified: status
  }
  try {
    await this.$apiPatch(`/kyc/${id}/verify`, '',payload);

    this.$root.$refs.toast.showToast(
       "KYC Verified" ,
      "success"
    );

    this.fetchItems(this.currentPage);

  } catch (e) {
    console.error(e);
  }
},

async unverifyKYC(id, status) {
   console.log(id);
  const payload={
    // verified: status
  }
  try {
    await this.$apiPatch(`/kyc/${id}/unverify`, '',payload);

    this.$root.$refs.toast.showToast(
      "KYC Unverified",
      "success"
    );

    this.fetchItems(this.currentPage);

  } catch (e) {
    console.error(e);
  }
}

  },

  mounted() {
    this.fetchItems();
  }
};
</script>