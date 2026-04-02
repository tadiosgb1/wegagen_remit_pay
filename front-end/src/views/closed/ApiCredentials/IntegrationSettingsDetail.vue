
<template>
  <div class="p-6 bg-gray-50 min-h-screen text-sm text-gray-800">
    <!-- Loading -->
    <Loading :visible="loading" message="Loading IntegrationSettings..." />

    <!-- Page Header -->
    <div class="flex items-center justify-between mb-6 border-b pb-4 border-gray-200">
      <h1 class="text-lg font-bold text-gray-800">IntegrationSettings Detail</h1>
    </div>

    <!-- Detail Card -->
    <div class="bg-white overflow-hidden rounded-md border border-gray-200 p-4 hidden md:block space-y-2">
      <div><strong>ID:</strong> {{ item.id }}</div>
      <div><strong>Provider_name:</strong> {{ item.provider_name }}</div><div><strong>Merchant_id:</strong> {{ item.merchant_id }}</div><div><strong>Profile_id:</strong> {{ item.profile_id }}</div><div><strong>Access_key:</strong> {{ item.access_key }}</div><div><strong>Secret_key:</strong> {{ item.secret_key }}</div><div><strong>Shared_secret_key:</strong> {{ item.shared_secret_key }}</div><div><strong>Environment:</strong> {{ item.environment }}</div><div><strong>Is_active:</strong> {{ item.is_active }}</div>
    </div>

    <!-- Mobile View -->
    <div class="md:hidden bg-white rounded-md border border-gray-200 p-4 space-y-2">
      <div><strong>ID:</strong> {{ item.id }}</div>
      <div><strong>Provider_name:</strong> {{ item.provider_name }}</div><div><strong>Merchant_id:</strong> {{ item.merchant_id }}</div><div><strong>Profile_id:</strong> {{ item.profile_id }}</div><div><strong>Access_key:</strong> {{ item.access_key }}</div><div><strong>Secret_key:</strong> {{ item.secret_key }}</div><div><strong>Shared_secret_key:</strong> {{ item.shared_secret_key }}</div><div><strong>Environment:</strong> {{ item.environment }}</div><div><strong>Is_active:</strong> {{ item.is_active }}</div>
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
      const response = await this.$apiGetById('/integrationsettings', id);
      this.item = response || {};
    } catch (error) {
      console.error(error);
    } finally {
      this.loading = false;
    }
  },
};
</script>
