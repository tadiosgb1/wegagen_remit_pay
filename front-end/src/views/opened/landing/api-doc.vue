<template>
  <div class="min-h-screen bg-white flex flex-col font-sans selection:bg-primary/10">
    <header class="bg-primary sticky top-0 z-50 border-b border-white/10 shadow-lg backdrop-blur-md bg-opacity-95 transition-all duration-500">
      <div class="max-w-7xl mx-auto px-6 py-3 flex items-center justify-between">
        <div class="flex items-center space-x-3 group cursor-pointer" @click="scrollTo('home')">
          <div class="h-11 w-11 bg-white rounded-xl flex items-center justify-center shadow-inner transform group-hover:rotate-12 transition-transform duration-300">
            <i class="fas fa-layer-group text-primary text-xl"></i>
          </div>
          <div class="flex flex-col">
            <span class="text-xl font-black text-white tracking-tighter leading-none">ALPHA</span>
            <span class="text-[10px] font-bold text-white/70 uppercase tracking-[0.2em] leading-none mt-1">SMS Aggregator</span>
          </div>
        </div>

        <nav class="hidden md:flex items-center space-x-8 text-white/90 text-sm font-bold uppercase tracking-widest">
          <a href="#features" class="hover:text-white transition relative">Features</a>
          <a href="#api" class="hover:text-white transition relative">API Docs</a>
          <a href="#plans" class="hover:text-white transition relative">Bulk Pricing</a>
          <a href="#contact" class="hover:text-white transition relative">Support</a>
        </nav>

        <div class="hidden md:flex items-center space-x-4">
          <select v-model="selectedLang" class="bg-white/10 text-white text-xs font-black px-4 py-2 rounded-xl border border-white/20 outline-none">
            <option value="cURL" class="text-slate-800">EN</option>
            <option value="am" class="text-slate-800">AM</option>
          </select>
          <button @click="showLoginModal = true" class="flex items-center gap-2 px-6 py-2.5 font-black text-xs uppercase tracking-widest text-white bg-secondary rounded-xl shadow-lg hover:bg-opacity-90 transition-all">
            Login
          </button>
        </div>

        <button @click="mobileMenuOpen = !mobileMenuOpen" class="md:hidden text-white text-2xl">
          <i class="fas" :class="mobileMenuOpen ? 'fa-times' : 'fa-bars-staggered'"></i>
        </button>
      </div>
    </header>

    <div class="flex flex-1 max-w-[1600px] mx-auto w-full relative">
      <SidebarList />

      <main class="flex-1 flex flex-col lg:flex-row">
        <div class="flex-1 p-8 lg:p-16 max-w-3xl">
          <section id="send-sms" class="mb-32">
            <div class="flex items-center gap-3 mb-6">
              <span class="px-2 py-1 bg-green-100 text-green-700 text-[10px] font-black rounded uppercase">POST</span>
              <code class="text-sm font-mono font-bold text-slate-400">/api/v1/send</code>
            </div>
            <h1 class="text-4xl font-black text-slate-900 mb-6 tracking-tight">Send Transactional SMS</h1>
            <p class="text-slate-500 text-lg font-medium leading-relaxed mb-10">
              Use this endpoint to send instant messages to a single recipient. Perfect for OTPs, alerts, and notifications. 
              Supports <strong>Amharic (Unicode)</strong> and automated message splitting.
            </p>

            <h4 class="text-xs font-black uppercase tracking-widest text-slate-900 border-b border-slate-100 pb-4 mb-8">Request Parameters</h4>
            <div class="space-y-8">
              <div v-for="param in smsParams" :key="param.name" class="flex flex-col border-b border-slate-50 pb-6">
                <div class="flex items-center justify-between mb-2">
                  <div class="flex items-center gap-3">
                    <span class="font-mono font-bold text-primary">{{ param.name }}</span>
                    <span class="text-[10px] font-black text-slate-300 uppercase">{{ param.type }}</span>
                  </div>
                  <span v-if="param.required" class="text-[9px] font-black text-rose-500 bg-rose-50 px-2 py-0.5 rounded uppercase">Required</span>
                </div>
                <p class="text-sm text-slate-500 font-medium leading-relaxed">{{ param.desc }}</p>
                <p v-if="param.default" class="mt-2 text-[10px] text-slate-400 italic">Default: {{ param.default }}</p>
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
            <button @click="activeMode = 'test'" :class="activeMode === 'test' ? 'bg-primary text-white' : 'bg-slate-700 text-slate-300'" class="mr-4 px-3 py-1 rounded-md text-[9px] font-black uppercase">Try It</button>
          </div>

          <div class="p-8 flex-1 overflow-y-auto no-scrollbar font-mono text-sm">
            <div v-if="activeMode === 'code'">
              <div class="flex justify-between items-center mb-6">
                <h5 class="text-[10px] font-black uppercase tracking-widest text-slate-500">Request Snippet</h5>
                <button class="text-slate-500 hover:text-white text-xs"><i class="far fa-copy"></i></button>
              </div>
              <pre class="text-blue-400 leading-relaxed whitespace-pre-wrap">{{ generateSnippet() }}</pre>
            </div>

            <div v-else class="space-y-6">
              <div class="flex justify-between items-center">
                <h5 class="text-[10px] font-black uppercase tracking-widest text-slate-500">Live API Explorer</h5>
                <button @click="activeMode = 'code'" class="text-primary text-[10px] font-black uppercase">Back to Code</button>
              </div>
              
              <div class="space-y-4">
                <div class="grid grid-cols-2 gap-4">
                  <div class="space-y-2">
                    <label class="text-[9px] font-black text-slate-500 uppercase">Sender ID</label>
                    <input v-model="testData.sender" class="w-full bg-slate-800 border border-white/5 rounded-lg px-3 py-2 text-white text-xs outline-none focus:border-primary" />
                  </div>
                  <div class="space-y-2">
                    <label class="text-[9px] font-black text-slate-500 uppercase">To Number</label>
                    <input v-model="testData.to" class="w-full bg-slate-800 border border-white/5 rounded-lg px-3 py-2 text-white text-xs outline-none focus:border-primary" />
                  </div>
                </div>
                <div class="space-y-2">
                  <label class="text-[9px] font-black text-slate-500 uppercase">Message Body</label>
                  <textarea v-model="testData.message" rows="3" class="w-full bg-slate-800 border border-white/5 rounded-lg px-3 py-2 text-white text-xs outline-none focus:border-primary"></textarea>
                </div>
                <button @click="executeApi" :disabled="loading" class="w-full bg-primary text-white py-3 rounded-xl font-black uppercase text-[10px] tracking-[0.2em] shadow-lg shadow-primary/20 flex justify-center items-center">
                  <span v-if="!loading">Send Request</span>
                  <span v-else class="animate-spin text-lg">◌</span>
                </button>
              </div>

              <div v-if="apiResponse" class="mt-8">
                <h5 class="text-[10px] font-black uppercase tracking-widest text-slate-500 mb-4">Response Body</h5>
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
import Header from './header.vue'
import Footer from './footer.vue'
// Local import since they are in the same folder
import SidebarList from './apidocs/SidebarList.vue' 

