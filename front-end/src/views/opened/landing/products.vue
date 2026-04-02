<template>
  <div class="min-h-screen bg-white font-sans selection:bg-primary/10">
    <Header />

    <main class="pt-20">
      <section class="py-24 bg-slate-50 border-b border-slate-100">
        <div class="max-w-7xl mx-auto px-6">
          <div class="flex flex-col md:flex-row md:items-end justify-between gap-8">
            <div class="max-w-2xl">
              <h2 class="text-primary text-xs font-black uppercase tracking-[0.5em] mb-4">The Infrastructure</h2>
              <h1 class="text-5xl md:text-7xl font-black text-slate-900 tracking-tighter leading-none">
                BUILD WITHOUT <br/> <span class="text-slate-400">LIMITS.</span>
              </h1>
            </div>
            <p class="max-w-xs text-slate-500 font-medium text-sm leading-relaxed border-l-2 border-slate-200 pl-6">
              Our suite of messaging APIs is engineered for 99.99% deliverability across all Ethiopian and global carriers.
            </p>
          </div>
        </div>
      </section>

      <section class="py-24 border-b border-slate-50">
        <div class="max-w-7xl mx-auto px-6 grid lg:grid-cols-12 gap-16 items-center">
          <div class="lg:col-span-7">
            <div class="inline-flex items-center gap-2 px-3 py-1 bg-blue-50 text-blue-600 rounded-full mb-6">
              <span class="w-2 h-2 bg-blue-600 rounded-full animate-pulse"></span>
              <span class="text-[10px] font-black uppercase tracking-widest">High Throughput</span>
            </div>
            <h2 class="text-4xl font-black text-slate-900 mb-6">Programmable Messaging</h2>
            <p class="text-slate-500 text-lg font-medium leading-relaxed mb-10">
              Send and receive SMS globally with a single API. Our intelligent routing engine automatically selects the highest-quality path for your traffic, ensuring sub-5-second delivery.
            </p>
            
            <div class="grid md:grid-cols-2 gap-8">
              <div v-for="feat in smsFeatures" :key="feat.title" class="space-y-2">
                <h4 class="text-sm font-black text-slate-900 uppercase tracking-wide">{{ feat.title }}</h4>
                <p class="text-xs text-slate-400 leading-relaxed">{{ feat.desc }}</p>
              </div>
            </div>
          </div>
          <div class="lg:col-span-5">
            <div class="bg-slate-900 rounded-[2rem] p-8 shadow-2xl transform lg:rotate-2 hover:rotate-0 transition-transform duration-500">
              <div class="flex items-center gap-2 mb-6">
                <div class="w-3 h-3 rounded-full bg-rose-500"></div>
                <div class="w-3 h-3 rounded-full bg-amber-500"></div>
                <div class="w-3 h-3 rounded-full bg-emerald-500"></div>
              </div>
              <pre class="text-blue-400 text-xs font-mono leading-relaxed">
