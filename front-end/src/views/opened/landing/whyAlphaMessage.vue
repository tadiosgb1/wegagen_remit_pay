<template>
  <section class="py-32 bg-white overflow-hidden">
    <div class="max-w-7xl mx-auto px-6">
      
      <div class="flex flex-col md:flex-row md:items-end justify-between gap-8 mb-20">
        <div class="max-w-2xl">
          <h2 class="text-primary text-xs font-black uppercase tracking-[0.5em] mb-4">The Alpha Advantage</h2>
          <h3 class="text-5xl md:text-7xl font-black text-slate-900 tracking-tighter leading-[0.9]">
            Built for the <br/>
            <span class="text-secondary italic">Next Billion</span> Transactions.
          </h3>
        </div>
        <p class="max-w-xs text-slate-500 font-medium text-sm leading-relaxed border-l-2 border-slate-100 pl-6">
          Generic gateways fail in complex markets. Alpha is engineered specifically for the unique architectural demands of Ethiopia's digital infrastructure.
        </p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-12 gap-6 auto-rows-[240px]">
        
        <div class="md:col-span-8 md:row-span-2 group relative bg-slate-900 rounded-[3rem] p-12 overflow-hidden border border-slate-800 transition-all duration-700 hover:shadow-[0_0_50px_rgba(61,90,254,0.2)]">
          <div class="absolute top-0 right-0 w-full h-full opacity-20 group-hover:opacity-40 transition-opacity duration-700">
            <div class="absolute inset-0 bg-[radial-gradient(circle_at_70%_30%,#3d5afe_0%,transparent_70%)]"></div>
          </div>
          
          <div class="relative z-10 h-full flex flex-col justify-between">
            <div>
              <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary/20 border border-primary/30 text-primary text-[10px] font-black uppercase tracking-widest mb-8">
                <i class="fas fa-bolt"></i> Localized Edge
              </div>
              <h4 class="text-4xl font-black text-white mb-6 leading-tight">
                Direct SMPP Binds <br/> to <span class="text-secondary">Ethio Telecom.</span>
              </h4>
              <p class="text-slate-400 max-w-md font-medium leading-relaxed">
                By bypassing third-party global aggregators, we reduce hop-count and eliminate "carrier-side" grey routing, ensuring your OTPs arrive in < 3 seconds.
              </p>
            </div>
            
            <div class="flex items-center gap-12 mt-8">
              <div v-for="stat in mainStats" :key="stat.label">
                <div class="text-2xl font-black text-white italic">{{ stat.value }}</div>
                <div class="text-[9px] font-black text-slate-500 uppercase tracking-widest">{{ stat.label }}</div>
              </div>
            </div>
          </div>
        </div>

        <div class="md:col-span-4 md:row-span-2 group relative bg-slate-50 rounded-[3rem] p-10 overflow-hidden border border-slate-100 transition-all duration-500 hover:bg-white hover:shadow-2xl">
          <div class="h-16 w-16 bg-white rounded-2xl shadow-xl flex items-center justify-center text-primary text-2xl mb-8 group-hover:scale-110 transition-transform">
            <i class="fas fa-shield-check"></i>
          </div>
          <h4 class="text-2xl font-black text-slate-900 mb-4">Bank-Grade Compliance</h4>
          <p class="text-slate-500 text-sm font-medium leading-relaxed mb-8 italic">
            "Security isn't a feature; it's our foundation."
          </p>
          <ul class="space-y-4">
            <li v-for="item in securityItems" :key="item" class="flex items-center gap-3 text-[10px] font-black text-slate-400 uppercase tracking-widest">
              <i class="fas fa-circle text-[4px] text-primary"></i> {{ item }}
            </li>
          </ul>
        </div>

        <div class="md:col-span-6 md:row-span-1 group relative bg-secondary/5 rounded-[3rem] p-10 border border-secondary/10 hover:bg-white hover:shadow-2xl transition-all duration-500 flex items-center gap-8">
          <div class="text-5xl font-black text-secondary/30 group-hover:text-secondary/80 transition-colors italic">ሀለ</div>
          <div>
            <h4 class="text-xl font-black text-slate-900 mb-2">Native Ethiopic Script</h4>
            <p class="text-slate-500 text-xs font-medium">Automatic UCS-2 encoding for Amharic, Oromiffa, and Tigrinya with zero character corruption.</p>
          </div>
        </div>

        <div class="md:col-span-6 md:row-span-1 group relative bg-primary/5 rounded-[3rem] p-10 border border-primary/10 hover:bg-white hover:shadow-2xl transition-all duration-500 flex items-center gap-8">
          <div class="w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center text-primary text-xl group-hover:rotate-12 transition-transform">
            <i class="fas fa-terminal"></i>
          </div>
          <div>
            <h4 class="text-xl font-black text-slate-900 mb-2">Idempotent APIs</h4>
            <p class="text-slate-500 text-xs font-medium">Built for developers. Prevent duplicate messages even during network retries with unique request IDs.</p>
          </div>
        </div>

      </div>
    </div>
  </section>
</template>

<script>
export default {
  name: 'WhyAlpha',
  data() {
    return {
      mainStats: [
        { label: 'Avg Latency', value: '42ms' },
        { label: 'Carrier Fallback', value: 'Instant' },
        { label: 'Deliverability', value: '99.98%' }
      ],
      securityItems: [
        'AES-256 Encryption',
        'TLS 1.3 Endpoints',
        'ISO 27001 Ready',
        '2FA Dashboard Access'
      ]
    }
  }
}
</script>

<style scoped>
/* Tabular numbers for clean stat display */
.tabular-nums {
  font-variant-numeric: tabular-nums;
}

/* Custom shadow for secondary color */
.hover\:shadow-\[0_0_50px_rgba\(61\,90\,254\,0\.2\)\]:hover {
  box-shadow: 0 0 50px rgba(61, 90, 254, 0.2);
}
</style>