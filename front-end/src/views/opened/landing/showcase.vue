<template>
  <div class="min-h-screen bg-white font-sans selection:bg-primary/10">
    <Header />

    <main class="pt-20">
      <section class="bg-slate-900 py-32 relative overflow-hidden">
        <div class="absolute inset-0 opacity-10">
          <div class="absolute -top-24 -left-24 w-96 h-96 bg-primary rounded-full blur-[120px]"></div>
          <div class="absolute top-1/2 right-0 w-64 h-64 bg-secondary rounded-full blur-[100px]"></div>
        </div>
        
        <div class="max-w-7xl mx-auto px-6 relative z-10 text-center">
          <h2 class="text-secondary text-xs font-black uppercase tracking-[0.6em] mb-6">Case Studies</h2>
          <h1 class="text-5xl md:text-7xl font-black text-white tracking-tighter mb-8 italic">
            ALPHA IN THE WILD<span class="text-primary">.</span>
          </h1>
          <p class="max-w-2xl mx-auto text-slate-400 text-lg font-medium leading-relaxed">
            From rapid-scale FinTech to government infrastructure, discover how the world’s most ambitious teams use Alpha to move data.
          </p>
        </div>
      </section>

      <div class="sticky top-[72px] z-40 bg-white/80 backdrop-blur-xl border-b border-slate-100">
        <div class="max-w-7xl mx-auto px-6 flex items-center justify-center gap-8 py-4 overflow-x-auto no-scrollbar">
          <button 
            v-for="cat in categories" :key="cat"
            @click="activeCategory = cat"
            :class="activeCategory === cat ? 'text-primary' : 'text-slate-400 hover:text-slate-900'"
            class="text-[10px] font-black uppercase tracking-widest transition-all whitespace-nowrap"
          >
            {{ cat }}
          </button>
        </div>
      </div>

      <section class="max-w-7xl mx-auto px-6 py-24">
        <div class="grid lg:grid-cols-2 gap-16">
          <div 
            v-for="(item, index) in filteredShowcase" 
            :key="item.title"
            class="group cursor-pointer"
            :class="index % 2 !== 0 ? 'lg:mt-24' : ''"
          >
            <div class="relative aspect-[16/10] bg-slate-100 rounded-[2.5rem] overflow-hidden mb-8 shadow-sm group-hover:shadow-2xl transition-all duration-700">
              <div class="absolute inset-0 bg-gradient-to-br" :class="item.gradient"></div>
              <div class="absolute inset-0 flex items-center justify-center">
                <i :class="item.icon" class="text-white text-8xl opacity-20 group-hover:scale-110 group-hover:opacity-40 transition-all duration-700"></i>
              </div>
              <div class="absolute bottom-6 left-6 px-4 py-2 bg-white/10 backdrop-blur-md rounded-xl border border-white/20">
                <span class="text-white text-[10px] font-black uppercase tracking-widest">{{ item.metric }}</span>
              </div>
            </div>

            <div class="space-y-4 px-4">
              <div class="flex items-center gap-3">
                <span class="h-px w-8 bg-primary"></span>
                <span class="text-primary text-[10px] font-black uppercase tracking-widest">{{ item.category }}</span>
              </div>
              <h3 class="text-3xl font-black text-slate-900 group-hover:text-primary transition-colors">{{ item.title }}</h3>
              <p class="text-slate-500 font-medium leading-relaxed mb-6">{{ item.description }}</p>
              
              <div class="flex flex-wrap gap-2 pt-4">
                <span v-for="tag in item.tags" :key="tag" class="px-3 py-1 bg-slate-50 border border-slate-100 text-[9px] font-black text-slate-400 uppercase rounded-full">
                  {{ tag }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section class="bg-slate-50 py-32 border-y border-slate-100">
        <div class="max-w-5xl mx-auto px-6 text-center">
          <i class="fas fa-quote-left text-primary/20 text-6xl mb-8"></i>
          <h4 class="text-3xl md:text-4xl font-black text-slate-800 leading-tight mb-10 italic">
            "Switching to Alpha reduced our OTP latency by 45% in East Africa. For a bank, those milliseconds are the difference between a conversion and a bounce."
          </h4>
          <div class="flex flex-col items-center">
            <div class="h-16 w-16 bg-slate-900 rounded-full mb-4 overflow-hidden border-2 border-white shadow-lg">
              <div class="w-full h-full bg-primary flex items-center justify-center text-white font-black italic">B</div>
            </div>
            <span class="text-sm font-black text-slate-900 uppercase">Head of Digital Banking</span>
            <span class="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Enterprise FinTech</span>
          </div>
        </div>
      </section>

      <section class="py-32 bg-white text-center">
        <div class="max-w-4xl mx-auto px-6">
          <h2 class="text-5xl font-black text-slate-900 mb-8 tracking-tighter">Your project is next.</h2>
          <p class="text-slate-500 text-lg font-medium mb-12 leading-relaxed">
            Join 2,500+ developers building the future of African commerce on Alpha Message.
          </p>
          <div class="flex flex-col sm:flex-row items-center justify-center gap-4">
            <button class="w-full sm:w-auto px-10 py-4 bg-primary text-white font-black text-xs uppercase tracking-widest rounded-2xl shadow-xl hover:scale-105 transition-all">Start Integrating</button>
            <button class="w-full sm:w-auto px-10 py-4 border border-slate-200 text-slate-900 font-black text-xs uppercase tracking-widest rounded-2xl hover:bg-slate-50 transition-all">Request Demo</button>
          </div>
        </div>
      </section>
    </main>

    <Footer />
  </div>
</template>

<script>
import Header from './header.vue'
import Footer from './footer.vue'

export default {
  name: 'ShowcasePage',
  components: { Header, Footer },
  data() {
    return {
      activeCategory: 'All Solutions',
      categories: ['All Solutions', 'FinTech', 'E-Commerce', 'Logistics', 'GovTech'],
      showcaseItems: [
        {
          title: 'Bank-Wide 2FA Security',
          category: 'FinTech',
          description: 'Deploying secure OTP across 12M+ monthly logins with instant carrier fallback for 99.9% delivery.',
          metric: 'Avg 2.4s Delivery',
          icon: 'fas fa-shield-alt',
          gradient: 'from-blue-600 to-indigo-900',
          tags: ['OTP API', 'High Volume', 'Flash SMS']
        },
        {
          title: 'Hyper-Local Logistics',
          category: 'Logistics',
          description: 'Real-time driver coordination and customer arrival alerts for a fleet of 10,000+ vehicles.',
          metric: '100% Path Visibility',
          icon: 'fas fa-map-marker-check',
          gradient: 'from-emerald-500 to-teal-800',
          tags: ['Sender ID', 'DLT Mapping', 'Webhooks']
        },
        {
          title: 'National Census Verification',
          category: 'GovTech',
          description: 'Secure digital identity verification for over 500,000 field agents during a national data collection.',
          metric: '0% Fail Rate',
          icon: 'fas fa-id-card',
          gradient: 'from-amber-500 to-rose-700',
          tags: ['Verify API', 'White Label', 'SLA 99.9']
        },
        {
          title: 'Cross-Border Marketplace',
          category: 'E-Commerce',
          description: 'Dynamic order status updates and automated marketing campaigns across 5 regional countries.',
          metric: '30% ROI Increase',
          icon: 'fas fa-shopping-cart',
          gradient: 'from-purple-600 to-fuchsia-900',
          tags: ['Bulk SMS', 'Campaigner', 'Unicode']
        }
      ]
    }
  },
  computed: {
    filteredShowcase() {
      if (this.activeCategory === 'All Solutions') return this.showcaseItems;
      return this.showcaseItems.filter(item => item.category === this.activeCategory);
    }
  }
}
</script>

<style scoped>
.no-scrollbar::-webkit-scrollbar {
  display: none;
}
.no-scrollbar {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
</style>