<template>
  <div class="min-h-screen bg-white flex flex-col font-sans selection:bg-primary/10">
     <Header />
    <div class="flex flex-1 max-w-[1600px] mx-auto w-full relative">
      <SidebarList />

      <main class="flex-1 flex flex-col lg:flex-row">
        <div class="flex-1 p-8 lg:p-16 max-w-3xl">
          <section id="verify-code" class="mb-32">
            <div class="flex items-center gap-3 mb-6">
              <span class="px-2 py-1 bg-blue-100 text-blue-700 text-[10px] font-black rounded uppercase">GET</span>
              <code class="text-sm font-mono font-bold text-slate-400">/api/v1/verify</code>
            </div>
            <h1 class="text-4xl font-black text-slate-900 mb-6 tracking-tight">Verify Security Code</h1>
            <p class="text-slate-500 text-lg font-medium leading-relaxed mb-10">
              Check the authenticity of a code submitted by your user. You can verify using the recipient's phone number or the unique <strong>Verification ID</strong> returned during the challenge phase.
            </p>

            <h4 class="text-xs font-black uppercase tracking-widest text-slate-900 border-b border-slate-100 pb-4 mb-8">Verification Parameters</h4>
            <div class="space-y-8">
              <div v-for="param in verifyParams" :key="param.name" class="flex flex-col border-b border-slate-50 pb-6">
                <div class="flex items-center justify-between mb-2">
                  <div class="flex items-center gap-3">
                    <span class="font-mono font-bold text-primary">{{ param.name }}</span>
                    <span class="text-[10px] font-black text-slate-300 uppercase">{{ param.type }}</span>
                  </div>
                  <span v-if="param.required" class="text-[9px] font-black text-rose-500 bg-rose-50 px-2 py-0.5 rounded uppercase">Required</span>
                </div>
                <p class="text-sm text-slate-500 font-medium leading-relaxed">{{ param.desc }}</p>
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
            <button @click="activeMode = 'test'" :class="activeMode === 'test' ? 'bg-primary text-white' : 'bg-slate-700 text-slate-300'" class="mr-4 px-3 py-1 rounded-md text-[9px] font-black uppercase">Live Verify</button>
          </div>

          <div class="p-8 flex-1 overflow-y-auto no-scrollbar font-mono text-sm">
            <div v-if="activeMode === 'code'">
              <h5 class="text-[10px] font-black uppercase tracking-widest text-slate-500 mb-6">Verification Snippet</h5>
              <pre class="text-blue-400 leading-relaxed whitespace-pre-wrap">{{ generateVerifySnippet() }}</pre>
            </div>

            <div v-else class="space-y-6">
              <div class="flex justify-between items-center">
                <h5 class="text-[10px] font-black uppercase tracking-widest text-slate-500">Manual Verification</h5>
                <button @click="activeMode = 'code'" class="text-primary text-[10px] font-black uppercase">View Code</button>
              </div>
              
              <div class="space-y-4">
                <div class="space-y-2">
                  <label class="text-[9px] font-black text-slate-500 uppercase">Verification ID (Optional)</label>
                  <input v-model="testData.vc" placeholder="vc-9as2..." class="w-full bg-slate-800 border border-white/5 rounded-lg px-3 py-2 text-white text-xs outline-none focus:border-primary" />
                </div>
                <div class="space-y-2">
                  <label class="text-[9px] font-black text-slate-500 uppercase">Phone Number</label>
                  <input v-model="testData.to" class="w-full bg-slate-800 border border-white/5 rounded-lg px-3 py-2 text-white text-xs outline-none focus:border-primary" />
                </div>
                <div class="space-y-2">
                  <label class="text-[9px] font-black text-slate-500 uppercase">Code to Verify</label>
                  <input v-model="testData.code" placeholder="123456" class="w-full bg-slate-800 border border-white/5 rounded-lg px-3 py-2 text-white text-xs outline-none focus:border-primary border-dashed" />
                </div>
                <button @click="executeApi" :disabled="loading" class="w-full bg-primary text-white py-3 rounded-xl font-black uppercase text-[10px] tracking-[0.2em] shadow-lg flex justify-center items-center">
                  <span v-if="!loading">Verify Code Now</span>
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
  name: 'VerifyCode',
  components: { SidebarList,Footer,Header },
  data() {
    return {
      selectedLang: 'cURL',
      activeMode: 'code',
      loading: false,
      apiResponse: null,
      languages: ['cURL', 'Node.js', 'Python'],
      verifyParams: [
        { name: 'to', type: 'string', required: false, desc: 'The recipient phone number. Mandatory if Verification ID is not given.' },
        { name: 'vc', type: 'string', required: false, desc: 'The unique Verification ID received from the /challenge response.' },
        { name: 'code', type: 'string', required: true, desc: 'The secret code submitted by the user.' }
      ],
      testData: {
        to: '+251911001122',
        vc: '',
        code: ''
      }
    }
  },
  methods: {
    generateVerifySnippet() {
      const url = `https://api.alphamsg.com/api/verify?to=${this.testData.to}&code=${this.testData.code}${this.testData.vc ? '&vc='+this.testData.vc : ''}`;
      
      const snippets = {
        'cURL': `curl -X GET "${url}" \\\n  -H "Authorization: Bearer {TOKEN}"`,
        'Node.js': `axios.get("${url}", {\n  headers: { 'Authorization': 'Bearer {TOKEN}' }\n});`,
        'Python': `requests.get("${url}", headers={"Authorization": "Bearer {TOKEN}"})`
      };
      return snippets[this.selectedLang];
    },
    async executeApi() {
      if (!this.testData.code) return alert("Please enter a code to verify");
      this.loading = true;
      try {
        await new Promise(r => setTimeout(r, 1200));
        // Logic: if code is 123456, simulate success, else fail
        const isSuccess = this.testData.code === '123456';
        
        this.apiResponse = {
          ok: isSuccess,
          data: isSuccess 
            ? JSON.stringify({
                acknowledge: "success",
                response: {
                  phone: this.testData.to,
                  code: this.testData.code,
                  verificationId: this.testData.vc || "v-82hf-92kd",
                  status: "Verified Successfully",
                  sentAt: "2 minutes ago"
                }
              }, null, 2)
            : JSON.stringify({
                acknowledge: "failure",
                response: {
                  error: "Invalid Code",
                  description: "The code provided does not match or has expired."
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