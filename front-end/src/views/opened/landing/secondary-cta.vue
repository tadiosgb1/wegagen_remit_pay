<template>
  <section class="py-20 bg-white">
    <div class="max-w-7xl mx-auto px-6">
      <div class="relative bg-slate-900 rounded-[4rem] p-12 md:p-24 overflow-hidden group shadow-2xl">
        
        <div class="absolute top-0 right-0 w-1/2 h-full bg-gradient-to-l from-primary/20 to-transparent opacity-50 group-hover:opacity-100 transition-opacity duration-1000"></div>
        <div class="absolute -bottom-24 -right-24 w-96 h-96 bg-secondary/10 rounded-full blur-[100px] group-hover:bg-secondary/20 transition-all duration-700"></div>
        
        <div class="absolute inset-0 opacity-10">
          <div class="absolute top-10 left-0 w-full h-[1px] bg-gradient-to-r from-transparent via-white to-transparent animate-pulse"></div>
          <div class="absolute top-40 left-0 w-full h-[1px] bg-gradient-to-r from-transparent via-white to-transparent animate-pulse delay-700"></div>
        </div>

        <div class="relative z-10 grid lg:grid-cols-2 gap-16 items-center">
          
          <div>
            <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-white/5 border border-white/10 text-secondary text-[10px] font-black uppercase tracking-[0.3em] mb-8">
              <span class="relative flex h-2 w-2">
                <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-secondary opacity-75"></span>
                <span class="relative inline-flex rounded-full h-2 w-2 bg-secondary"></span>
              </span>
              Developer Sandbox
            </div>
            
            <h2 class="text-4xl md:text-6xl font-black text-white mb-8 tracking-tighter leading-none">
              Stop Losing Users to <br/> 
              <span class="text-transparent bg-clip-text bg-gradient-to-r from-white via-white/80 to-white/40 italic">Slow OTPs.</span>
            </h2>
            
            <p class="text-slate-400 text-lg font-medium leading-relaxed max-w-lg mb-12">
              Join 2,500+ developers building the future of Ethiopian commerce. 
              Get <span class="text-white font-bold">50 free credits</span> to test our high-priority routes immediately.
            </p>

            <div class="flex flex-col sm:flex-row gap-4">
              <button class="px-10 py-5 bg-primary text-white rounded-2xl font-black uppercase tracking-widest text-xs shadow-xl shadow-primary/20 hover:scale-105 active:scale-95 transition-all">
                Claim Free Credits
              </button>
              <button class="px-10 py-5 bg-white/5 border border-white/10 text-white rounded-2xl font-black uppercase tracking-widest text-xs hover:bg-white/10 transition-all backdrop-blur-md">
                Talk to an Expert
              </button>
            </div>
          </div>

          <div class="relative hidden lg:block">
            <div class="absolute inset-0 bg-primary/20 rounded-full blur-[120px] animate-pulse"></div>
            
            <div class="relative bg-[#1a1a1a] border border-white/10 p-6 rounded-[2.5rem] shadow-2xl transform rotate-3 hover:rotate-0 transition-transform duration-700 group-hover:scale-105">
              <div class="flex items-center justify-between mb-8">
                <div class="flex gap-1.5">
                  <div class="w-2.5 h-2.5 rounded-full bg-white/10"></div>
                  <div class="w-2.5 h-2.5 rounded-full bg-white/10"></div>
                </div>
                <div class="text-[10px] font-black text-white/20 uppercase tracking-widest font-mono">Alpha-Secure-v3</div>
              </div>

              <div class="space-y-4">
                <div class="p-4 bg-white/5 rounded-2xl rounded-tl-none border border-white/5 animate-fade-in">
                  <div class="text-[10px] font-black text-primary uppercase mb-2">Alpha Message</div>
                  <div class="text-sm text-slate-300 font-medium">Your verification code is: <span class="text-white font-mono font-bold tracking-widest">882-194</span>. Valid for 5 mins.</div>
                </div>
                <div class="text-[9px] text-slate-600 font-bold uppercase tracking-widest text-center italic pt-4">
                  Delivered in 1.8 seconds via Ethio Telecom
                </div>
              </div>
            </div>

            <div class="absolute -top-6 -left-6 bg-secondary text-slate-900 px-4 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest shadow-2xl transform -rotate-12 animate-bounce-slow">
              99.9% Delivery
            </div>
          </div>

        </div>
      </div>
    </div>
  </section>
</template>

<script>
export default {
  name: 'SecondaryCTA'
}
</script>

<style scoped>
.animate-bounce-slow {
  animation: bounceSlow 4s infinite ease-in-out;
}

@keyframes bounceSlow {
  0%, 100% { transform: translateY(0) rotate(-12deg); }
  50% { transform: translateY(-15px) rotate(-12deg); }
}

@keyframes fadeIn {
  from { opacity: 0; transform: scale(0.95); }
  to { opacity: 1; transform: scale(1); }
}

.animate-fade-in {
  animation: fadeIn 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}
</style>