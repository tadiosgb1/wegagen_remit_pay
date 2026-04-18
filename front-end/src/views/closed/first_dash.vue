<template>
  <div class="m-4">

    <!-- 🔷 STAT CARDS -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">

      <div class="card">
        <p class="label">Admin Users</p>
        <h2 class="value">{{ stats.adminUsers }}</h2>
      </div>

      <div class="card">
        <p class="label text-green-600">KYC Approved</p>
        <h2 class="value">{{ stats.kycApproved }}</h2>
      </div>

      <div class="card">
        <p class="label text-red-500">KYC Not Approved</p>
        <h2 class="value">{{ stats.kycNotApproved }}</h2>
      </div>

      <div class="card">
        <p class="label text-blue-500">Total Transactions</p>
        <h2 class="value">{{ totalTransactions }}</h2>
      </div>

    </div>

    <!-- 🔷 CHARTS -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">

      <!-- Transactions Chart -->
      <div class="bg-white p-6 rounded-2xl shadow">
        <h3 class="font-bold mb-4">Transactions (Account vs Cash Pickup)</h3>
        <apexchart
          type="bar"
          height="300"
          :options="transactionChartOptions"
          :series="transactionSeries"
        />
      </div>

      <!-- KYC Chart -->
      <div class="bg-white p-6 rounded-2xl shadow">
        <h3 class="font-bold mb-4">KYC Customers</h3>
        <apexchart
          type="donut"
          height="300"
          :options="kycChartOptions"
          :series="kycSeries"
        />
      </div>

    </div>

    <!-- 🔷 TRANSACTION TABLE -->
    <div class="bg-white p-6 rounded-2xl shadow">
      <h3 class="font-bold mb-4">Recent Transactions</h3>

      <table class="w-full text-sm">
        <thead>
          <tr class="border-b text-left">
            <th>Customer</th>
            <th>Type</th>
            <th>Amount</th>
            <th>Status</th>
          </tr>
        </thead>

        <tbody>
          <tr v-for="tx in transactions" :key="tx.id" class="border-b">
            <td>{{ tx.name }}</td>
            <td>{{ tx.type }}</td>
            <td>{{ tx.amount }}</td>
            <td>
              <span
                :class="tx.status === 'Completed' ? 'text-green-600' : 'text-yellow-500'"
              >
                {{ tx.status }}
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

  </div>
</template>

<script>
export default {
  data() {
    return {
      // 🔹 SAMPLE DATA
      stats: {
        adminUsers: 10,
        kycApproved: 250,
        kycNotApproved: 70,
      },

      transactions: [
        { id: 1, name: "Abel T.", type: "Account Holder", amount: "$500", status: "Completed" },
        { id: 2, name: "Marta K.", type: "Cash Pickup", amount: "$300", status: "Pending" },
        { id: 3, name: "Samuel G.", type: "Account Holder", amount: "$900", status: "Completed" },
      ],

      // 🔹 TRANSACTION CHART
      transactionSeries: [
        {
          name: "Transactions",
          data: [35, 20], // Account Holder, Cash Pickup
        },
      ],

      transactionChartOptions: {
        chart: {
          toolbar: { show: false },
        },
        xaxis: {
          categories: ["Account Holder", "Cash Pickup"],
        },
        dataLabels: {
          enabled: true,
        },
      },

      // 🔹 KYC CHART
      kycSeries: [250, 70],

      kycChartOptions: {
        labels: ["Approved", "Not Approved"],
        legend: {
          position: "bottom",
        },
      },
    };
  },

  computed: {
    totalTransactions() {
      return this.transactions.length;
    },
  },
};
</script>

<style scoped>
.card {
  background: white;
  padding: 20px;
  border-radius: 16px;
  box-shadow: 0 4px 10px rgba(0,0,0,0.05);
}

.label {
  font-size: 12px;
  color: #64748b;
}

.value {
  font-size: 24px;
  font-weight: bold;
}
</style>