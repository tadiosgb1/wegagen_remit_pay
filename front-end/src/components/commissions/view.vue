<template>
  <div class="p-6 min-h-screen bg-gray-100">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-2xl font-bold">Commissions</h1>
      <button
        @click="showModal = true"
        class="px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600"
      >
        Add Commission
      </button>
    </div>

    <!-- Table -->
    <div class="overflow-x-auto bg-white shadow rounded-lg">
      <table class="w-full text-left">
        <thead class="bg-gray-200">
          <tr>
            <th class="px-4 py-2">SaaS Commission</th>
            <th class="px-4 py-2">Broker Commission</th>
            <th class="px-4 py-2">Total Commission</th>
            <th class="px-4 py-2">Property Sale</th>
            <th class="px-4 py-2">Created At</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="commission in commissions"
            :key="commission.id"
            class="border-b hover:bg-gray-50"
          >
            <td class="px-4 py-2">{{ commission.saas_commission }}</td>
            <td class="px-4 py-2">{{ commission.broker_commission }}</td>
            <td class="px-4 py-2">{{ commission.total_commission }}</td>
            <td class="px-4 py-2">{{ commission.property_sale_name || commission.property_sale }}</td>
            <td class="px-4 py-2">{{ commission.created_at | formatDate }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Add Commission Modal -->
    <AddCommission
      :visible="showModal"
      @close="showModal = false"
      @success="fetchCommissions"
    />
  </div>
</template>

<script>
import AddCommission from "./AddCommission.vue";

export default {
  name: "CommissionView",
  components: { AddCommission },
  data() {
    return {
      showModal: false,
      commissions: [],
    };
  },
  filters: {
    formatDate(value) {
      if (!value) return "";
      return new Date(value).toLocaleDateString();
    },
  },
  mounted() {
    this.fetchCommissions();
  },
  methods: {
    async fetchCommissions() {
      try {
        const res = await this.$apiGet("/get_commissions");
        this.commissions = res.data || [];
      } catch (err) {
        console.error("Failed to fetch commissions:", err);
      }
    },
  },
};
</script>
