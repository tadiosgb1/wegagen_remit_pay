<template>
  <div
    class="relative flex justify-center items-center min-h-screen bg-blue-300"
    :style="{
      backgroundImage:
        'url(https://www.transparenttextures.com/patterns/connected.png)',
    }"
  >
    <!-- Top Bar with Logo and Language Dropdown -->
    <div
      class="absolute top-0 left-0 right-0 flex justify-between items-center p-4"
    >
      <!-- Logo -->
      <div class="flex items-center space-x-2 text-white text-xl font-bold">
        <img src="../../../assets/img/logo.jpg" alt="Logo" class="h-12 w-auto rounded-full" />
      </div>

      <!-- Language Dropdown -->
      <div>
        <select
          v-model="selectedLanguage"
          @change="changeLanguage"
          class="px-2 py-1 rounded border text-sm"
        >
          <option value="en">English</option>
          <option value="am">Amharic</option>
          <option value="ti">Tigrigna</option>
        </select>
      </div>
    </div>

    <Toast ref="toast" />

    <!-- Main Reset Password Form -->
    <div class="w-full max-w-md bg-white p-8 rounded-lg shadow-md mt-12">
      <h2 class="text-2xl font-bold text-center text-gray-800 mb-6">
        Reset Your Password
      </h2>
      <form @submit.prevent="submitForm">
        <!-- New Password Field -->
        <div class="mb-4">
          <label
            for="password"
            class="block text-sm font-semibold text-gray-700 mb-2"
          >
            New Password
          </label>
          <input
            type="password"
            id="password"
            v-model="password"
            required
            placeholder="Enter your new password"
            class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-600 focus:border-transparent"
          />
          <p v-if="passwordError" class="text-xs text-red-600 mt-1">
            {{ passwordError }}
          </p>
        </div>

        <!-- Confirm Password Field -->
        <div class="mb-4">
          <label
            for="confirmPassword"
            class="block text-sm font-semibold text-gray-700 mb-2"
          >
            Confirm Password
          </label>
          <input
            type="password"
            id="confirmPassword"
            v-model="confirmPassword"
            required
            placeholder="Confirm your new password"
            class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-600 focus:border-transparent"
          />
          <p v-if="confirmPasswordError" class="text-xs text-red-600 mt-1">
            {{ confirmPasswordError }}
          </p>
        </div>

        <!-- Response Message -->
        <div
          v-if="message"
          :class="messageType"
          class="text-center text-sm mt-4"
        >
          <p>{{ message }}</p>
        </div>

        <!-- Submit Button -->
        <div class="flex items-center justify-between mt-4">
          <button
            type="submit"
            class="w-full bg-indigo-600 text-white py-2 px-4 rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-600"
          >
            <i class="fas fa-lock mr-2"></i> Reset Password
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import Toast from "../../../components/Toast.vue";

export default {
  components: {
    Toast,
  },
  data() {
    return {
      password: "",
      confirmPassword: "",
      passwordError: "",
      confirmPasswordError: "",
      message: "",
      messageType: "text-green-600",
      token: this.$route.params.token,
    };
  },
  methods: {
    validatePasswordStrength(password) {
      const regex =
        /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]).{8,}$/;
      return regex.test(password);
    },
    async submitForm() {
      this.passwordError = "";
      this.confirmPasswordError = "";
      this.message = "";

      if (!this.password) {
        this.passwordError = "Password is required.";
      } else if (!this.validatePasswordStrength(this.password)) {
        this.passwordError =
          "Password must include digit, lowercase, uppercase, special character, and be at least 8 characters.";
      }

      if (this.password !== this.confirmPassword) {
        this.confirmPasswordError = "Passwords do not match.";
      }

      if (this.passwordError || this.confirmPasswordError) return;

      const payload = {
        password: this.password,
        token: this.token,
      };

      try {
        const response = await this.$apiPost("/auth/reset", payload);
        this.$refs.toast.showSuccessToastMessage(response.message);
        setTimeout(() => {
          this.$router.push("/login");
        }, 3000);
      } catch (error) {
        console.log("reset error", error);
        this.message = error.response?.data?.message || "Something went wrong!";
        this.messageType = "text-red-600";
      }
    },
  },
};
</script>

<style scoped>
/* Additional custom styles if needed */
</style>