<span class="text-slate-500">// Send Alpha SMS</span>
POST /api/v1/send {
  "to": "+251911001122",
  "from": "AlphaAlert",
  "body": "Your order #102 is out!",
  "callback": "https://yoursite.com"
}</pre>
            </div>
          </div>
        </div>
      </section>

      <section class="py-24 bg-slate-900 text-white overflow-hidden">
        <div class="max-w-7xl mx-auto px-6">
          <div class="grid lg:grid-cols-2 gap-20 items-center">
            <div class="relative">
              <div class="absolute -top-20 -left-20 w-64 h-64 bg-primary/20 rounded-full blur-[100px]"></div>
              <h2 class="text-4xl font-black mb-8">Alpha Verify™</h2>
              <p class="text-slate-400 text-lg font-medium leading-relaxed mb-12">
                Don't just send codes; manage identities. Our Verify API handles code generation, hashing, and expiration logic so you don't have to build a security backend.
              </p>
              <ul class="space-y-6">
                <li v-for="item in verifyPoints" :key="item" class="flex items-start gap-4">
                  <div class="mt-1 h-5 w-5 rounded-full bg-primary/20 flex items-center justify-center flex-shrink-0">
                    <i class="fas fa-check text-primary text-[10px]"></i>
                  </div>
                  <span class="text-slate-200 font-bold">{{ item }}</span>
                </li>
              </ul>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-4 pt-12">
                <div class="bg-white/5 border border-white/10 p-6 rounded-3xl backdrop-blur-md">
                  <i class="fas fa-shield-check text-secondary text-2xl mb-4"></i>
                  <div class="text-xs font-black uppercase tracking-widest mb-1">Secure</div>
                  <div class="text-[10px] text-slate-500">AES-256 Hashing</div>
                </div>
                <div class="bg-white/5 border border-white/10 p-6 rounded-3xl backdrop-blur-md">
                  <i class="fas fa-hourglass-end text-primary text-2xl mb-4"></i>
                  <div class="text-xs font-black uppercase tracking-widest mb-1">TTL</div>
                  <div class="text-[10px] text-slate-500">Auto-expiry logic</div>
                </div>
              </div>
              <div class="space-y-4">
                <div class="bg-white/5 border border-white/10 p-6 rounded-3xl backdrop-blur-md">
                  <i class="fas fa-redo text-blue-400 text-2xl mb-4"></i>
                  <div class="text-xs font-black uppercase tracking-widest mb-1">Retry</div>
                  <div class="text-[10px] text-slate-500">Smart resend limits</div>
                </div>
                <div class="bg-white/5 border border-white/10 p-6 rounded-3xl backdrop-blur-md">
                  <i class="fas fa-analytics text-emerald-400 text-2xl mb-4"></i>
                  <div class="text-xs font-black uppercase tracking-widest mb-1">Insights</div>
                  <div class="text-[10px] text-slate-500">Conversion tracking</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section class="py-32 bg-white">
        <div class="max-w-7xl mx-auto px-6">
          <div class="text-center mb-20">
            <h3 class="text-xs font-black text-slate-400 uppercase tracking-[0.4em] mb-4">The Comparison</h3>
            <h2 class="text-4xl font-black text-slate-900">Technical Capability Matrix</h2>
          </div>
          
          <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
              <thead>
                <tr class="border-b-2 border-slate-900">
                  <th class="py-6 text-xs font-black uppercase tracking-widest text-slate-400">Feature</th>
                  <th class="py-6 text-xs font-black uppercase tracking-widest text-slate-900 text-center">Standard SMS</th>
                  <th class="py-6 text-xs font-black uppercase tracking-widest text-primary text-center">Alpha Premium</th>
                </tr>
              </thead>
              <tbody class="text-sm font-bold">
                <tr v-for="row in tableData" :key="row.feature" class="border-b border-slate-100 hover:bg-slate-50 transition-colors">
                  <td class="py-6 text-slate-600">{{ row.feature }}</td>
                  <td class="py-6 text-slate-400 text-center">{{ row.standard }}</td>
                  <td class="py-6 text-slate-900 text-center">{{ row.premium }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </section>

      <section class="max-w-7xl mx-auto px-6 pb-32">
        <div class="bg-primary rounded-[3rem] p-12 text-center text-white relative overflow-hidden">
          <div class="relative z-10">
            <h3 class="text-4xl font-black mb-6">Ready to start building?</h3>
            <p class="text-white/60 mb-10 max-w-xl mx-auto">Get 50 free credits to test our API. No credit card required.</p>
            <button class="px-10 py-4 bg-white text-primary font-black text-xs uppercase tracking-[0.2em] rounded-2xl hover:bg-secondary hover:text-white transition-all">Create Free Account</button>
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
  name: 'ProductsPage',
  components: { Header, Footer },
  data() {
    return {
      smsFeatures: [
        { title: 'Unicode Support', desc: 'Full support for Amharic and 100+ other languages without character breakage.' },
        { title: 'Dynamic Sender ID', desc: 'Customizable Alpha-numeric sender names for brand recognition.' },
        { title: 'DLR Callbacks', desc: 'Instant webhooks to notify your server the moment a handset receives the message.' },
        { title: 'Smart Concatenation', desc: 'Automatically splits and rejoins long messages into a single seamless text.' }
      ],
      verifyPoints: [
        'Built-in 4 to 10 digit code generation',
        'Customizable message templates (Prefix/Suffix)',
        'Automatic expiration (TTL) from 30s to 1 hour',
        'Channel-agnostic (SMS, WhatsApp, or Voice)'
      ],
      tableData: [
        { feature: 'Latency (Ethiopia)', standard: '8 - 15 Seconds', premium: '2 - 4 Seconds' },
        { feature: 'Uptime Guarantee', standard: '95.0%', premium: '99.99%' },
        { feature: 'Delivery Reports', status: 'Partial', premium: 'Real-time Full DLR' },
        { feature: 'API Rate Limits', standard: '10 req/sec', premium: 'Unlimited (Elastic)' },
        { feature: '24/7 Support', standard: 'Email Only', premium: 'Dedicated Account Manager' }
      ]
    }
  }
}
</script>