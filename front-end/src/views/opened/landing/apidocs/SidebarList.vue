<template>
  <aside class="w-72 border-r border-slate-50 p-8 hidden lg:block sticky top-[80px] h-[calc(100vh-80px)] overflow-y-auto no-scrollbar">
    <nav class="space-y-10">
      <div v-for="group in menuGroups" :key="group.title">
        <h5 class="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 mb-6">
          {{ group.title }}
        </h5>
        <ul class="space-y-4">
          <li v-for="link in group.links" :key="link.name">
            <router-link 
              :to="link.path" 
              class="text-sm font-bold text-slate-500 hover:text-primary transition-colors flex items-center gap-2"
              active-class="text-primary"
            >
              <span v-if="link.method" :class="methodClass(link.method)">
                {{ link.method }}
              </span>
              {{ link.name }}
            </router-link>
          </li>
        </ul>
      </div>
    </nav>
  </aside>
</template>

<script>
export default {
  name: 'Sidebar',
  data() {
    return {
      menuGroups: [
        {
          title: 'Messaging',
          links: [
            { name: 'Send SMS', path: '/send-sms', method: 'POST' },
            { name: 'Bulk Send', path: '/bulk-sms', method: 'POST' },
            { name: 'OTP-Security Code', path: '/otp', method: 'GET' }
          ]
        },
        {
          title: 'Management',
          links: [
            { name: 'Verify Code', path: '/verify', method: 'GET' },
            { name: 'Balance', path: '/balance', method: 'GET' },
            { name: 'Status', path: '/status', method: 'GET' }
          ]
        }
      ]
    }
  },
  methods: {
    methodClass(m) {
      const colors = { 
        POST: 'text-emerald-500', 
        GET: 'text-blue-500', 
        DELETE: 'text-rose-500' 
      };
      return `text-[8px] font-black px-1.5 py-0.5 rounded bg-slate-100 ${colors[m]}`;
    }
  }
}
</script>

<style scoped>
.no-scrollbar::-webkit-scrollbar { display: none; }
</style>