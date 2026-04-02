<template>
  <section id="features" class="py-32 bg-[#fafafa] relative overflow-hidden">
    <div class="absolute inset-0 z-0 opacity-[0.05] pointer-events-none">
      <div class="absolute inset-0 bg-[linear-gradient(to_right,#3d5afe_1px,transparent_1px),linear-gradient(to_bottom,#3d5afe_1px,transparent_1px)] bg-[size:60px_60px]"></div>
      <div class="absolute inset-0 bg-gradient-to-b from-white via-transparent to-white"></div>
    </div>

    <div class="max-w-7xl mx-auto px-6 relative z-10">
      
      <div class="max-w-4xl mb-24">
        <div class="flex items-center gap-4 mb-6">
          <span class="h-[1px] w-12 bg-primary"></span>
          <span class="text-[10px] font-black tracking-[0.4em] text-primary uppercase">Alpha Psychometrics 1.0</span>
        </div>
        <h2 class="text-5xl md:text-7xl font-black text-slate-900 mb-8 tracking-tighter leading-none">
          Scientific Insights for <br/>
          <span class="text-transparent bg-clip-text bg-gradient-to-r from-primary to-blue-400">Human Development.</span>
        </h2>
        <p class="text-slate-500 text-xl font-medium leading-relaxed max-w-2xl border-l-4 border-slate-100 pl-8">
          Alpha provides the core engine for modern evaluations, transforming raw test data into actionable behavioral intelligence for schools and corporations.
        </p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-1px bg-slate-200 border border-slate-200 rounded-[3rem] overflow-hidden shadow-2xl">
        
        <div v-for="(feature, index) in features" :key="index"
          class="group relative bg-white p-12 transition-all duration-700 hover:bg-slate-50 cursor-default"
        >
          <div class="absolute -inset-px bg-gradient-to-br from-primary/20 to-secondary/20 opacity-0 group-hover:opacity-100 transition-opacity duration-500 blur-xl z-0"></div>

          <div class="relative z-10">
            <div class="relative w-16 h-16 mb-10">
              <div class="absolute inset-0 bg-primary/5 rounded-2xl group-hover:scale-110 group-hover:rotate-12 transition-all duration-500"></div>
              <div class="relative w-16 h-16 bg-white shadow-xl rounded-2xl flex items-center justify-center text-primary group-hover:bg-primary group-hover:text-white transition-all duration-500 transform group-hover:-translate-y-2">
                <i :class="[feature.icon, 'text-2xl']"></i>
              </div>
            </div>

            <h3 class="text-2xl font-black text-slate-900 mb-4 tracking-tight group-hover:text-primary transition-colors">
              {{ feature.title }}
            </h3>
            <p class="text-slate-500 text-sm leading-relaxed font-medium mb-10 h-12 overflow-hidden">
              {{ feature.description }}
            </p>
            
            <div class="flex flex-wrap gap-2 mb-10">
              <span v-for="point in feature.points" :key="point" 
                class="px-3 py-1 bg-slate-100 text-[9px] font-black uppercase tracking-tighter text-slate-500 rounded-md border border-transparent group-hover:border-primary/20 group-hover:bg-white transition-all">
                {{ point }}
              </span>
            </div>

            <div class="flex items-center gap-3 text-[10px] font-black text-slate-300 uppercase tracking-[0.2em] group-hover:text-primary transition-all">
              <span>View Module</span>
              <div class="h-px w-0 bg-primary group-hover:w-8 transition-all duration-500"></div>
              <i class="fas fa-arrow-right opacity-0 group-hover:opacity-100 -translate-x-2 group-hover:translate-x-0 transition-all"></i>
            </div>
          </div>
        </div>
      </div>

      <div class="mt-12 bg-slate-900 rounded-[3rem] p-12 lg:p-20 relative overflow-hidden group/stats">
        <div class="absolute inset-0 overflow-hidden">
          <div class="absolute top-0 left-1/4 w-[1px] h-full bg-gradient-to-b from-transparent via-primary/40 to-transparent"></div>
          <div class="absolute top-0 left-2/4 w-[1px] h-full bg-gradient-to-b from-transparent via-secondary/40 to-transparent"></div>
          <div class="absolute top-0 left-3/4 w-[1px] h-full bg-gradient-to-b from-transparent via-primary/40 to-transparent"></div>
        </div>
        
        <div class="relative z-10 grid grid-cols-2 lg:grid-cols-4 gap-12">
          <div v-for="stat in stats" :key="stat.label" class="text-center lg:text-left">
            <div class="text-[10px] font-black text-primary uppercase tracking-[0.4em] mb-4">{{ stat.label }}</div>
            <div class="text-4xl lg:text-6xl font-black text-white tracking-tighter tabular-nums group-hover/stats:scale-110 transition-transform duration-700 origin-left">
              {{ stat.value }}
            </div>
          </div>
        </div>
      </div>

    </div>
  </section>
</template>

<script>
export default {
  data() {
    return {
      features: [
        {
          title: "Adaptive Engine",
          icon: "fas fa-brain",
          description: "Smart question-branching that adjusts difficulty based on real-time participant responses.",
          points: ["31 Story Points", "Logic Branching", "Timed Sections"]
        },
        {
          title: "Deep Analysis",
          icon: "fas fa-chart-line",
          description: "Proprietary scoring algorithms that convert data into 16-factor behavioral profiles.",
          points: ["21 Story Points", "Trait Mapping", "Visual Reports"]
        },
        {
          title: "Multi-Tenant Admin",
          icon: "fas fa-users-gear",
          description: "Separate management silos for individual test-takers and large-scale organizational clients.",
          points: ["18 Story Points", "Bulk Invitations", "Role Controls"]
        },
        {
          title: "Progress Tracker",
          icon: "fas fa-timeline",
          description: "Historical data visualization to monitor student or employee growth over long durations.",
          points: ["13 Story Points", "Growth Curves", "Benchmarking"]
        },
        {
          title: "Payment Vault",
          icon: "fas fa-vault",
          description: "Secure Cybersource integration for individual testing credits and organizational billing.",
          points: ["Non-Functional", "PCI Compliant", "Instant Credits"]
        },
        {
          title: "Secure Proctoring",
          icon: "fas fa-user-shield",
          description: "Advanced non-functional security layers to prevent test manipulation and ensure data integrity.",
          points: ["26 Story Points", "IP Tracking", "Session Lock"]
        }
      ],
      stats: [
        { label: "Accuracy Rate", value: "98.4%" },
        { label: "Concurrent Tests", value: "2k/sec" },
        { label: "Test Templates", value: "150+" },
        { label: "Reports Generated", value: "1M+" }
      ]
    };
  }
};
</script>

<style scoped>
.gap-1px {
  gap: 1px;
}
.group:hover .relative.z-10 {
  transform: translateY(-5px);
  transition: transform 0.5s cubic-bezier(0.16, 1, 0.3, 1);
}
.tabular-nums {
  font-variant-numeric: tabular-nums;
}
</style>