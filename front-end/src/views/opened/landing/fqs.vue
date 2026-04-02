<template>
  <section id="faq" class="py-32 bg-slate-50 relative overflow-hidden">
    <div class="absolute top-0 right-0 w-1/2 h-full bg-white skew-x-12 translate-x-32 z-0"></div>
    
    <div class="max-w-6xl mx-auto px-6 relative z-10">
      <div class="grid lg:grid-cols-3 gap-16">
        
        <div class="lg:sticky lg:top-32 h-fit">
          <span class="inline-block px-3 py-1 mb-4 text-[11px] font-bold tracking-[0.2em] text-primary bg-primary/10 rounded-md uppercase">
            Platform Support
          </span>
          <h2 class="text-4xl font-black text-slate-900 mb-6 leading-tight">
            Scientific <br/> <span class="text-primary">Reliability</span> FAQ
          </h2>
          <p class="text-slate-500 font-medium mb-8 leading-relaxed">
            Everything you need to know about our assessment engine, result analytics, and proctoring security.
          </p>
          
          <div class="p-6 bg-white rounded-2xl border border-slate-200 shadow-sm">
            <p class="text-sm font-bold text-slate-700 mb-2">Need a custom test?</p>
            <p class="text-xs text-slate-400 mb-4">Our industrial psychologists can help design bespoke assessments for your organization.</p>
            <button class="w-full py-3 bg-slate-900 text-white text-xs font-bold uppercase tracking-widest rounded-xl hover:bg-primary transition-colors">
              Contact Expert
            </button>
          </div>
        </div>

        <div class="lg:col-span-2 space-y-4">
          <transition-group 
            appear
            @before-enter="beforeEnter"
            @enter="enter"
          >
            <div
              v-for="(faq, index) in faqs"
              :key="faq.question"
              :data-index="index"
              class="faq-item group"
            >
              <div 
                class="bg-white border transition-all duration-500 rounded-2xl"
                :class="activeIndex === index ? 'border-primary ring-4 ring-primary/5 shadow-xl' : 'border-slate-200 hover:border-slate-300'"
              >
                <button
                  @click="toggleFaq(index)"
                  class="w-full flex items-center justify-between p-7 text-left outline-none"
                >
                  <span class="text-lg font-bold text-slate-800 group-hover:text-primary transition-colors">
                    {{ faq.question }}
                  </span>
                  <div 
                    class="flex-shrink-0 w-6 h-6 flex items-center justify-center rounded-full transition-transform duration-500"
                    :class="activeIndex === index ? 'rotate-180 bg-primary text-white' : 'bg-slate-100 text-slate-400'"
                  >
                    <i class="fas fa-chevron-down text-[10px]"></i>
                  </div>
                </button>

                <div
                  v-show="activeIndex === index"
                  class="overflow-hidden transition-all duration-500"
                >
                  <div class="px-7 pb-7">
                    <div class="h-px w-12 bg-primary/20 mb-6"></div>
                    <p class="text-slate-600 leading-relaxed font-medium mb-6">
                      {{ faq.answer }}
                    </p>
                    
                    <div class="flex flex-wrap gap-2">
                      <span v-for="tag in faq.tags" :key="tag" class="text-[9px] font-black uppercase tracking-tighter px-2 py-1 bg-slate-100 text-slate-500 rounded">
                        # {{ tag }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </transition-group>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref } from 'vue'
import gsap from 'gsap'

const activeIndex = ref(0)

const toggleFaq = (index) => {
  activeIndex.value = activeIndex.value === index ? null : index
}

// GSAP Stagger Logic Preserved
const beforeEnter = (el) => {
  el.style.opacity = 0
  el.style.transform = 'translateY(30px)'
}

const enter = (el, done) => {
  gsap.to(el, {
    opacity: 1,
    y: 0,
    duration: 0.6,
    delay: el.dataset.index * 0.15,
    onComplete: done
  })
}

// Updated FAQ Content for Alpha Psychometrics
const faqs = [
  {
    question: 'How accurate are the behavioral results?',
    answer: 'Alpha utilizes validated psychometric frameworks (21 Story Points for Result Analysis) to ensure high reliability. Our algorithms are benchmarked against international standards to provide a 98.4% accuracy rate in trait identification.',
    tags: ['Validation', 'Analytics']
  },
  {
    question: 'Can organizations manage multiple candidates at once?',
    answer: 'Yes. Our Admin Dashboard (18 Story Points) is built for scale. HR managers can send bulk invitations, monitor real-time progress, and generate comparative group reports with a single click.',
    tags: ['Bulk-Mgmt', 'Organizations']
  },
  {
    question: 'How do you prevent cheating during assessments?',
    answer: 'Our Secure Proctoring layer (26 Story Points) includes session locking, IP tracking, and behavioral monitoring. If a user attempts to switch tabs or uses unauthorized aids, the system flags the session for review.',
    tags: ['Security', 'Integrity']
  },
  {
    question: 'Are the assessments mobile-friendly?',
    answer: 'Absolutely. The Interactive Assessment engine (31 Story Points) is fully responsive. Participants can take tests on any device—mobile, tablet, or desktop—without losing progress.',
    tags: ['UX', 'Mobile']
  },
  {
    question: 'Can I track long-term growth for students?',
    answer: 'Yes. The Progress Tracking module (13 Story Points) stores historical data, allowing institutions to visualize growth curves and cognitive development over months or years.',
    tags: ['Education', 'History']
  },
  {
    question: 'Is user data encrypted and secure?',
    answer: 'Alpha follows strict data protection protocols. All results and personal information are encrypted at rest and in transit, ensuring that sensitive behavioral data remains private.',
    tags: ['Privacy', 'Encryption']
  }
]
</script>

<style scoped>
.faq-item {
  will-change: transform, opacity;
}

::-webkit-scrollbar {
  width: 4px;
}
::-webkit-scrollbar-thumb {
  background: #e2e8f0;
  border-radius: 10px;
}
</style>