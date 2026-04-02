<template>
  <div class="space-y-8">

    <!-- Overview Stats -->
    <div class="grid grid-cols-1 sm:grid-cols-3 lg:grid-cols-4 gap-6">
      <div v-for="stat in stats" :key="stat.label" class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200 hover:shadow-lg transition-all">
        <div class="flex justify-between items-center">
          <div>
            <h2 class="text-xs font-bold text-slate-400 uppercase">{{ stat.label }}</h2>
            <p class="text-2xl font-black text-slate-800">{{ stat.value }}</p>
          </div>
         <div :class="['w-12 h-12 flex items-center justify-center rounded-xl', stat.iconBg]">
  <i :class="['text-xl', stat.icon, stat.iconColor]"></i>
</div>
        </div>
      </div>
    </div>

    <!-- Chart Section -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
      <div class="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
        <h3 class="font-bold text-slate-800 mb-4 uppercase text-sm">Total Organizations</h3>
        <apexchart type="bar" height="300" :options="orgChartOptions" :series="orgChartSeries" />
      </div>

      <div class="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
        <h3 class="font-bold text-slate-800 mb-4 uppercase text-sm">Registered Users</h3>
        <apexchart type="line" height="300" :options="userChartOptions" :series="userChartSeries" />
      </div>
    </div>

  </div>
</template>

<script>
import ApexCharts from "apexcharts";
import VueApexCharts from "vue3-apexcharts";

export default {
  name: "SuperDashboard",
  components: { apexchart: VueApexCharts },
  data() {
    return {
      stats: [
        { label: "Total Organizations", value: 42, icon: "fas fa-building", iconBg: "bg-blue-50", iconColor: "text-blue-500" },
        { label: "Total Users", value: 512, icon: "fas fa-users", iconBg: "bg-green-50", iconColor: "text-green-500" },
        { label: "Tests Taken", value: 1284, icon: "fas fa-file-alt", iconBg: "bg-purple-50", iconColor: "text-purple-600" },
        { label: "Active Admins", value: 18, icon: "fas fa-user-shield", iconBg: "bg-amber-50", iconColor: "text-amber-500" },
      ],
      orgChartSeries: [{ name: "Organizations", data: [5, 8, 6, 10, 13] }],
      orgChartOptions: {
        chart: { toolbar: { show: false } },
        xaxis: { categories: ["Jan", "Feb", "Mar", "Apr", "May"] },
        colors: ["#6366f1"],
        dataLabels: { enabled: false },
        stroke: { curve: "smooth" },
      },
      userChartSeries: [{ name: "Users", data: [12, 18, 25, 32, 40] }],
      userChartOptions: {
        chart: { toolbar: { show: false } },
        xaxis: { categories: ["Jan", "Feb", "Mar", "Apr", "May"] },
        colors: ["#10b981"],
        dataLabels: { enabled: false },
        stroke: { curve: "smooth" },
      },
    };
  },
};
</script>

<style scoped>
</style>