<template>
  <div class="flex items-center justify-center min-h-screen bg-gray-100">
    <div class="w-full max-w-md bg-white shadow-lg rounded-xl p-8">
      <h1 class="text-2xl font-bold text-center mb-6">Reset Password</h1>

      <form @submit.prevent="submitForm" class="space-y-4">
        <!-- Hidden Token -->
        <input type="hidden" :value="token" />

        <!-- New Password -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">New Password</label>
          <input
            type="password"
            v-model="password"
            required
            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:outline-none"
          />
        </div>

        <!-- Confirm Password -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Confirm Password</label>
          <input
            type="password"
            v-model="confirmPassword"
            required
            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:outline-none"
          />
        </div>

        <!-- Submit Button -->
        <button
          type="submit"
          :disabled="loading"
          class="w-full bg-primary text-white py-2 px-4 rounded-lg hover:bg-blue-700 transition font-medium disabled:opacity-60"
        >
          <span v-if="loading">Changing...</span>
          <span v-else>Change Password</span>
        </button>
      </form>

      <!-- Back to Home link after success -->
      <div v-if="success" class="text-center mt-6">
        <router-link to="/" class="text-blue-600 hover:underline">
          Go to Home
        </router-link>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";

export default {
  props: ["lang"],
  data() {
    return {
      token: "",
      password: "",
      confirmPassword: "",
      loading: false,
      success: false,
    };
  },
  mounted() {
    // Get token from ?token=... query param
    this.token = this.$route.query.token || "";

    // If not found, fallback to entire query string
    if (!this.token) {
      const query = this.$route.fullPath.split("?")[1];
      this.token = query || "";
    }

    console.log("Lang:", this.lang);
    console.log("Token:", this.token);
  },
  methods: {
    async submitForm() {
      if (this.password !== this.confirmPassword) {
        this.$root.$refs.toast.showToast("Passwords do not match", "error");
        return;
      }

      if (!this.token) {
        this.$root.$refs.toast.showToast("Invalid or missing token", "error");
        return;
      }

      this.loading = true;

      try {
        const payload = { password: this.password };

        const res = await axios.post(
          `https://alphapms.sunriseworld.org/api/reset_password/${this.token}`,
          payload
        );

        if (res.data && res.data.message) {
          this.$root.$refs.toast.showToast(
            res.data.message || "Password changed successfully!",
            "success"
          );
          this.success = true;
          this.password = "";
          this.confirmPassword = "";
        } else {
          this.$root.$refs.toast.showToast(
            res.data?.error || "Failed to reset password",
            "error"
          );
        }
      } catch (err) {
        this.$root.$refs.toast.showToast(
          err.response?.data?.message || "Server error. Please try again.",
          "error"
        );
        console.error("Reset password error:", err);
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>
