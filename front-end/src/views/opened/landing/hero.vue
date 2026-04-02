<template>
  <section class="relative min-h-screen flex items-center justify-center bg-[#050505] overflow-hidden pt-20">
    
    <div class="absolute inset-0 z-0">
      <div class="absolute top-[-10%] left-[-10%] w-[50%] h-[50%] bg-primary rounded-full blur-[120px] animate-pulse"></div>
      <div class="absolute bottom-[-10%] right-[-10%] w-[50%] h-[50%] bg-secondary/20 rounded-full blur-[120px] animate-bounce-slow"></div>
      
      <div class="absolute inset-0 bg-[linear-gradient(to_right,#ffffff05_1px,transparent_1px),linear-gradient(to_bottom,#ffffff05_1px,transparent_1px)] bg-[size:40px_40px] [mask-image:radial-gradient(ellipse_60%_50%_at_50%_50%,#000_70%,transparent_100%)]"></div>
      
      <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full h-full opacity-30">
        <div class="absolute top-1/4 left-1/3 w-2 h-2 bg-secondary rounded-full shadow-[0_0_20px_#ffde59]"></div>
        <div class="absolute bottom-1/3 right-1/4 w-1.5 h-1.5 bg-primary rounded-full shadow-[0_0_15px_#3d5afe]"></div>
      </div>
    </div>

    <div class="max-w-7xl mx-auto px-6 relative z-10 text-center">
      
      <div class="inline-flex items-center gap-3 px-5 py-2 mb-10 rounded-full bg-white/5 border border-white/10 backdrop-blur-xl shadow-2xl animate-fade-in-up">
        <span class="relative flex h-2 w-2">
          <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
          <span class="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
        </span>
        <span class="text-[10px] font-black text-white/90 uppercase tracking-[0.4em]">Advanced Behavioral Analytics Platform</span>
      </div>

      <h1 class="text-primary text-6xl md:text-9xl font-[1000] mb-8 tracking-tighter leading-[0.85] animate-hero-reveal uppercase">
        Unlock Your <br/>
        <span class="relative inline-block text-transparent bg-clip-text bg-gradient-to-br from-secondary via-white to-primary bg-[size:200%_auto] animate-text-shine italic">
          Cognitive 
        </span>
        <br/> Edge
      </h1>

      <p class="text-lg md:text-xl text-white/50 mb-14 max-w-2xl mx-auto font-medium leading-relaxed tracking-wide animate-fade-in-up-delay">
        The complete psychometric suite for modern talent. Engineered for 
        <span class="text-white">deep personality mapping</span>, student aptitude, and 
        <span class="text-white">organizational performance analysis</span>.
      </p>

      <div class="flex flex-col sm:flex-row justify-center gap-6 animate-fade-in-up-deep">
        <button 
          @click="scrollTo('onboard')" 
          class="group relative px-12 py-5 bg-secondary rounded-2xl font-black uppercase tracking-[0.2em] text-slate-900 transition-all duration-500 hover:shadow-[0_0_40px_rgba(255,222,89,0.4)] hover:-translate-y-1 overflow-hidden"
        >
          <span class="relative z-10 italic">Start Assessment</span>
          <div class="absolute inset-0 bg-white translate-y-full group-hover:translate-y-0 transition-transform duration-500 opacity-20"></div>
        </button>

        <button 
          @click="scrollTo('features')"
          class="px-12 py-5 bg-white/5 border border-white/10 rounded-2xl text-white font-black uppercase tracking-[0.2em] backdrop-blur-xl hover:bg-white/10 transition-all duration-300 border-b-4 border-b-white/5 active:border-b-0"
        >
          For Organizations
        </button>
      </div>

      <div class="mt-24 animate-bounce opacity-30">
        <i class="fas fa-chevron-down text-white text-xl"></i>
      </div>
    </div>
  </section>
</template>

<script>
export default {
  name: 'HeroSection',
  methods: {
    scrollTo(id) {
      const el = document.getElementById(id);
      if (el) el.scrollIntoView({ behavior: 'smooth' });
    }
  }
}
</script>

<style scoped>
/* All Original Animations Preserved Exactly */
.animate-text-shine {
  animation: textShine 4s linear infinite;
}

@keyframes textShine {
  to { background-position: 200% center; }
}

.animate-hero-reveal {
  animation: heroReveal 1.2s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}

@keyframes heroReveal {
  from { opacity: 0; transform: translateY(40px) scale(0.95); letter-spacing: -0.05em; }
  to { opacity: 1; transform: translateY(0) scale(1); letter-spacing: -0.05em; }
}

.animate-fade-in-up {
  animation: fadeInUp 0.8s ease-out forwards;
}
.animate-fade-in-up-delay {
  animation: fadeInUp 0.8s ease-out 0.3s forwards;
  opacity: 0;
}
.animate-fade-in-up-deep {
  animation: fadeInUp 0.8s ease-out 0.6s forwards;
  opacity: 0;
}

@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-bounce-slow {
  animation: bounceSlow 6s infinite ease-in-out;
}

@keyframes bounceSlow {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-30px); }
}

.font-\[1000\] {
  font-weight: 950;
}
</style>