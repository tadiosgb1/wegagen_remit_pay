<template>
  <footer class="relative bg-primary text-white pt-20 pb-10 px-6 overflow-hidden">
    
    <div class="absolute top-0 left-0 w-full h-1 bg-white/10"></div>
    <div class="absolute -bottom-24 -right-24 w-96 h-96 bg-secondary/10 rounded-full blur-3xl"></div>

    <div class="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-5 gap-12 relative z-10">
      
      <div class="md:col-span-2 space-y-6">
        <div class="flex items-center space-x-3">
           <div class="h-10 w-10 bg-white rounded-xl flex items-center justify-center shadow-lg">
             <i class="fas fa-brain text-primary text-lg"></i>
           </div>
           <span class="text-2xl font-black tracking-tighter uppercase">Alpha Psychometrics</span>
        </div>
        
        <p class="text-white/70 text-sm leading-relaxed max-w-sm font-medium">
          The premier behavioral analytics platform in East Africa. We bridge the gap between human potential and data-driven insights for educational institutions and corporate enterprises.
        </p>

        <div class="flex space-x-5 mt-6">
          <a v-for="social in socials" :key="social.name" href="#" 
             class="w-10 h-10 rounded-xl bg-white/10 flex items-center justify-center hover:bg-secondary hover:scale-110 transition-all duration-300 group">
            <i :class="[social.class, 'text-lg group-hover:text-white transition-colors']"></i>
          </a>
        </div>
      </div>

      <div v-for="group in navGroups" :key="group.title">
        <h3 class="text-xs font-black uppercase tracking-[0.2em] text-white/50 mb-6">{{ group.title }}</h3>
        <ul class="space-y-4">
          <li v-for="link in group.links" :key="link.name">
            <a :href="link.url" class="text-sm text-white/80 hover:text-secondary hover:translate-x-1 inline-block transition-all duration-200">
              {{ link.name }}
            </a>
          </li>
        </ul>
      </div>

    </div>

    <div class="mt-20 border-t border-white/10 pt-8 max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between">
      <div class="text-xs font-bold text-white/40 uppercase tracking-widest">
        © {{ new Date().getFullYear() }} Alpha Psychometrics. A Division of Alpha Tech.
      </div>
      
      <div class="flex gap-8 mt-6 md:mt-0 text-[11px] font-black uppercase tracking-widest">
        <a href="#" class="text-white/40 hover:text-secondary transition-colors">Data Ethics</a>
        <a href="#" class="text-white/40 hover:text-secondary transition-colors">Privacy Policy</a>
        <a href="#" class="text-white/40 hover:text-secondary transition-colors">Research Citations</a>
      </div>
    </div>
  </footer>
</template>

<script setup>
const socials = [
  { name: 'LinkedIn', class: 'fab fa-linkedin-in' },
  { name: 'Twitter', class: 'fab fa-twitter' },
  { name: 'Telegram', class: 'fab fa-telegram-plane' },
  { name: 'Facebook', class: 'fab fa-facebook-f' }
];

const navGroups = [
  {
    title: 'Platform',
    links: [
      { name: 'Student Aptitude', url: '#' },
      { name: 'Corporate Profiles', url: '#' },
      { name: 'Interactive Engine', url: '#' },
      { name: 'Report Analytics', url: '#' }
    ]
  },
  {
    title: 'Resources',
    links: [
      { name: 'Methodology', url: '#' },
      { name: 'Sample Reports', url: '#' },
      { name: 'API Docs', url: '#' },
      { name: 'System Status', url: '#' }
    ]
  },
  {
    title: 'Organization',
    links: [
      { name: 'Our Science', url: '#' },
      { name: 'Pricing Plans', url: '#' },
      { name: 'Consult Expert', url: '#' },
      { name: 'Security Whitepaper', url: '#' }
    ]
  }
];
</script>

<style scoped>
footer::before {
  content: "";
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)'/%3E%3C/svg%3E");
  opacity: 0.03;
  pointer-events: none;
}
</style>