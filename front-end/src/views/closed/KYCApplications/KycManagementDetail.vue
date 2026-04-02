
<template>
  <div class="p-6 bg-gray-50 min-h-screen text-sm text-gray-800">
    <!-- Loading -->
    <Loading :visible="loading" message="Loading KycManagement..." />

    <!-- Page Header -->
    <div class="flex items-center justify-between mb-6 border-b pb-4 border-gray-200">
      <h1 class="text-lg font-bold text-gray-800">KycManagement Detail</h1>
    </div>

    <!-- Detail Card -->
    <div class="bg-white overflow-hidden rounded-md border border-gray-200 p-4 hidden md:block space-y-2">
      <div><strong>ID:</strong> {{ item.id }}</div>
      <div><strong>User_id:</strong> {{ item.user_id }}</div><div><strong>Document_type:</strong> {{ item.document_type }}</div><div><strong>Document_number:</strong> {{ item.document_number }}</div><div><strong>Id_image_url:</strong> {{ item.id_image_url }}</div><div><strong>Selfie_url:</strong> {{ item.selfie_url }}</div><div><strong>Status:</strong> {{ item.status }}</div><div><strong>Rejection_reason:</strong> {{ item.rejection_reason }}</div>
    </div>

    <!-- Mobile View -->
    <div class="md:hidden bg-white rounded-md border border-gray-200 p-4 space-y-2">
      <div><strong>ID:</strong> {{ item.id }}</div>
      <div><strong>User_id:</strong> {{ item.user_id }}</div><div><strong>Document_type:</strong> {{ item.document_type }}</div><div><strong>Document_number:</strong> {{ item.document_number }}</div><div><strong>Id_image_url:</strong> {{ item.id_image_url }}</div><div><strong>Selfie_url:</strong> {{ item.selfie_url }}</div><div><strong>Status:</strong> {{ item.status }}</div><div><strong>Rejection_reason:</strong> {{ item.rejection_reason }}</div>
    </div>

    <button @click="$router.back()" class="mt-4 text-blue-600 hover:underline">Back</button>
  </div>
</template>

<script>
import Loading from "@/components/Loading.vue";

export default {
  components: { Loading },
  data() {
    return {
      item: {},
      loading: false,
    };
  },
  async mounted() {
    this.loading = true;
    const id = this.$route.params.id;
    try {
      const response = await this.$apiGetById('/kycmanagement', id);
      this.item = response || {};
    } catch (error) {
      console.error(error);
    } finally {
      this.loading = false;
    }
  },
};
</script>