export default {
  name: 'SendSms',
  components: {
    Header,
    Footer,
    SidebarList
  },
  data() {
    return {
      selectedLang: 'cURL',
      activeMode: 'code',
      loading: false,
      apiResponse: null,
      mobileMenuOpen: false,
      showLoginModal: false,
      languages: ['cURL', 'Node.js', 'PHP', 'Python', 'Java', 'Go'],
      smsParams: [
        { name: 'from', type: 'string', required: false, desc: 'Your System Identifier ID.', default: 'Default Identifier' },
        { name: 'sender', type: 'string', required: true, desc: 'The verified Sender Name displayed to users.' },
        { name: 'to', type: 'string', required: true, desc: 'Recipient phone number (+251...).' },
        { name: 'message', type: 'string', required: true, desc: 'The SMS content or Template UID.' }
      ],
      testData: {
        sender: 'AlphaMsg',
        to: '+251911223344',
        message: 'Hello! This is a test from Alpha Message Console.'
      }
    }
  },
  methods: {
    generateSnippet() {
      const { sender, to, message } = this.testData
      const url = 'https://api.alphamsg.com/api/send'
      const snippets = {
        'cURL': `curl -X POST "${url}" \\\n  -H "Authorization: Bearer {TOKEN}" \\\n  -H "Content-Type: application/json" \\\n  -d '{"sender":"${sender}", "to":"${to}", "message":"${message}"}'`,
        'Node.js': `const axios = require('axios');\n\naxios.post('${url}', {\n  sender: '${sender}',\n  to: '${to}',\n  message: '${message}'\n}, {\n  headers: { 'Authorization': 'Bearer {TOKEN}' }\n});`,
        'PHP': `$ch = curl_init('${url}');\ncurl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([\n  "sender" => "${sender}",\n  "to" => "${to}",\n  "message" => "${message}"\n]));\ncurl_setopt($ch, CURLOPT_HTTPHEADER, ['Authorization: Bearer {TOKEN}']);\ncurl_exec($ch);`,
        'Python': `import requests\n\nresp = requests.post('${url}', \n  json={"sender": "${sender}", "to": "${to}", "message": "${message}"},\n  headers={"Authorization": "Bearer {TOKEN}"}\n)\nprint(resp.json())`,
        'Java': `OkHttpClient client = new OkHttpClient();\nMediaType mediaType = MediaType.parse("application/json");\nRequestBody body = RequestBody.create(mediaType, "{\\"sender\\":\\"${sender}\\"...}");\nRequest request = new Request.Builder().url("${url}").post(body).build();`,
        'Go': `payload := strings.NewReader(\`{"sender":"${sender}","to":"${to}"}\`)\nreq, _ := http.NewRequest("POST", "${url}", payload)\nreq.Header.Add("Authorization", "Bearer {TOKEN}")`
      }
      return snippets[this.selectedLang]
    },
    async executeApi() {
      this.loading = true
      this.apiResponse = null
      try {
        await new Promise(r => setTimeout(r, 1500))
        this.apiResponse = {
          ok: true,
          data: JSON.stringify({ acknowledge: "success", response: { status: "Send in progress...", message_id: "9ab2-867c", to: this.testData.to } }, null, 2)
        }
      } catch (e) {
        this.apiResponse = { ok: false, data: "Error: 401 Unauthorized." }
      } finally {
        this.loading = false
      }
    },
    scrollTo(id) {
        console.log('Scrolling to', id);
    }
  }
}
</script>

<style scoped>
.no-scrollbar::-webkit-scrollbar { display: none; }
pre { white-space: pre-wrap; word-wrap: break-word; }
</style>