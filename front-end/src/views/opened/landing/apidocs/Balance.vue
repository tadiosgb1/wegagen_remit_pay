<template>
  <div class="min-h-screen bg-white flex flex-col font-sans selection:bg-primary/10">
    <Header />
    <div class="flex flex-1 max-w-[1600px] mx-auto w-full relative">
      <SidebarList />
      <main class="flex-1 flex flex-col lg:flex-row">
        <div class="flex-1 p-8 lg:p-16 max-w-3xl">
          <section id="get-balance" class="mb-32">
            <div class="flex items-center gap-3 mb-6">
              <span class="px-2 py-1 bg-blue-100 text-blue-700 text-[10px] font-black rounded uppercase">GET</span>
              <code class="text-sm font-mono font-bold text-slate-400">/api/v1/balance</code>
            </div>
            <h1 class="text-4xl font-black text-slate-900 mb-6 tracking-tight">Check Account Balance</h1>
            <p class="text-slate-500 text-lg font-medium leading-relaxed mb-10">
              Retrieve your current credit balance and estimated remaining message count. This endpoint is ideal for automated systems to trigger alerts when credits are running low.
            </p>

            <h4 class="text-xs font-black uppercase tracking-widest text-slate-900 border-b border-slate-100 pb-4 mb-8">Details</h4>
            <div class="space-y-6">
              <p class="text-sm text-slate-500 font-medium">
                No additional parameters are required for this call. The system identifies your account based on the <strong>Bearer Token</strong> provided in the Authorization header.
              </p>
              <div class="p-4 bg-slate-50 rounded-xl border border-slate-100">
                <span class="text-[10px] font-black text-slate-400 uppercase block mb-2">Note</span>
                <p class="text-xs text-slate-600 italic leading-relaxed">
                  "The estimated message count is based on your current pricing tier and standard single-part message costs."
                </p>
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
            <button @click="activeMode = 'test'" :class="activeMode === 'test' ? 'bg-primary text-white' : 'bg-slate-700 text-slate-300'" class="mr-4 px-3 py-1 rounded-md text-[9px] font-black uppercase">Live Check</button>
          </div>

          <div class="p-8 flex-1 overflow-y-auto no-scrollbar font-mono text-sm">
            <div v-if="activeMode === 'code'">
              <div class="flex justify-between items-center mb-6">
                <h5 class="text-[10px] font-black uppercase tracking-widest text-slate-500">Request Header</h5>
                <button class="text-slate-500 hover:text-white text-xs"><i class="far fa-copy"></i></button>
              </div>
              <pre class="text-blue-400 leading-relaxed whitespace-pre-wrap">{{ generateBalanceSnippet() }}</pre>
            </div>

            <div v-else class="space-y-6">
              <div class="flex justify-between items-center">
                <h5 class="text-[10px] font-black uppercase tracking-widest text-slate-500">Execution</h5>
                <button @click="activeMode = 'code'" class="text-primary text-[10px] font-black uppercase">View cURL</button>
              </div>
              
              <div class="p-6 bg-slate-800/30 rounded-2xl border border-white/5">
                <p class="text-xs text-slate-400 mb-6 leading-relaxed">
                  Ready to fetch real-time balance for the authenticated token?
                </p>
                <button @click="executeApi" :disabled="loading" class="w-full bg-primary text-white py-3 rounded-xl font-black uppercase text-[10px] tracking-[0.2em] shadow-lg flex justify-center items-center">
                  <span v-if="!loading">Fetch Current Balance</span>
                  <span v-else class="animate-spin text-lg">◌</span>
                </button>
              </div>

              <div v-if="apiResponse" class="mt-8">
                <h5 class="text-[10px] font-black uppercase tracking-widest text-slate-500 mb-4">Account Response</h5>
                <div class="bg-black/40 border border-white/5 p-6 rounded-2xl overflow-x-auto">
                  <pre class="text-emerald-400">{{ apiResponse.data }}</pre>
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
  name: 'GetBalance',
  components: { SidebarList,Footer,Header },
  data() {
    return {
      selectedLang: 'cURL',
      activeMode: 'code',
      loading: false,
      apiResponse: null,
      languages: ['cURL', 'PHP', 'Python', 'Node.js'],
    }
  },
  methods: {
    generateBalanceSnippet() {
      const url = 'https://api.alphamsg.com/api/balance';
      const snippets = {
        'cURL': `curl -X GET "${url}" \\\n  -H "Authorization: Bearer {YOUR_TOKEN}"`,
        'PHP': `// Using cURL\n$ch = curl_init("${url}");\ncurl_setopt($ch, CURLOPT_HTTPHEADER, ['Authorization: Bearer {TOKEN}']);\ncurl_exec($ch);`,
        'Python': `import requests\nresponse = requests.get("${url}", \n  headers={"Authorization": "Bearer {TOKEN}"}\n)\nprint(response.json())`,
        'Node.js': `const axios = require('axios');\n\naxios.get("${url}", {\n  headers: { 'Authorization': 'Bearer {TOKEN}' }\n});`
      };
      return snippets[this.selectedLang];
    },
    async executeApi() {
      this.loading = true;
      try {
        // Simulate real API latency
        await new Promise(r => setTimeout(r, 1000));
        this.apiResponse = {
          data: JSON.stringify({
            acknowledge: "success",
            response: {
              balance: "2,450.75",
              currency: "ETB",
              estimatedMessages: "16338",
              lastRecharge: "2026-02-15"
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