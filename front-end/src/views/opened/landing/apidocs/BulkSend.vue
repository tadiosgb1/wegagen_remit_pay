<template>
  <div class="min-h-screen bg-white flex flex-col font-sans selection:bg-primary/10">
    <Header />

    <div class="flex flex-1 max-w-[1600px] mx-auto w-full relative">
      <SidebarList />

      <main class="flex-1 flex flex-col lg:flex-row">
        <div class="flex-1 p-8 lg:p-16 max-w-3xl">
          <section id="bulk-sms" class="mb-32">
            <div class="flex items-center gap-3 mb-6">
              <span class="px-2 py-1 bg-green-100 text-green-700 text-[10px] font-black rounded uppercase">POST</span>
              <code class="text-sm font-mono font-bold text-slate-400">/api/v1/bulk_send</code>
            </div>
            <h1 class="text-4xl font-black text-slate-900 mb-6 tracking-tight">Send Bulk SMS</h1>
            <p class="text-slate-500 text-lg font-medium leading-relaxed mb-10">
              Broadcast messages to thousands of recipients in a single call. You can send the <strong>same message</strong> to a list or <strong>personalized messages</strong> using unique objects.
            </p>

            <h4 class="text-xs font-black uppercase tracking-widest text-slate-900 border-b border-slate-100 pb-4 mb-8">Bulk Parameters</h4>
            <div class="space-y-8">
              <div v-for="param in bulkParams" :key="param.name" class="flex flex-col border-b border-slate-50 pb-6">
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
            <button @click="activeMode = 'test'" :class="activeMode === 'test' ? 'bg-primary text-white' : 'bg-slate-700 text-slate-300'" class="mr-4 px-3 py-1 rounded-md text-[9px] font-black uppercase">Try Bulk</button>
          </div>

          <div class="p-8 flex-1 overflow-y-auto no-scrollbar font-mono text-sm">
            <div v-if="activeMode === 'code'">
              <h5 class="text-[10px] font-black uppercase tracking-widest text-slate-500 mb-6">Request JSON Structure</h5>
              <pre class="text-blue-400 leading-relaxed whitespace-pre-wrap">{{ generateBulkSnippet() }}</pre>
            </div>

            <div v-else class="space-y-6">
              <div class="flex justify-between items-center">
                <h5 class="text-[10px] font-black uppercase tracking-widest text-slate-500">Bulk Explorer</h5>
                <button @click="activeMode = 'code'" class="text-primary text-[10px] font-black uppercase">View JSON</button>
              </div>
              
              <div class="space-y-4">
                <div class="space-y-2">
                  <label class="text-[9px] font-black text-slate-500 uppercase">Campaign Name</label>
                  <input v-model="testData.campaign" class="w-full bg-slate-800 border border-white/5 rounded-lg px-3 py-2 text-white text-xs outline-none" />
                </div>
                <div class="space-y-2">
                  <label class="text-[9px] font-black text-slate-500 uppercase">Recipients (Comma Separated)</label>
                  <textarea v-model="recipientInput" rows="3" class="w-full bg-slate-800 border border-white/5 rounded-lg px-3 py-2 text-white text-xs outline-none" placeholder="+251..., +251..."></textarea>
                </div>
                <button @click="executeApi" :disabled="loading" class="w-full bg-primary text-white py-3 rounded-xl font-black uppercase text-[10px] tracking-[0.2em] shadow-lg flex justify-center items-center">
                  <span v-if="!loading">Execute Bulk Send</span>
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
import Header from '../../landing/header.vue'
import Footer from '../../landing/footer.vue'
import SidebarList from './SidebarList.vue'

export default {
  name: 'BulkSms',
  components: { SidebarList,Footer,Header },
  data() {
    return {
      selectedLang: 'cURL',
      activeMode: 'code',
      loading: false,
      apiResponse: null,
      languages: ['cURL', 'Node.js', 'PHP', 'Python'],
      recipientInput: '+251911000001, +251911000002',
      bulkParams: [
        { name: 'to', type: 'array', required: true, desc: 'List of phone numbers or objects for personalized messages.' },
        { name: 'message', type: 'string', required: true, desc: 'The base message content.' },
        { name: 'campaign', type: 'string', required: false, desc: 'Name to identify this batch in the dashboard.' },
        { name: 'statusCallback', type: 'string', required: false, desc: 'URL to receive delivery reports for each number.' }
      ],
      testData: {
        sender: 'AlphaBulk',
        campaign: 'Promo_March_2026',
        message: 'Your monthly statement is ready to view.'
      }
    }
  },
  methods: {
    generateBulkSnippet() {
      const recipients = this.recipientInput.split(',').map(s => s.trim());
      const url = 'https://api.alphamsg.com/api/bulk_send';
      
      const snippets = {
        'cURL': `curl -X POST "${url}" \\\n  -H "Authorization: Bearer {TOKEN}" \\\n  -d '{\n    "sender": "${this.testData.sender}",\n    "to": ${JSON.stringify(recipients)},\n    "message": "${this.testData.message}",\n    "campaign": "${this.testData.campaign}"\n  }'`,
        'Node.js': `axios.post('${url}', {\n  to: ${JSON.stringify(recipients)},\n  message: '${this.testData.message}'\n});`,
        'PHP': `$data = [\n  "to" => ${JSON.stringify(recipients)},\n  "message" => "${this.testData.message}"\n];`,
        'Python': `requests.post('${url}', json={\n  "to": ${JSON.stringify(recipients)},\n  "message": "${this.testData.message}"\n})`
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
              message: "Bulk SMS is scheduled for send...", 
              campaign_id: "bulk-" + Math.random().toString(36).substr(2, 9) 
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