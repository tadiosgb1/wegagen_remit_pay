<template>
  <section class="py-24 bg-slate-50 relative overflow-hidden">
    <div class="absolute top-0 right-0 w-1/3 h-1/3 bg-primary/5 rounded-full blur-[120px] -z-10"></div>
    <div class="absolute bottom-0 left-0 w-1/4 h-1/4 bg-secondary/5 rounded-full blur-[100px] -z-10"></div>

    <div class="max-w-7xl mx-auto px-6">
      
      <div class="flex flex-col md:flex-row md:items-end justify-between mb-12 gap-6">
        <div class="max-w-xl text-left">
          <span class="inline-block px-4 py-1.5 mb-4 text-[10px] font-black tracking-[0.2em] text-primary bg-primary/10 rounded-full uppercase">
            Marketplace
          </span>
          <h2 class="text-4xl font-black text-slate-900 tracking-tight leading-none mb-4">
            Explore <span class="text-primary italic">Properties</span>
          </h2>
          <p class="text-slate-500 font-medium">
            Discover premier residential and commercial spaces across Ethiopia's growing urban centers.
          </p>
        </div>

        <div class="relative w-full md:w-96 group">
          <input
            v-model="searchQuery"
            @input="filterByLocation"
            type="text"
            placeholder="Search city or neighborhood..."
            class="w-full bg-white border border-slate-200 rounded-2xl px-6 py-4 shadow-sm group-hover:shadow-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all pl-14 font-medium text-slate-700"
            list="cityList"
          />
          <i class="fas fa-location-dot absolute left-6 top-1/2 -translate-y-1/2 text-slate-400 group-hover:text-primary transition-colors"></i>
          <datalist id="cityList">
            <option v-for="city in cities" :key="city" :value="city" />
          </datalist>
        </div>
      </div>

      <div class="flex flex-wrap items-center gap-3 mb-10">
        <button
          v-for="tab in tabs"
          :key="tab.key"
          @click="changeTab(tab.key)"
          class="px-8 py-3 rounded-2xl font-black text-[11px] uppercase tracking-widest transition-all duration-300 transform active:scale-95"
          :class="[
            currentTab === tab.key
              ? 'bg-primary text-white shadow-xl shadow-primary/20'
              : 'bg-white text-slate-500 border border-slate-100 hover:bg-slate-50 hover:text-slate-900'
          ]"
        >
          {{ tab.label }}
        </button>
      </div>

      <div v-if="loading" class="flex flex-col items-center justify-center py-24 space-y-4">
        <div class="w-12 h-12 border-4 border-slate-200 border-t-primary rounded-full animate-spin"></div>
        <span class="text-xs font-black uppercase tracking-widest text-slate-400">Syncing database...</span>
      </div>

      <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
        <div
          v-for="item in filteredItems"
          :key="item.id"
          class="group bg-white rounded-[2rem] border border-slate-100 transition-all duration-500 hover:shadow-2xl hover:shadow-slate-200/50 overflow-hidden flex flex-col"
        >
          <div class="relative w-full aspect-[4/3] overflow-hidden">
            <img
              v-if="getImageCount(item) > 0"
              :src="getCurrentImage(item)"
              class="w-full h-full object-cover cursor-pointer group-hover:scale-110 transition-transform duration-700"
              @click="openZoom(item)"
            />
            <div v-else class="w-full h-full bg-slate-100 flex items-center justify-center text-slate-300">
               <i class="fas fa-image text-4xl"></i>
            </div>

            <div class="absolute top-4 left-4 z-10">
              <span class="bg-white/90 backdrop-blur-md text-slate-900 px-4 py-2 rounded-xl text-sm font-black shadow-sm">
                 {{ item.price || item.price_monthly || 'Contact' }} <span class="text-[10px] text-slate-400 ml-1">ETB</span>
              </span>
            </div>

            <div v-if="getImageCount(item) > 1" class="absolute inset-x-4 top-1/2 -translate-y-1/2 flex justify-between opacity-0 group-hover:opacity-100 transition-opacity duration-300">
              <button @click.stop="prevImage(item)" class="w-8 h-8 rounded-full bg-white/90 backdrop-blur-md flex items-center justify-center hover:bg-primary hover:text-white transition-all shadow-lg">‹</button>
              <button @click.stop="nextImage(item)" class="w-8 h-8 rounded-full bg-white/90 backdrop-blur-md flex items-center justify-center hover:bg-primary hover:text-white transition-all shadow-lg">›</button>
            </div>

            <div v-if="getImageCount(item) > 1" class="absolute bottom-4 right-4 bg-slate-900/60 backdrop-blur-sm text-[10px] text-white px-3 py-1 rounded-full font-bold">
              {{ item.imageIndex + 1 }} / {{ getImageCount(item) }}
            </div>
          </div>

          <div class="p-8 flex flex-col flex-grow">
            <div class="flex justify-between items-start mb-4">
              <div>
                <h3 class="text-xl font-black text-slate-900 mb-1 group-hover:text-primary transition-colors truncate">{{ item.name }}</h3>
                <p class="text-xs font-bold text-slate-400 uppercase tracking-widest flex items-center gap-1">
                  <i class="fas fa-location-arrow text-[10px]"></i> {{ item.city }}
                </p>
              </div>
            </div>

            <div class="flex items-center gap-4 py-6 border-y border-slate-50 mb-6">
              <template v-if="currentTab !== 'cowork'">
                <div class="flex flex-col items-center gap-1 flex-1 border-r border-slate-100">
                   <span class="text-xs font-black text-slate-900">{{ item.bed_rooms || 0 }}</span>
                   <span class="text-[9px] font-black text-slate-400 uppercase">Beds</span>
                </div>
                <div class="flex flex-col items-center gap-1 flex-1">
                   <span class="text-xs font-black text-slate-900">{{ item.bath_rooms || 0 }}</span>
                   <span class="text-[9px] font-black text-slate-400 uppercase">Baths</span>
                </div>
              </template>
              <template v-else>
                <div class="flex flex-col items-center gap-1 flex-1">
                   <span class="text-xs font-black text-slate-900">{{ item.capacity || 'N/A' }}</span>
                   <span class="text-[9px] font-black text-slate-400 uppercase">Capacity</span>
                </div>
              </template>
            </div>

            <button
              @click="item.showDownload = !item.showDownload"
              class="w-full py-4 rounded-2xl font-black text-xs uppercase tracking-[0.2em] transition-all duration-300 overflow-hidden relative group/btn"
              :class="item.showDownload ? 'bg-secondary text-white' : 'bg-slate-900 text-white hover:bg-primary'"
            >
              <span class="relative z-10">{{ item.showDownload ? 'Download Alpha App' : (currentTab === 'rent' ? 'Rent Now' : 'Inquire Now') }}</span>
            </button>
          </div>
        </div>
      </div>

      <div v-if="!loading && filteredItems.length === 0" class="text-center py-20 bg-white rounded-[3rem] border-2 border-dashed border-slate-100">
        <div class="text-slate-200 mb-4"><i class="fas fa-search text-6xl"></i></div>
        <p class="text-slate-500 font-bold italic">No results found for "{{ searchQuery }}" in {{ currentTabLabel }}.</p>
      </div>

      <div v-if="!loading && (nextPageUrl || prevPageUrl)" class="flex justify-center items-center mt-16 space-x-6">
        <button
          @click="loadPrevious"
          :disabled="!prevPageUrl"
          class="flex items-center gap-2 font-black text-[10px] uppercase tracking-widest text-slate-400 hover:text-primary disabled:opacity-30 transition-colors"
        >
          <i class="fas fa-arrow-left"></i> Previous
        </button>

        <div class="h-8 w-[1px] bg-slate-200"></div>
        <span class="text-[11px] font-black text-slate-900 uppercase tracking-[0.3em]">Page {{ currentPage }} / {{ totalPages }}</span>
        <div class="h-8 w-[1px] bg-slate-200"></div>

        <button
          @click="loadNext"
          :disabled="!nextPageUrl"
          class="flex items-center gap-2 font-black text-[10px] uppercase tracking-widest text-slate-400 hover:text-primary disabled:opacity-30 transition-colors"
        >
          Next <i class="fas fa-arrow-right"></i>
        </button>
      </div>
    </div>
  </section>
