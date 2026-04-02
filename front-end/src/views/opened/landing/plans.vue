<template>
  <div class="min-h-screen bg-white font-sans selection:bg-primary/10">
    <Header />

    <main class="pt-20">
      <div v-if="loading" class="py-40 text-center">
        <div class="inline-block animate-spin w-12 h-12 border-4 border-primary border-t-transparent rounded-full"></div>
        <p class="mt-4 font-black uppercase tracking-widest text-slate-400 text-[10px]">Syncing Plans...</p>
      </div>

      <section v-else id="plans" class="py-24 bg-slate-50 relative overflow-hidden">
        <div class="absolute top-0 left-1/2 -translate-x-1/2 w-full h-full bg-[radial-gradient(circle_at_center,_var(--tw-gradient-stops))] from-primary/5 via-transparent to-transparent opacity-50"></div>

        <div class="max-w-7xl mx-auto px-6 relative z-10">
          <div class="max-w-3xl mx-auto text-center mb-20">
            <span class="inline-block px-4 py-1.5 mb-4 text-[10px] font-black tracking-[0.3em] text-primary bg-primary/10 rounded-full uppercase">
              Subscription Tiers
            </span>
            <h2 class="text-4xl md:text-5xl font-black text-slate-900 mb-6 tracking-tight">
              Scale Your <span class="text-primary italic">Messaging.</span>
            </h2>
            <p class="text-slate-500 font-medium tracking-tight">Select a plan that fits your business volume and technical requirements.</p>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 items-start mb-24">
            <div v-for="(plan, index) in items" :key="plan.id"
              class="group relative bg-white border border-slate-200 rounded-[2.5rem] p-10 transition-all duration-500 hover:shadow-2xl hover:border-primary/20 hover:-translate-y-2"
            >
              <div v-if="index === 0" class="absolute -top-5 left-1/2 -translate-x-1/2 bg-slate-900 text-primary px-6 py-2 rounded-full text-[10px] font-black uppercase tracking-widest shadow-lg">
                Active Tier
              </div>

              <div class="mb-8">
                <div class="flex justify-between items-start">
                  <h3 class="text-xl font-black text-slate-900 mb-2 uppercase tracking-tighter">{{ plan.plan_name }}</h3>
                  <i class="fas fa-layer-group text-slate-200 text-2xl"></i>
                </div>
                <p class="text-slate-400 text-[10px] font-black uppercase tracking-widest">Daily Limit: {{ plan.max_daily_sends }} SMS</p>
              </div>

              <div class="mb-10 flex items-baseline gap-1">
                <span class="text-sm font-black text-slate-400 uppercase">ETB</span>
                <span class="text-5xl font-black text-slate-900 tracking-tighter">
                  {{ getPrice(index) }}
                </span>
                <span class="text-[10px] font-bold text-slate-400 uppercase">/msg</span>
              </div>

              <div class="h-px w-full bg-slate-100 mb-8"></div>

              <ul class="space-y-4 mb-10">
                <li class="flex items-center gap-3 text-xs font-bold text-slate-600">
                  <i class="fas fa-check-circle text-primary text-sm"></i>
                  {{ plan.sender_names }} Sender Names
                </li>
                <li class="flex items-center gap-3 text-xs font-bold text-slate-600">
                  <i class="fas fa-check-circle text-primary text-sm"></i>
                  {{ plan.import_limit }} Contact Imports
                </li>
                <li class="flex items-center gap-3 text-xs font-bold text-slate-600">
                  <i class="fas fa-check-circle text-primary text-sm"></i>
                  {{ plan.keywords }} Automated Keywords
                </li>
                <li class="flex items-center gap-3 text-xs font-bold text-slate-600">
                  <i class="fas fa-check-circle text-primary text-sm"></i>
                  OTP: {{ plan.max_otp }}
                </li>
                <li v-if="plan.import_throttled" class="flex items-center gap-3 text-[10px] font-black uppercase text-amber-600 bg-amber-50 p-2 rounded-lg">
                  <i class="fas fa-bolt"></i>
                  Throttled Processing Enabled
                </li>
              </ul>

              <button 
                class="w-full py-5 rounded-2xl font-black text-xs uppercase tracking-[0.2em] transition-all hover:scale-105 active:scale-95 shadow-lg bg-slate-900 text-white hover:bg-primary"
              >
                Select Plan
              </button>
            </div>
          </div>
        </div>
      </section>

      <section class="py-32 bg-white">
        <div class="max-w-4xl mx-auto px-6">
          <div class="bg-slate-900 rounded-[3.5rem] p-8 md:p-16 text-white shadow-2xl relative overflow-hidden border border-white/5">
            <div class="relative z-10">
              <div class="mb-16">
                <div class="flex justify-between items-end mb-6">
                  <span class="text-[10px] font-black uppercase tracking-widest text-slate-500">Estimated Monthly Usage</span>
                  <span class="text-3xl font-black text-white italic">{{ estimatedVolume.toLocaleString() }} <span class="text-xs not-italic text-slate-500 uppercase">SMS</span></span>
                </div>
                <input 
                  type="range" 
                  v-model.number="estimatedVolume" 
                  min="1000" 
                  max="500000" 
                  step="1000" 
                  class="w-full h-1.5 bg-slate-800 rounded-lg appearance-none cursor-pointer accent-primary"
                >
              </div>
              
              <div class="grid md:grid-cols-2 gap-12 border-t border-white/5 pt-12">
                <div>
                  <span class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Estimated Monthly Cost</span>
                  <div class="text-4xl font-black text-white">
                    <span class="text-lg text-primary mr-1">ETB</span>{{ calculateTotal }}
                  </div>
                </div>
                <div class="md:text-right">
                  <span class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Current Rate</span>
                  <div class="text-4xl font-black text-primary">
                    0.35<span class="text-xs text-slate-500 uppercase ml-2">/sms</span>
                  </div>
                </div>
              </div>
            </div>
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
  name: 'PricingPage',
  components: { Header, Footer },
  data() {
    return {
      items: [],
      loading: false,
      estimatedVolume: 10000,
      baseRate: 0.35
    }
  },
  computed: {
    calculateTotal() {
      const total = this.estimatedVolume * this.baseRate;
      return total.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }
  },
  methods: {
    async fetchPlans() {
      this.loading = true;
      try {
        // Adjust the endpoint to your specific API structure
        const response = await this.$apiGet('/plans');
        // Based on the provided server response: response.data.data.data
        this.items = response.data.data || [];
      } catch (error) {
        console.error("Error fetching plans:", error);
      } finally {
        this.loading = false;
      }
    },
    getPrice(index) {
      // Logic for price display if not in API response
      const prices = ["0.35", "0.28", "0.22"];
      return prices[index] || "0.30";
    }
  },
  mounted() {
    this.fetchPlans();
  }
}
</script>

<style scoped>
input[type=range]::-webkit-slider-thumb {
  -webkit-appearance: none;
  height: 24px;
  width: 24px;
  border-radius: 50%;
  background: #facc15; /* Primary color */
  box-shadow: 0 0 15px rgba(0,0,0,0.4);
  cursor: pointer;
  margin-top: -10px;
}
</style>