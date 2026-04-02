<template>
  <div class="p-6 bg-slate-50 min-h-screen font-sans">

    <!-- User Type Selector -->
    <div class="mb-8 flex items-center justify-end gap-4">
      <label class="text-xs font-bold uppercase tracking-wide text-slate-500">Select Dashboard:</label>
      <select v-model="selectedDashboard" class="px-4 py-2 rounded-2xl border border-slate-300 shadow-sm text-sm font-bold focus:outline-none focus:ring-2 focus:ring-primary">
        <option value="super">Super Admin</option>
        <option value="admin">Organization Admin</option>
        <option value="user">Individual User</option>
      </select>
    </div>

    <!-- Dashboard Components -->
    <div>
      <component :is="currentDashboard" />
    </div>

  </div>
</template>

<script>
import SuperDashboard from "./dashboards/superdashboard.vue";
import AdminDashboard from "./dashboards/admindashboard.vue";
import UserDashboard from "./dashboards/userdashboard.vue";

export default {
  name: "FirstDash",
  components: {
    SuperDashboard,
    AdminDashboard,
    UserDashboard,
  },
  data() {
    return {
      selectedDashboard: "super", // default
    };
  },
  computed: {
    currentDashboard() {
      switch (this.selectedDashboard) {
        case "super":
          return "SuperDashboard";
        case "admin":
          return "AdminDashboard";
        case "user":
          return "UserDashboard";
        default:
          return "UserDashboard";
      }
    },
  },
};
</script>

<style scoped>
/* Basic styling for dropdown */
select {
  background-color: #fff;
  color: #1e293b;
  border-radius: 1rem;
  font-weight: bold;
  transition: all 0.3s ease-in-out;
}
select:focus {
  outline: none;
  border-color: #6366f1;
  box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.3);
}
</style>