</template>

<script>
import axios from 'axios'

export default {
  name: "PropertiesSection",
  data() {
    return {
      tabs: [
        { key: "rent", label: "For Rent" },
        { key: "sale", label: "For Sale" },
        { key: "cowork", label: "Co-working Spaces" },
      ],
      currentTab: "rent",
      items: [],
      filteredItems: [],
      loading: false,
      searchQuery: "",
      currentPage: 1,
      totalPages: 1,
      nextPageUrl: null,
      prevPageUrl: null,
      cities: [
        "Addis Ababa",
        "Adama",
        "Bahir Dar",
        "Dire Dawa",
        "Hawassa",
        "Mekelle",
        "Jimma",
        "Gondar",
        "Harar",
        "Dessie",
      ],
    };
  },
  computed: {
    currentTabLabel() {
      const tab = this.tabs.find((t) => t.key === this.currentTab);
      return tab ? tab.label.toLowerCase() : "";
    },
  },
  mounted() {
    this.fetchData();
  },
  methods: {
    async changeTab(tabKey) {
      if (this.currentTab !== tabKey) {
        this.currentTab = tabKey;
        this.searchQuery = "";
        this.currentPage = 1;
        this.fetchData();
      }
    },

    async fetchData(url = null) {
      try {
        this.loading = true;

        const baseUrl =
          this.currentTab === "cowork"
            ? "https://alphapms.sunriseworld.org/api/get_coworking_spaces"
            : "https://alphapms.sunriseworld.org/api/get_properties";

        const params = {};
        if (this.currentTab === "rent") params.PROPERTY_RENT = "rent" ;
        if (this.currentTab === "sale") params.PROPERTY_SALE = "sale";
        
        params.page_size=3
        const res = await axios.get(url || baseUrl, { params });

        const data = res.data;
        this.items = (data.data || []).map((item) => ({
          ...item,
          imageIndex: 0,
          showDownload: false,
        }));

        this.filteredItems = [...this.items];
        this.currentPage = data.current_page || 1;
        this.totalPages = data.total_pages || 1;
        this.nextPageUrl = data.next;
        this.prevPageUrl = data.previous;
      } catch (error) {
        console.error("Error fetching data:", error);
        this.items = [];
        this.filteredItems = [];
      } finally {
        this.loading = false;
      }
    },

    async loadNext() {
      if (this.nextPageUrl) {
        await this.fetchData(this.nextPageUrl);
      }
    },

    async loadPrevious() {
      if (this.prevPageUrl) {
        await this.fetchData(this.prevPageUrl);
      }
    },

    filterByLocation() {
      const query = this.searchQuery.toLowerCase();
      this.filteredItems = this.items.filter(
        (item) =>
          item.city?.toLowerCase().includes(query) ||
          item.address?.toLowerCase().includes(query) ||
          item.location?.toLowerCase().includes(query)
      );
    },

    getImageCount(item) {
      return item.property_pictures ? item.property_pictures.length : 0;
    },
    getCurrentImage(item) {
      return item.property_pictures && item.property_pictures.length > 0
        ? item.property_pictures[item.imageIndex].property_image
        : null;
    },
    nextImage(item) {
      const pictures = item.property_pictures || [];
      if (pictures.length > 1)
        item.imageIndex = (item.imageIndex + 1) % pictures.length;
    },
    prevImage(item) {
      const pictures = item.property_pictures || [];
      if (pictures.length > 1)
        item.imageIndex = (item.imageIndex - 1 + pictures.length) % pictures.length;
    },
    openZoom(item) {
      console.log("Zoom image for", item.name);
    },
  },
};
</script>

<style scoped>
.container {
  max-width: 1200px;
}
</style>
