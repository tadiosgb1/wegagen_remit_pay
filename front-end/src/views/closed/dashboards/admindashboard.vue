<template>
  <div class="space-y-8">

    <!-- Org Stats -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
      <div v-for="stat in stats" :key="stat.label" class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200 hover:shadow-lg transition-all">
        <div class="flex justify-between items-center">
          <div>
            <h2 class="text-xs font-bold text-slate-400 uppercase">{{ stat.label }}</h2>
            <p class="text-2xl font-black text-slate-800">{{ stat.value }}</p>
          </div>
         <!-- Corrected -->
<div :class="['w-12 h-12 flex items-center justify-center rounded-xl', stat.iconBg]">
  <i :class="['text-xl', stat.icon, stat.iconColor]"></i>
</div>
        </div>
      </div>
    </div>

    <!-- Org Charts -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
      <div class="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
        <h3 class="font-bold text-slate-800 mb-4 uppercase text-sm">Employee Test Scores</h3>
        <apexchart type="bar" height="300" :options="testChartOptions" :series="testChartSeries" />
      </div>

      <div class="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
        <h3 class="font-bold text-slate-800 mb-4 uppercase text-sm">Test Participation</h3>
        <apexchart type="line" height="300" :options="participationChartOptions" :series="participationChartSeries" />
      </div>
    </div>

  </div>
</template>

<script>
import VueApexCharts from "vue3-apexcharts";

export default {
  name: "AdminDashboard",
  components: { apexchart: VueApexCharts },
  data() {
    return {
      stats: [
        { label: "Total Employees", value: 120, icon: "fas fa-users", iconBg: "bg-green-50", iconColor: "text-green-500" },
        { label: "Tests Taken", value: 400, icon: "fas fa-file-alt", iconBg: "bg-purple-50", iconColor: "text-purple-600" },
        { label: "Pending Tests", value: 25, icon: "fas fa-clock", iconBg: "bg-amber-50", iconColor: "text-amber-500" },
        { label: "Completed Tests", value: 375, icon: "fas fa-check-circle", iconBg: "bg-blue-50", iconColor: "text-blue-500" },
      ],
      testChartSeries: [{ name: "Scores", data: [70, 85, 78, 90, 95] }],
      testChartOptions: { chart: { toolbar: { show: false } }, xaxis: { categories: ["Emp1", "Emp2", "Emp3", "Emp4", "Emp5"] }, colors: ["#6366f1"], dataLabels: { enabled: false } },
      participationChartSeries: [{ name: "Participation", data: [10, 15, 20, 25, 30] }],
      participationChartOptions: { chart: { toolbar: { show: false } }, xaxis: { categories: ["Week1", "Week2", "Week3", "Week4", "Week5"] }, colors: ["#10b981"], dataLabels: { enabled: false } },
    };
  },
};
</script>

<style scoped>
</style>