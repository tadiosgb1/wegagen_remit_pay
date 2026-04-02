import './style.css';
import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
import store from './store';
import globals from './globals/globals.js';
import './assets/global.css'; // Import the global CSS
import { createI18n } from 'vue-i18n';
import amharicMessages from '../locales/amharic.json';
import englishMessages from '../locales/english.json';
import tigrignaMessages from '../locales/tigrigna.json';
import apiClientPlugin from "./store/plugins/apiClientPlugin";
import './assets/css/darkmode.css'; 
import "animate.css";
import VueParticles from "vue-particles";
//import toast from './components/Common/Toast.vue';
//check
//hii


import VueApexCharts from 'vue3-apexcharts';
const defaultLocale = 'amharic';
const i18n = createI18n({
  locale: defaultLocale, // Set Amharic as the default language
  fallbackLocale: 'english', // Set a fallback language
  messages: {
    amharic: amharicMessages,
    english: englishMessages,
    tigrigna: tigrignaMessages,
  },
});

createApp(App)
  .use(store)
  .use(globals)
  .use(VueApexCharts)
  .use(router)
  .use(i18n)
  .use(VueParticles)
  .use(apiClientPlugin)
  //.use(toast)
  .mount('#app');
