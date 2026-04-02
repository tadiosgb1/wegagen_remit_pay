
<template>
  <div class="p-6 bg-gray-50 min-h-screen text-sm text-gray-800">
    <!-- Loading -->
    <Loading :visible="loading" message="Loading Transactions..." />

    <!-- Page Header -->
    <div class="flex items-center justify-between mb-6 border-b pb-4 border-gray-200">
      <h1 class="text-lg font-bold text-gray-800">Transactions Detail</h1>
    </div>

    <!-- Detail Card -->
    <div class="bg-white overflow-hidden rounded-md border border-gray-200 p-4 hidden md:block space-y-2">
      <div><strong>ID:</strong> {{ item.id }}</div>
      <div><strong>Reference_no:</strong> {{ item.reference_no }}</div><div><strong>Sender_id:</strong> {{ item.sender_id }}</div><div><strong>Amount_original:</strong> {{ item.amount_original }}</div><div><strong>Currency:</strong> {{ item.currency }}</div><div><strong>Exchange_rate:</strong> {{ item.exchange_rate }}</div><div><strong>Amount_etb:</strong> {{ item.amount_etb }}</div><div><strong>Status:</strong> {{ item.status }}</div><div><strong>Payment_method:</strong> {{ item.payment_method }}</div><div><strong>Delivery_method:</strong> {{ item.delivery_method }}</div><div><strong>Receiver_full_name:</strong> {{ item.receiver_full_name }}</div><div><strong>Receiver_phone:</strong> {{ item.receiver_phone }}</div><div><strong>Receiver_email:</strong> {{ item.receiver_email }}</div><div><strong>Bank_name:</strong> {{ item.bank_name }}</div><div><strong>Account_number:</strong> {{ item.account_number }}</div>
    </div>

    <!-- Mobile View -->
    <div class="md:hidden bg-white rounded-md border border-gray-200 p-4 space-y-2">
      <div><strong>ID:</strong> {{ item.id }}</div>
      <div><strong>Reference_no:</strong> {{ item.reference_no }}</div><div><strong>Sender_id:</strong> {{ item.sender_id }}</div><div><strong>Amount_original:</strong> {{ item.amount_original }}</div><div><strong>Currency:</strong> {{ item.currency }}</div><div><strong>Exchange_rate:</strong> {{ item.exchange_rate }}</div><div><strong>Amount_etb:</strong> {{ item.amount_etb }}</div><div><strong>Status:</strong> {{ item.status }}</div><div><strong>Payment_method:</strong> {{ item.payment_method }}</div><div><strong>Delivery_method:</strong> {{ item.delivery_method }}</div><div><strong>Receiver_full_name:</strong> {{ item.receiver_full_name }}</div><div><strong>Receiver_phone:</strong> {{ item.receiver_phone }}</div><div><strong>Receiver_email:</strong> {{ item.receiver_email }}</div><div><strong>Bank_name:</strong> {{ item.bank_name }}</div><div><strong>Account_number:</strong> {{ item.account_number }}</div>
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
      const response = await this.$apiGetById('/transactions', id);
      this.item = response || {};
    } catch (error) {
      console.error(error);
    } finally {
      this.loading = false;
    }
  },
};
</script>
