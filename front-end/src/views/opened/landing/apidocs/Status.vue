<template>
  <div class="min-h-screen bg-white flex flex-col font-sans selection:bg-primary/10">
    <Header />
    <div class="flex flex-1 max-w-[1600px] mx-auto w-full relative">
      <SidebarList />

      <main class="flex-1 flex flex-col lg:flex-row">
        <div class="flex-1 p-8 lg:p-16 max-w-3xl">
          <section id="get-status" class="mb-32">
            <div class="flex items-center gap-3 mb-6">
              <span class="px-2 py-1 bg-blue-100 text-blue-700 text-[10px] font-black rounded uppercase">GET</span>
              <code class="text-sm font-mono font-bold text-slate-400">/api/v1/status</code>
            </div>
            <h1 class="text-4xl font-black text-slate-900 mb-6 tracking-tight">Message Status</h1>
            <p class="text-slate-500 text-lg font-medium leading-relaxed mb-10">
              Check the latest delivery state of a specific message. This is useful for auditing and as a fallback mechanism if your callback URL was unavailable during the initial delivery attempt.
            </p>

            <div class="mb-12 p-6 bg-amber-50 border-l-4 border-amber-400 rounded-r-2xl">
              <div class="flex items-center gap-3 mb-2">
                <i class="fas fa-exclamation-triangle text-amber-600"></i>
                <span class="text-xs font-black text-amber-800 uppercase tracking-widest">Rate Limit Notice</span>
              </div>
              <p class="text-sm text-amber-700 leading-relaxed font-medium">
                This endpoint is limited to <strong>30 requests per minute</strong>. Exceeding this limit will result in a 2-minute temporary block. Always inspect the <code>Retry-After</code> header.
              </p>
            </div>

            <h4 class="text-xs font-black uppercase tracking-widest text-slate-900 border-b border-slate-100 pb-4 mb-8">Required Parameter</h4>
            <div class="space-y-8">
              <div class="flex flex-col border-b border-slate-50 pb-6">
                <div class="flex items-center justify-between mb-2">
                  <div class="flex items-center gap-3">
                    <span class="font-mono font-bold text-primary">id</span>
                    <span class="text-[10px] font-black text-slate-300 uppercase">string</span>
                  </div>
                  <span class="text-[9px] font-black text-rose-500 bg-rose-50 px-2 py-0.5 rounded uppercase">Required</span>
                </div>
                <p class="text-sm text-slate-500 font-medium leading-relaxed">The unique <code>message_id</code> returned by the send API call.</p>
              </div>
            </div>
          </section>
        </div>

        <div class="lg:w-[500px] xl:w-[650px] bg-slate-900 lg:sticky lg:top-[80px] h-fit lg:h-[calc(100vh-80px)] flex flex-col shadow-2xl">
          <div class="flex items-center bg-slate-800/50 border-b border-white/5 px-2">
            <button v-for="lang in languages" :key="lang" 
              @click="selectedLang = lang"
              :class="[selectedLang === lang ? 'text-primary border-b-2 border-primary' : 'text-slate-500 hover:text-white']"
              class="px-4 py-4 text-[10px] font-black uppercase tracking-widest transition-all">
              {{ lang }}
            </button>
            <div class="flex-1"></div>
            <button @click="activeMode = 'test'" :class="activeMode === 'test' ? 'bg-primary text-white' : 'bg-slate-700 text-slate-300'" class="mr-4 px-3 py-1 rounded-md text-[9px] font-black uppercase">Track ID</button>
          </div>

          <div class="p-8 flex-1 overflow-y-auto no-scrollbar font-mono text-sm">
            <div v-if="activeMode === 'code'">
              <h5 class="text-[10px] font-black uppercase tracking-widest text-slate-500 mb-6">Status Request Snippet</h5>
              <pre class="text-blue-400 leading-relaxed whitespace-pre-wrap">{{ generateStatusSnippet() }}</pre>
            </div>

            <div v-else class="space-y-6">
              <div class="flex justify-between items-center">
                <h5 class="text-[10px] font-black uppercase tracking-widest text-slate-500">Manual Lookup</h5>
                <button @click="activeMode = 'code'" class="text-primary text-[10px] font-black uppercase">View Code</button>
              </div>
              
              <div class="space-y-4">
                <div class="space-y-2">
                  <label class="text-[9px] font-black text-slate-500 uppercase">Message ID</label>
                  <input v-model="messageId" placeholder="e.g. 9ab2867c-96ce-4405-b890" class="w-full bg-slate-800 border border-white/5 rounded-lg px-3 py-2 text-white text-xs outline-none focus:border-primary" />
                </div>
                <button @click="executeApi" :disabled="loading || !messageId" class="w-full bg-primary text-white py-3 rounded-xl font-black uppercase text-[10px] tracking-[0.2em] shadow-lg flex justify-center items-center disabled:opacity-50">
                  <span v-if="!loading">Track Delivery</span>
                  <span v-else class="animate-spin text-lg">◌</span>
                </button>
              </div>

              <div v-if="apiResponse" class="mt-8">
                <div class="bg-black/40 border border-white/5 p-6 rounded-2xl overflow-x-auto">
                  <pre :class="apiResponse.ok ? 'text-emerald-400' : 'text-rose-400'">{{ apiResponse.data }}</pre>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
    <Footer />
  </div>
</template>

<script>
import SidebarList from './SidebarList.vue'
import Header from '../../landing/header.vue'
import Footer from '../../landing/footer.vue'

export default {
  name: 'GetStatus',
  components: { SidebarList ,Footer,Header},
  data() {
    return {
      selectedLang: 'cURL',
      activeMode: 'code',
      loading: false,
      apiResponse: null,
      messageId: 'aa54b477-7eb7-4a7e-929f-7323803f6fbd',
      languages: ['cURL', 'PHP', 'Python', 'Node.js'],
    }
  },
  methods: {
    generateStatusSnippet() {
      const url = `https://api.alphamsg.com/api/status?id=${this.messageId}`;
      const snippets = {
        'cURL': `curl -X GET "${url}" \\\n  -H "Authorization: Bearer {TOKEN}"`,
        'PHP': `file_get_contents("${url}");`,
        'Python': `requests.get("${url}", headers={"Authorization": "Bearer {TOKEN}"})`,
        'Node.js': `axios.get("${url}", { headers: { 'Authorization': 'Bearer {TOKEN}' } });`
      };
      return snippets[this.selectedLang];
    },
    async executeApi() {
      this.loading = true;
      try {
        await new Promise(r => setTimeout(r, 1000));
        this.apiResponse = {
          ok: true,
          data: JSON.stringify({
            acknowledge: "success",
            response: {
              messageId: this.messageId,
              cost: "0.15",
              parts: "1",
              status: "DELIVRD",
              description: "Message delivered successfully to handset.",
              deliveredAt: "2026-03-02 10:15:30"
            }
          }, null, 2)
        };
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>