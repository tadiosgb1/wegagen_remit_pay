<template>
  <div class="min-h-screen bg-white flex flex-col font-sans selection:bg-primary/10">
    <Header />

    <div class="flex flex-1 max-w-[1600px] mx-auto w-full relative">
      <SidebarList />

      <main class="flex-1 flex flex-col lg:flex-row">
        <div class="flex-1 p-8 lg:p-16 max-w-3xl">
          <section id="otp-sms" class="mb-32">
            <div class="flex items-center gap-3 mb-6">
              <span class="px-2 py-1 bg-blue-100 text-blue-700 text-[10px] font-black rounded uppercase">GET</span>
              <code class="text-sm font-mono font-bold text-slate-400">/api/v1/challenge</code>
            </div>
            <h1 class="text-4xl font-black text-slate-900 mb-6 tracking-tight">Send Security Code</h1>
            <p class="text-slate-500 text-lg font-medium leading-relaxed mb-10">
              Generate and deliver One-Time Passwords (OTP) for 2FA or verification. Our system automatically generates a secure code, manages its expiration, and allows for custom message wrapping.
            </p>

            <h4 class="text-xs font-black uppercase tracking-widest text-slate-900 border-b border-slate-100 pb-4 mb-8">Challenge Parameters</h4>
            <div class="space-y-8">
              <div v-for="param in otpParams" :key="param.name" class="flex flex-col border-b border-slate-50 pb-6">
                <div class="flex items-center justify-between mb-2">
                  <div class="flex items-center gap-3">
                    <span class="font-mono font-bold text-primary">{{ param.name }}</span>
                    <span class="text-[10px] font-black text-slate-300 uppercase">{{ param.type }}</span>
                  </div>
                  <span v-if="param.required" class="text-[9px] font-black text-rose-500 bg-rose-50 px-2 py-0.5 rounded uppercase">Required</span>
                </div>
                <p class="text-sm text-slate-500 font-medium leading-relaxed">{{ param.desc }}</p>
                <p v-if="param.default !== undefined" class="mt-2 text-[10px] text-slate-400 italic">Default: {{ param.default }}</p>
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
            <button @click="activeMode = 'test'" :class="activeMode === 'test' ? 'bg-primary text-white' : 'bg-slate-700 text-slate-300'" class="mr-4 px-3 py-1 rounded-md text-[9px] font-black uppercase">Configure OTP</button>
          </div>

          <div class="p-8 flex-1 overflow-y-auto no-scrollbar font-mono text-sm">
            <div v-if="activeMode === 'code'">
              <h5 class="text-[10px] font-black uppercase tracking-widest text-slate-500 mb-6">Generated Query URL</h5>
              <pre class="text-blue-400 leading-relaxed whitespace-pre-wrap">{{ generateOtpSnippet() }}</pre>
            </div>

            <div v-else class="space-y-6">
              <div class="flex justify-between items-center">
                <h5 class="text-[10px] font-black uppercase tracking-widest text-slate-500">OTP Configuration</h5>
                <button @click="activeMode = 'code'" class="text-primary text-[10px] font-black uppercase">View Query</button>
              </div>
              
              <div class="space-y-4">
                <div class="grid grid-cols-2 gap-4">
                  <div class="space-y-2">
                    <label class="text-[9px] font-black text-slate-500 uppercase">Code Length</label>
                    <input type="number" v-model="testData.len" class="w-full bg-slate-800 border border-white/5 rounded-lg px-3 py-2 text-white text-xs outline-none focus:border-primary" />
                  </div>
                  <div class="space-y-2">
                    <label class="text-[9px] font-black text-slate-500 uppercase">Expire (Sec)</label>
                    <input type="number" v-model="testData.ttl" class="w-full bg-slate-800 border border-white/5 rounded-lg px-3 py-2 text-white text-xs outline-none focus:border-primary" />
                  </div>
                </div>
                <div class="space-y-2">
                  <label class="text-[9px] font-black text-slate-500 uppercase">Code Type</label>
                  <select v-model="testData.t" class="w-full bg-slate-800 border border-white/5 rounded-lg px-3 py-2 text-white text-xs outline-none">
                    <option :value="0">Numeric (0-9)</option>
                    <option :value="1">Alpha (A-Z)</option>
                    <option :value="2">Alphanumeric</option>
                  </select>
                </div>
                <div class="space-y-2">
                  <label class="text-[9px] font-black text-slate-500 uppercase">Prefix Text</label>
                  <input v-model="testData.pr" placeholder="Your code is:" class="w-full bg-slate-800 border border-white/5 rounded-lg px-3 py-2 text-white text-xs outline-none" />
                </div>
                <button @click="executeApi" :disabled="loading" class="w-full bg-primary text-white py-3 rounded-xl font-black uppercase text-[10px] tracking-[0.2em] shadow-lg flex justify-center items-center">
                  <span v-if="!loading">Test Challenge</span>
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
  name: 'OtpSms',
  components: { SidebarList,Footer,Header },
  data() {
    return {
      selectedLang: 'cURL',
      activeMode: 'code',
      loading: false,
      apiResponse: null,
      languages: ['cURL', 'PHP', 'Python'],
      otpParams: [
        { name: 'to', type: 'string', required: true, desc: 'Recipient phone number (+251...).' },
        { name: 'len', type: 'number', required: false, desc: 'Character length of the code.', default: 4 },
        { name: 't', type: 'number', required: false, desc: '0: Numeric, 1: Alpha, 2: Alphanumeric.', default: 0 },
        { name: 'ttl', type: 'number', required: false, desc: 'Seconds until code expires (0 = never).', default: 0 },
        { name: 'pr', type: 'string', required: false, desc: 'Message prefix (e.g. "Your code is").' }
      ],
      testData: {
        to: '+251911001122',
        len: 6,
        t: 0,
        ttl: 300,
        pr: 'Your Alpha code is'
      }
    }
  },
  methods: {
    generateOtpSnippet() {
      const base = `https://api.alphamsg.com/api/challenge?to=${this.testData.to}&len=${this.testData.len}&t=${this.testData.t}&ttl=${this.testData.ttl}&pr=${encodeURIComponent(this.testData.pr)}`;
      
      const snippets = {
        'cURL': `curl -X GET "${base}" \\\n  -H "Authorization: Bearer {TOKEN}"`,
        'PHP': `file_get_contents("${base}");`,
        'Python': `requests.get("${base}", headers={"Authorization": "Bearer {TOKEN}"})`
      };
      return snippets[this.selectedLang];
    },
    async executeApi() {
      this.loading = true;
      try {
        await new Promise(r => setTimeout(r, 1500));
        this.apiResponse = {
          ok: true,
          data: JSON.stringify({
            acknowledge: "success",
            response: {
              status: "Send is in progress...",
              to: this.testData.to,
              code: "884210", // Example generated code
              verificationId: "v-" + Math.random().toString(36).substr(2, 9)
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