<template>
  <div class="min-h-screen bg-slate-50 font-sans selection:bg-primary/30">
    <section id="home">
     <Header />
    </section>

     <Hero />
    
    <div class="bg-white py-20">
      <div class="max-w-7xl mx-auto px-6 grid md:grid-cols-2 gap-12 items-center">
          <div>
              <span class="text-primary font-black uppercase tracking-widest text-xs">Scientific Precision</span>
              <h2 class="text-4xl font-black text-slate-800 mt-2 mb-6">Psychometric Solutions for Growth</h2>
              <p class="text-slate-600 mb-8 leading-relaxed">
                Empower your organization with data-driven behavioral insights. From <strong>Interactive Assessments</strong> to <strong>Deep Result Analysis</strong>, Alpha provides the tools to test students, employees, or yourself with academic-grade accuracy.
              </p>
              <ul class="space-y-4">
                  <li class="flex items-center gap-3 font-bold text-slate-700"><i class="fas fa-brain text-secondary"></i> Interactive Assessment Engine</li>
                  <li class="flex items-center gap-3 font-bold text-slate-700"><i class="fas fa-chart-pie text-secondary"></i> Advanced Result Analytics</li>
                  <li class="flex items-center gap-3 font-bold text-slate-700"><i class="fas fa-users text-secondary"></i> Multi-tenant User Management</li>
              </ul>
          </div>
      </div>
    </div>

    <Features id="features" />

    <Fqs />
    <ContactUs />
    <Footer />
  </div>
</template>

<script>
// --- ALL IMPORTS PRESERVED ---
import Header from './header.vue'
import Footer from './footer.vue'
import Hero from './hero.vue'
import Features from './features.vue'
import Fqs from './fqs.vue'
import ContactUs from './contactUs.vue'
import LoginModal from '../auth/login.vue'
import whyAlphaMessage from './whyAlphaMessage.vue'
import secondaryCta from './secondary-cta.vue'
import pricingPreview from './pricing-preview.vue'

export default {
  components: {
    Header,
    Hero,
    Features,
    Fqs,
    ContactUs,
    Footer,
    LoginModal,
    whyAlphaMessage,
    secondaryCta,
    pricingPreview
  },
  data() {
    return {
      showLoginModal: false,
      selectedLang: "en",
      mobileMenuOpen: false,
      selectedPlan: null,
      showForm: true, // Shown for MVP visibility
      form: {
        company_name: '',
        type: 'individual',
        email: '',
        password: '',
        phone_number: ''
      }
    };
  },
  methods: {
    apiDoc(){
      this.$router.push('/assessments');
    },
    onPlanSelected(planId) {
      this.selectedPlan = planId;
      this.showForm = true;
      setTimeout(() => {
        const el = document.getElementById('onboard');
        el?.scrollIntoView({ behavior: 'smooth' });
      }, 100);
    },
    scrollTo(id) {
        const el = document.getElementById(id);
        el?.scrollIntoView({ behavior: 'smooth' });
    },
    async submitForm() {
        console.log("Psychometric Account Registration:", this.form);
        alert("Welcome to Alpha Psychometrics! Setting up your dashboard...");
    }
  }
};
</script>

<style scoped>
.custom-input {
  @apply w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3.5 text-sm font-semibold text-slate-700 
         transition-all outline-none focus:border-primary focus:ring-4 focus:ring-primary/10 placeholder:text-slate-300;
}
</style>