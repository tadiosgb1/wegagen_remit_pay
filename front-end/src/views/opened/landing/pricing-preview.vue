<template>
  <section class="py-24 bg-white relative overflow-hidden">
    <div class="absolute top-1/2 left-0 -translate-y-1/2 w-64 h-64 bg-primary/5 rounded-full blur-[100px]"></div>
    <div class="absolute bottom-0 right-0 w-96 h-96 bg-secondary/5 rounded-full blur-[120px]"></div>

    <div class="max-w-7xl mx-auto px-6 relative z-10">
      <div class="bg-slate-900 rounded-[4rem] overflow-hidden shadow-2xl flex flex-col lg:flex-row items-stretch border border-white/5">
        
        <div class="lg:w-2/5 p-12 md:p-20 bg-gradient-to-br from-slate-800 to-slate-950 flex flex-col justify-between border-r border-white/5">
          <div>
            <span class="inline-block px-4 py-1 rounded-full bg-primary/20 border border-primary/30 text-primary text-[10px] font-black uppercase tracking-widest mb-6">
              Volume Pricing
            </span>
            <h3 class="text-4xl font-black text-white mb-4 tracking-tighter">
              Scale without <br/> <span class="text-secondary italic">overpaying.</span>
            </h3>
            <p class="text-slate-400 text-sm font-medium leading-relaxed mb-12">
              Our automated tier-system reduces your cost per message as your volume grows. No manual negotiation required.
            </p>
          </div>

          <div class="space-y-2">
            <div class="text-[10px] font-black text-slate-500 uppercase tracking-[0.3em]">Starting From</div>
            <div class="flex items-baseline gap-2">
              <span class="text-6xl font-black text-white italic tracking-tighter">0.22</span>
              <span class="text-xl font-black text-primary uppercase">ETB</span>
              <span class="text-xs font-bold text-slate-500">/msg</span>
            </div>
          </div>
        </div>

        <div class="lg:w-3/5 p-12 md:p-20 bg-slate-900 flex flex-col justify-center">
          <div class="grid md:grid-cols-2 gap-12 mb-16">
            <div v-for="feat in quickFeatures" :key="feat.title" class="group">
              <div class="w-12 h-12 rounded-2xl bg-white/5 flex items-center justify-center text-primary text-xl mb-6 group-hover:bg-primary group-hover:text-white transition-all duration-500">
                <i :class="feat.icon"></i>
              </div>
              <h4 class="text-lg font-black text-white mb-2 uppercase tracking-tight">{{ feat.title }}</h4>
              <p class="text-slate-500 text-xs font-medium leading-relaxed">{{ feat.desc }}</p>
            </div>
          </div>

          <div class="flex flex-col sm:flex-row items-center gap-8 pt-10 border-t border-white/5">
            <router-link to="/pricing" class="w-full sm:w-auto px-12 py-5 bg-white text-slate-900 rounded-2xl font-black uppercase tracking-widest text-xs hover:bg-secondary transition-all text-center shadow-xl hover:-translate-y-1">
              View Detailed Plans
            </router-link>
            <div class="flex items-center gap-4 group cursor-pointer">
              <span class="text-[10px] font-black text-slate-400 uppercase tracking-widest group-hover:text-white transition-colors">Calculator Cost</span>
              <div class="w-8 h-8 rounded-full border border-white/10 flex items-center justify-center text-white text-[10px] group-hover:border-primary transition-all">
                <i class="fas fa-chevron-right"></i>
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>
  </section>
</template>

<script>
export default {
  name: 'PricingPreview',
  data() {
    return {
      quickFeatures: [
        { 
          title: "Zero Setup Fee", 
          icon: "fas fa-coins", 
          desc: "Start integrating our API without any upfront infrastructure costs or hidden charges." 
        },
        { 
          title: "Enterprise SLA", 
          icon: "fas fa-handshake-angle", 
          desc: "99.99% uptime guarantee for business and aggregator tiers with direct carrier binds." 
        },
        { 
          title: "Global Reach", 
          icon: "fas fa-globe", 
          desc: "Seamlessly send to international networks at competitive USD rates alongside local ETB." 
        },
        { 
          title: "Real-time DLRs", 
          icon: "fas fa-bolt", 
          desc: "Track every cent with instant delivery reports pushed directly to your webhooks." 
        }
      ]
    }
  }
}
</script>

<style scoped>
/* Smooth entrance for the italic price */
.italic {
  font-family: 'Inter', sans-serif; /* Or your specific brand font */
  font-style: italic;
}
</style>