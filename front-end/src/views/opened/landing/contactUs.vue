<template>
  <section id="contact" class="py-32 bg-white relative overflow-hidden">
    <div class="absolute top-0 left-0 w-full h-full opacity-[0.02] pointer-events-none -z-0" 
         style="background-image: linear-gradient(#3d5afe 1px, transparent 1px), linear-gradient(90deg, #3d5afe 1px, transparent 1px); background-size: 50px 50px;">
    </div>
    
    <div class="max-w-7xl mx-auto px-6 relative z-10">
      
      <div class="grid grid-cols-1 lg:grid-cols-12 gap-16 items-start">
        
        <div class="lg:col-span-5 space-y-8">
          <div>
            <span class="inline-block px-4 py-1.5 mb-6 text-[10px] font-black tracking-[0.3em] text-primary bg-primary/10 rounded-full uppercase">
              Partner with Alpha
            </span>
            <h2 class="text-6xl font-black text-slate-900 mb-8 tracking-tighter leading-[0.9]">
              Decode Your <br/> <span class="text-primary">Potential.</span>
            </h2>
            <p class="text-slate-500 text-lg font-medium leading-relaxed max-w-md">
              Ready to implement scientific assessments? Our industrial psychologists are ready to help you benchmark your talent.
            </p>
          </div>

          <div class="grid grid-cols-1 gap-4">
            <div v-for="info in contactInfo" :key="info.label" 
                 class="group p-6 bg-slate-50 border border-slate-100 rounded-[2rem] hover:bg-primary hover:border-primary transition-all duration-500 flex items-center gap-6">
              <div class="w-14 h-14 rounded-2xl bg-white shadow-sm flex items-center justify-center text-primary group-hover:scale-110 transition-transform">
                <i :class="info.icon" class="text-xl"></i>
              </div>
              <div>
                <p class="text-[10px] font-black uppercase tracking-widest text-slate-400 group-hover:text-white/60 mb-1">{{ info.label }}</p>
                <p class="text-md font-bold text-slate-800 group-hover:text-white">{{ info.value }}</p>
              </div>
            </div>
          </div>

          <div class="p-6 rounded-[2rem] bg-slate-900 text-white relative overflow-hidden">
            <div class="absolute top-0 right-0 p-4">
              <span class="relative flex h-3 w-3">
                <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                <span class="relative inline-flex rounded-full h-3 w-3 bg-green-500"></span>
              </span>
            </div>
            <p class="text-[10px] font-black uppercase tracking-[0.2em] text-white/40 mb-2">Assessment Server Status</p>
            <p class="text-sm font-bold">All Evaluation Nodes Operational (99.9%)</p>
          </div>
        </div>

        <div class="lg:col-span-7">
          <div class="bg-white rounded-[3rem] p-10 md:p-16 shadow-[0_32px_64px_-16px_rgba(0,0,0,0.08)] border border-slate-100 relative">
            <div class="absolute -top-6 -right-6 w-24 h-24 bg-secondary rounded-3xl -rotate-12 -z-10 opacity-20"></div>
            
            <form @submit.prevent="submitForm" class="space-y-10">
              <div class="grid grid-cols-1 md:grid-cols-2 gap-10">
                <div class="space-y-2">
                  <label class="text-[10px] font-black uppercase tracking-widest text-slate-400 ml-1">Organization / School</label>
                  <input type="text" v-model="form.org_name" required placeholder="Academy Name or PLC" 
                    class="w-full bg-slate-50 border-none rounded-2xl px-6 py-4 outline-none focus:ring-2 focus:ring-primary/20 transition-all font-bold text-slate-800 placeholder:text-slate-300" />
                </div>
                <div class="space-y-2">
                  <label class="text-[10px] font-black uppercase tracking-widest text-slate-400 ml-1">Official Email</label>
                  <input type="email" v-model="form.email" required placeholder="hr@institution.com" 
                    class="w-full bg-slate-50 border-none rounded-2xl px-6 py-4 outline-none focus:ring-2 focus:ring-primary/20 transition-all font-bold text-slate-800 placeholder:text-slate-300" />
                </div>
              </div>

              <div class="space-y-2">
                <label class="text-[10px] font-black uppercase tracking-widest text-slate-400 ml-1">Inquiry Purpose</label>
                <select v-model="form.subject" class="w-full bg-slate-50 border-none rounded-2xl px-6 py-4 outline-none focus:ring-2 focus:ring-primary/20 transition-all font-bold text-slate-800">
                  <option value="student">Student Aptitude Testing</option>
                  <option value="corporate">Corporate Behavioral Audit</option>
                  <option value="bespoke">Bespoke Test Development</option>
                  <option value="demo">Platform Demo Request</option>
                </select>
              </div>

              <div class="space-y-2">
                <label class="text-[10px] font-black uppercase tracking-widest text-slate-400 ml-1">Evaluation Details</label>
                <textarea v-model="form.message" rows="4" placeholder="How many participants are you looking to evaluate?" 
                  class="w-full bg-slate-50 border-none rounded-2xl px-6 py-4 outline-none focus:ring-2 focus:ring-primary/20 transition-all font-bold text-slate-800 resize-none placeholder:text-slate-300"></textarea>
              </div>

              <button
                type="submit"
                :disabled="loading"
                class="w-full bg-primary hover:bg-slate-900 text-white py-6 rounded-[2rem] font-black text-xs uppercase tracking-[0.4em] transition-all duration-500 shadow-2xl shadow-primary/30 flex items-center justify-center gap-4 group"
              >
                {{ loading ? 'Processing Request...' : 'Get Your Assessment Plan' }}
                <i class="fas fa-arrow-right group-hover:translate-x-2 transition-transform"></i>
              </button>
            </form>
          </div>
        </div>

      </div>
    </div>
  </section>
</template>

<script>
export default {
  data() {
    return {
      loading: false,
      contactInfo: [
        { label: 'Regional HQ', value: 'Bole Area, Addis Ababa, Ethiopia', icon: 'fas fa-map-marker-alt' },
        { label: 'Expert Support', value: 'consult@alpha-psych.com', icon: 'fas fa-user-tie' },
        { label: 'Partnerships', value: '+251 911 00 11 22', icon: 'fas fa-handshake' },
      ],
      form: {
        org_name: "",
        email: "",
        subject: "student",
        message: "",
      },
    };
  },
  methods: {
    async submitForm() {
      this.loading = true;
      // Simulated Submission Logic
      setTimeout(() => {
        alert("Request Received. An industrial psychologist will contact your team within 24 hours.");
        this.loading = false;
        this.form = { org_name: "", email: "", subject: "student", message: "" };
      }, 1500);
    }
  }
};
</script>

<style scoped>
input, select, textarea {
  box-shadow: inset 0 2px 4px 0 rgba(0, 0, 0, 0.02);
}
</style>