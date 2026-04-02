<template>
  <div>
    <transition name="slide">
      <aside
        class="w-72 flex flex-col fixed md:relative z-15 h-full transition-all duration-300 bg-white border-r border-slate-100 custom-scrollbar shadow-sm"
      >
        <!-- Sidebar Header -->
        <div
          v-if="showTitle"
          class="flex flex-row items-center space-x-4 p-5 font-black text-xl text-white bg-primary sticky top-0 z-20 shadow-lg"
        >
          <div class="w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-md">
            <img src="../../assets/img/logo1.jpg" alt="Logo" class="h-7 w-7 rounded-lg" />
          </div>
          <p class="tracking-tighter">Alpha GYZ</p>
        </div>

        <!-- Menu Items -->
        <div class="flex-1 overflow-y-auto custom-scrollbar pt-6">
          <div v-for="(group, gIndex) in groupedMenu" :key="gIndex" class="mb-8 px-4">
            <p class="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 mb-4 px-4">
              {{ group.title }}
            </p>

            <ul class="space-y-1.5">
             <li 
  v-for="item in group.items" 
  :key="item.route" 
  v-if="!item?.permission || $hasPermission(item?.permission)"
>
  <router-link
    :to="{ name: item.route }"
    class="group flex items-center px-4 py-3 rounded-2xl text-sm font-bold transition-all duration-200 relative overflow-hidden"
    :class="[
      $route.name === item.route
        ? 'bg-primary text-white shadow-xl shadow-primary/25'
        : 'text-slate-500 hover:bg-slate-50 hover:text-primary'
    ]"
  >
    <i
      :class="[
        item.icon,
        'w-6 text-lg mr-3 transition-transform duration-300 group-hover:scale-110',
        $route.name === item.route ? 'text-white' : 'text-slate-400 group-hover:text-primary'
      ]"
    ></i>
    <span class="whitespace-nowrap tracking-tight">{{ item.name }}</span>
    <div
      v-if="$route.name === item.route"
      class="absolute right-0 w-1.5 h-6 bg-white/40 rounded-l-full animate-pulse"
    ></div>
  </router-link>
</li>
            </ul>
          </div>
          <div class="h-10"></div>
        </div>
      </aside>
    </transition>
  </div>
</template>

<script>
export default {
  data() {
    return {
      showTitle: true,
      is_superuser: false,
      menuItems: [
        { name: "Dashboard", route: "first-dash", icon: "fas fa-chart-line" },
        { name: "Users", route: "Users-view", icon: "fas fa-user", permission: "" },
        { name: "Roles", route: "Role-view", icon: "fas fa-id-badge", permission: "" },
        { name: "Permissions", route: "Permission-view", icon: "fas fa-key", permission: "" },
          ],
    };
  },
  computed: {
    filteredMenuItems() {

      return this.menuItems.filter(item => {
        if (item.permission) return this.$hasPermission(item.permission);
        return true;
      });
    },
    groupedMenu() {
      const groups = {};
      this.filteredMenuItems.forEach(item => {
        const cat = item.category || "General";
        if (!groups[cat]) groups[cat] = [];
        groups[cat].push(item);
      });
      return Object.keys(groups).map(key => ({ title: key, items: groups[key] }));
    },
  },
  mounted() {
    this.is_superuser = localStorage.getItem("is_superuser") === "true";
    this.showTitle = window.innerWidth < 1024;
  },
};
</script>

<style scoped>
.slide-enter-active,
.slide-leave-active {
  transition: transform 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}
.slide-enter-from,
.slide-leave-to {
  transform: translateX(-100%);
}
.custom-scrollbar::-webkit-scrollbar {
  width: 4px;
}
.custom-scrollbar::-webkit-scrollbar-thumb {
  background: #f1f5f9;
  border-radius: 10px;
}
</style>