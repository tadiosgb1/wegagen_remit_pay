<template>
  <div class="relative min-h-screen bg-gray-200">
    <!-- Forgot Password Form -->
    <div v-if="showForm" class="flex justify-center items-center min-h-screen">
      <Toast ref="toast" />
      <div class="w-full max-w-md bg-white p-8 rounded-lg shadow-md">
        <h2 class="text-2xl font-bold text-center text-gray-800 mb-6">
          Forgot Password
        </h2>
        <form @submit.prevent="submitForm">
          <div class="mb-4">
            <label
              for="email"
              class="block text-sm font-semibold text-gray-700 mb-2"
              >Email Address</label
            >
            <input
              type="email"
              id="email"
              v-model="email"
              required
              placeholder="Enter your email"
              class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-600 focus:border-transparent"
            />
          </div>
          <div class="flex items-center justify-between mb-4">
            <button
              type="submit"
              :disabled="loading"
              class="w-full bg-primary text-white py-2 px-4 rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-primary disabled:opacity-60"
            >
              <i v-if="!loading" class="fas fa-envelope mr-2"></i>
              <span v-if="loading">Sending...</span>
              <span v-else>Send Reset Link</span>
            </button>
          </div>
          <div
            v-if="message"
            :class="messageType"
            class="text-center text-sm mt-4"
          >
            <p>{{ message }}</p>
          </div>
        </form>
        <div class="mt-6 text-center">
          <p class="text-sm text-gray-600">
            Remember your password?
            <router-link
              to="/"
              class="text-indigo-600 hover:text-indigo-800"
              >Back to Home</router-link
            >
          </p>
        </div>
      </div>
    </div>

    <!-- Reset Info Message -->
    <div
      v-if="showRestInfo"
      class="flex justify-center items-center min-h-screen px-4"
    >
      <div
        class="max-w-xl w-full p-6 bg-white border-l-4 border-primary shadow-md rounded-md"
      >
        <div class="flex items-start space-x-4">
          <div class="text-primary text-2xl mt-1">
            <i class="fas fa-envelope-open-text"></i>
          </div>
          <div>
            <h3 class="text-lg font-semibold text-gray-800 mb-1">
              Reset Link Sent
            </h3>
            <p class="text-sm text-gray-600">
              We've sent a secure password reset link to your email address.
              Please check your
              <span class="text-blue-600 font-bold">inbox </span>and follow the
              instructions. If you don’t see the email, check your
              <span class="text-pink-400 font-bold">spam or junk</span> folder.
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import Toast from "../../../components/Toast.vue";

export default {
  components: { Toast },
  data() {
    return {
      showForm: true,
      showRestInfo: false,
      email: "",
      message: "",
      messageType: "text-green-600",
      loading: false,
    };
  },
  methods: {
    async submitForm() {
      this.loading = true;
      this.message = "";

      try {
        const response = await axios.post(
          "https://alphapms.sunriseworld.org/api/send_password_reset_email",
          { email: this.email }
        );

        this.showForm = false;
        this.showRestInfo = true;
        this.$refs.toast.showSuccessToastMessage(response.data.message);
      } catch (error) {
        this.message =
          error.response?.data.message || "Something went wrong!";
        this.messageType = "text-red-600";
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>
