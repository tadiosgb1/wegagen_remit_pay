<template>
  <div class="space-y-8">

    <!-- User Test Summary -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
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

    <!-- User Test History -->
    <div class="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
      <h3 class="font-bold text-slate-800 mb-4 uppercase text-sm">My Test Scores</h3>
      <apexchart type="line" height="300" :options="scoreChartOptions" :series="scoreChartSeries" />
    </div>

  </div>
</template>

<script>
import VueApexCharts from "vue3-apexcharts";

export default {
  name: "UserDashboard",
  components: { apexchart: VueApexCharts },
  data() {
    return {
      stats: [
        { label: "Tests Taken", value: 12, icon: "fas fa-file-alt", iconBg: "bg-purple-50", iconColor: "text-purple-600" },
        { label: "Average Score", value: "78%", icon: "fas fa-chart-line", iconBg: "bg-amber-50", iconColor: "text-amber-500" },
        { label: "Pending Tests", value: 3, icon: "fas fa-clock", iconBg: "bg-blue-50", iconColor: "text-blue-500" },
      ],
      scoreChartSeries: [{ name: "Score", data: [65, 70, 80, 75, 90, 85, 78] }],
      scoreChartOptions: { chart: { toolbar: { show: false } }, xaxis: { categories: ["Test1", "Test2", "Test3", "Test4", "Test5", "Test6", "Test7"] }, stroke: { curve: "smooth" }, dataLabels: { enabled: false }, colors: ["#6366f1"] },
    };
  },
};
</script>

<style scoped>
</style>