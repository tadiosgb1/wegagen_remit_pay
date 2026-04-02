<template>
  <div class="min-h-screen bg-white font-sans selection:bg-secondary/20 selection:text-secondary overflow-x-hidden">
    <Header />

    <main>
      <section class="relative min-h-[90vh] flex items-center pt-20 bg-primary overflow-hidden">
        <div class="absolute inset-0 z-0">
          <div class="absolute inset-0 bg-[linear-gradient(to_right,#ffffff05_1px,transparent_1px),linear-gradient(to_bottom,#ffffff05_1px,transparent_1px)] bg-[size:40px_40px] [mask-image:radial-gradient(ellipse_60%_50%_at_50%_0%,#000_70%,transparent_100%)]"></div>
          <div class="absolute top-1/4 -left-20 w-96 h-96 bg-secondary/20 rounded-full blur-[120px] animate-pulse"></div>
          <div class="absolute bottom-1/4 -right-20 w-96 h-96 bg-blue-500/10 rounded-full blur-[120px]"></div>
        </div>

        <div class="max-w-7xl mx-auto px-6 relative z-10">
          <div class="max-w-4xl">
            <h2 class="text-secondary text-xs font-black uppercase tracking-[0.5em] mb-6 animate-fade-in">Established 2024</h2>
            <h1 class="text-6xl md:text-8xl lg:text-[120px] font-black text-white tracking-tighter leading-[0.85] mb-10">
              REDEFINING <br/>
              <span class="text-transparent bg-clip-text bg-gradient-to-r from-white via-white/80 to-white/40">CONNECTIVITY.</span>
            </h1>
            <p class="text-white/60 text-lg md:text-xl font-medium leading-relaxed max-w-2xl border-l-2 border-secondary pl-6">
              Alpha Message is more than an aggregator. We are the programmable bridge between complex telecommunication protocols and the modern developer's vision.
            </p>
          </div>
        </div>
      </section>

      <section class="py-32 relative bg-white">
        <div class="max-w-7xl mx-auto px-6">
          <div class="grid lg:grid-cols-2 gap-20 items-center">
            <div class="relative">
              <div class="absolute -top-10 -left-10 text-[200px] font-black text-slate-50 select-none z-0">DNA</div>
              <div class="relative z-10 space-y-12">
                <div class="group">
                  <span class="text-secondary font-black text-xs uppercase tracking-widest block mb-4">01. Our Mission</span>
                  <h3 class="text-4xl font-black text-slate-900 mb-4 leading-tight">Eliminating the "Carrier Gap" globally.</h3>
                  <p class="text-slate-500 text-lg font-medium leading-relaxed">
                    We mission to empower businesses with instant, secure, and reliable communication tools, abstracting the complexity of local network regulations into a single, elegant API.
                  </p>
                </div>
                <div class="group">
                  <span class="text-secondary font-black text-xs uppercase tracking-widest block mb-4">02. Our Vision</span>
                  <h3 class="text-4xl font-black text-slate-900 mb-4 leading-tight">The API that powers African digital trade.</h3>
                  <p class="text-slate-500 text-lg font-medium leading-relaxed">
                    To become the foundational layer for all transactional data in emerging markets, ensuring no message is left undelivered and no user is left unverified.
                  </p>
                </div>
              </div>
            </div>
            <div class="lg:pl-20">
              <div class="aspect-square bg-slate-900 rounded-[3rem] p-1 shadow-2xl overflow-hidden group">
                <div class="w-full h-full rounded-[2.8rem] bg-primary relative overflow-hidden flex items-center justify-center">
                  <div class="w-64 h-64 border border-white/10 rounded-full animate-ping absolute"></div>
                  <div class="w-48 h-48 border border-white/20 rounded-full animate-pulse absolute"></div>
                  <i class="fas fa-microchip text-7xl text-white"></i>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section class="bg-slate-900 py-24 overflow-hidden">
        <div class="max-w-7xl mx-auto px-6">
          <div class="grid grid-cols-2 md:grid-cols-4 gap-12 text-center">
            <div v-for="stat in stats" :key="stat.label">
              <div class="text-5xl font-black text-white mb-2">{{ stat.value }}</div>
              <div class="text-secondary text-[10px] font-black uppercase tracking-widest">{{ stat.label }}</div>
            </div>
          </div>
        </div>
      </section>

      <section class="py-32 bg-white">
        <div class="max-w-7xl mx-auto px-6 text-center mb-20">
          <h2 class="text-xs font-black text-primary uppercase tracking-[0.5em] mb-4">Engineering Principles</h2>
          <h3 class="text-5xl font-black text-slate-900 tracking-tight">How we build at Alpha.</h3>
        </div>
        
        <div class="max-w-7xl mx-auto px-6 grid md:grid-cols-3 gap-1px bg-slate-100 border border-slate-100">
          <div v-for="value in coreValues" :key="value.title" class="bg-white p-12 group hover:bg-primary transition-all duration-500">
            <div class="h-12 w-12 bg-slate-100 rounded-xl flex items-center justify-center text-primary mb-8 group-hover:bg-white/10 group-hover:text-white transition-all">
              <i :class="value.icon" class="text-xl"></i>
            </div>
            <h4 class="text-xl font-black text-slate-900 mb-4 group-hover:text-white transition-colors">{{ value.title }}</h4>
            <p class="text-slate-500 text-sm font-medium leading-relaxed group-hover:text-white/70 transition-colors">
              {{ value.desc }}
            </p>
          </div>
        </div>
      </section>

      <section class="max-w-7xl mx-auto px-6 mb-32">
        <div class="bg-secondary rounded-[3rem] p-12 md:p-20 text-white relative overflow-hidden">
          <div class="absolute -right-20 -bottom-20 opacity-10">
            <i class="fas fa-shield-alt text-[300px]"></i>
          </div>
          <div class="max-w-2xl relative z-10">
            <h3 class="text-4xl font-black mb-6 italic tracking-tight">Bank-Grade Compliance by Design.</h3>
            <p class="text-white/80 text-lg font-medium leading-relaxed mb-8">
              We process millions of sensitive authentication codes daily. Our infrastructure is built with AES-256 encryption at rest, end-to-end TLS 1.3, and is strictly ISO 27001 compliant.
            </p>
            <button class="px-8 py-4 bg-white text-secondary font-black text-xs uppercase tracking-widest rounded-xl hover:shadow-2xl transition-all">
              Read Security Whitepaper
            </button>
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
  name: 'AboutPage',
  components: {
    Header,
    Footer
  },
  data() {
    return {
      stats: [
        { value: '150M+', label: 'Messages Sent' },
        { value: '99.98%', label: 'Uptime SLA' },
        { value: '45+', label: 'Carrier Routes' },
        { value: '2.5k+', label: 'Global Developers' }
      ],
      coreValues: [
        { 
          title: 'Radical Reliability', 
          desc: 'Our queuing system is built to survive massive traffic spikes without dropping a single packet.', 
          icon: 'fas fa-bolt' 
        },
        { 
          title: 'Developer Empathy', 
          desc: 'We build the tools we would want to use. Documentation is never an afterthought.', 
          icon: 'fas fa-code' 
        },
        { 
          title: 'Zero-Trust Security', 
          desc: 'We assume every endpoint is hostile and verify every request with rigorous cryptographic standards.', 
          icon: 'fas fa-lock' 
        },
        { 
          title: 'Absolute Transparency', 
          desc: 'Real-time monitoring and public status pages. We own our mistakes and celebrate our stability.', 
          icon: 'fas fa-eye' 
        },
        { 
          title: 'Localized Precision', 
          desc: 'Support for Unicode, local Amharic characters, and regional carrier idiosyncrasies.', 
          icon: 'fas fa-language' 
        },
        { 
          title: 'Scale Velocity', 
          desc: 'Our platform scales horizontally, ensuring your growth is never capped by our hardware.', 
          icon: 'fas fa-chart-line' 
        }
      ]
    }
  }
}
</script>

<style scoped>
.animate-fade-in {
  animation: fadeIn 1s ease-out forwards;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Custom grid spacing for core values */
.gap-1px {
  gap: 1px;
}
</style>