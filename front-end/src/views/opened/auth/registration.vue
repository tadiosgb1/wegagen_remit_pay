<template>
  <div class="min-h-screen flex items-center justify-center bg-slate-50 p-6">
    <Toast ref="toast" />

    <div class="w-full max-w-3xl bg-white rounded-[3rem] shadow-2xl shadow-slate-200/60 p-10 border border-slate-100 relative overflow-hidden">

      <!-- Top Accent -->
      <div class="absolute top-0 left-0 w-full h-2 bg-gradient-to-r from-primary via-primary-dense to-secondary"></div>

      <!-- Header -->
      <div class="mb-8 text-center">
        <h2 class="text-3xl font-black text-slate-900">Create Account</h2>
        <p class="text-slate-400 text-sm font-bold uppercase tracking-widest mt-2">
          Psychometric Access Portal
        </p>
      </div>

      <!-- Account Type Switch -->
      <div class="flex bg-slate-100 rounded-2xl p-1 mb-8">
        <button
          @click="accountType = 'individual'"
          :class="accountType === 'individual' ? activeTab : inactiveTab"
        >
          Individual
        </button>
        <button
          @click="accountType = 'organization'"
          :class="accountType === 'organization' ? activeTab : inactiveTab"
        >
          Organization
        </button>
      </div>

      <!-- FORM -->
      <form @submit.prevent="register" class="space-y-8">

        <!-- ================= INDIVIDUAL ================= -->
        <template v-if="accountType === 'individual'">
          <div class="space-y-4">
            <h3 class="section-title">Personal Information</h3>

            <div>
              <label class="custom-label">First Name</label>
              <input v-model="form.first_name" required class="input" />
            </div>

            <div>
              <label class="custom-label">Middle Name</label>
              <input v-model="form.middle_name" class="input" />
            </div>

            <div>
              <label class="custom-label">Last Name</label>
              <input v-model="form.last_name" required class="input" />
            </div>

            <div>
              <label class="custom-label">Email</label>
              <input v-model="form.email" type="email" required class="input" />
            </div>

            <div>
              <label class="custom-label">Phone</label>
              <input v-model="form.phone" class="input" />
            </div>

            <div>
              <label class="custom-label">Password</label>
              <input v-model="form.password" type="password" required class="input" />
            </div>

            <div>
              <label class="custom-label">Confirm Password</label>
              <input v-model="form.confirm_password" type="password" required class="input" />
            </div>
          </div>
        </template>

        <!-- ================= ORGANIZATION ================= -->
        <template v-if="accountType === 'organization'">

          <!-- 👤 ADMIN USER -->
          <div class="border rounded-2xl p-6 space-y-4">
            <h3 class="section-title">Organization Administrator</h3>
            <p class="text-xs text-slate-400 font-semibold">
              This user will manage the organization and invite others.
            </p>

            <div>
              <label class="custom-label">First Name</label>
              <input v-model="form.first_name" required class="input" />
            </div>

            <div>
              <label class="custom-label">Middle Name</label>
              <input v-model="form.middle_name" class="input" />
            </div>

            <div>
              <label class="custom-label">Last Name</label>
              <input v-model="form.last_name" required class="input" />
            </div>

            <div>
              <label class="custom-label">Admin Email (Login)</label>
              <input v-model="form.email" type="email" required class="input" />
            </div>

            <div>
              <label class="custom-label">Phone</label>
              <input v-model="form.phone" class="input" />
            </div>

            <div>
              <label class="custom-label">Password</label>
              <input v-model="form.password" type="password" required class="input" />
            </div>

            <div>
              <label class="custom-label">Confirm Password</label>
              <input v-model="form.confirm_password" type="password" required class="input" />
            </div>
          </div>

          <!-- 🏢 ORGANIZATION INFO -->
          <div class="border rounded-2xl p-6 space-y-4">
            <h3 class="section-title">Organization Details</h3>

            <div>
              <label class="custom-label">Organization Name</label>
              <input v-model="form.org_name" required class="input" />
            </div>

            <div>
              <label class="custom-label">Official Email</label>
              <input v-model="form.org_email" type="email" class="input" />
            </div>

            <div>
              <label class="custom-label">Official Phone</label>
              <input v-model="form.org_phone" class="input" />
            </div>
           <div>
              <label class="custom-label">Address</label>
              <input v-model="form.address" class="input" />
            </div>
            <div>
              <label class="custom-label">Organization Type</label>
              <select v-model="form.org_type" class="input">
                <option>Company</option>
                <option>University</option>
                <option>School</option>
                <option>NGO</option>
              </select>
            </div>

          

            <div>
              <label class="custom-label">Description</label>
              <textarea v-model="form.description" class="input h-24"></textarea>
            </div>
          </div>

        </template>

        <!-- ERROR -->
        <div v-if="error" class="error-box">
          {{ error }}
        </div>

        <!-- SUBMIT -->
        <button type="submit" :disabled="loading" class="submit-btn">
          <span v-if="!loading">Create Account</span>
          <span v-else>Processing...</span>
        </button>

      </form>

      <!-- Footer -->
      <div class="mt-8 text-center">
        <p class="text-xs text-slate-400 font-bold uppercase">
          Already have access?
          <router-link to="/login" class="text-primary ml-1">
            Login
          </router-link>
        </p>
      </div>

    </div>
  </div>
</template>

<script>
import Toast from "../../../components/Toast.vue";

export default {
  name: "RegisterAlphaPsych",
  components: { Toast },

  data() {
    return {
      accountType: "individual",
      loading: false,
      error: "",

      form: {
        // USER
        first_name: "",
        middle_name: "",
        last_name: "",
        email: "",
        phone: "",
        password: "",
        confirm_password: "",

        // ORGANIZATION
        org_name: "",
        org_email: "",
        org_phone: "",
        org_type: "Company",
        address:"",
        description: "",
      },
    };
  },

  computed: {
    activeTab() {
      return "w-1/2 py-3 rounded-xl bg-white shadow font-bold text-xs uppercase";
    },
    inactiveTab() {
      return "w-1/2 py-3 rounded-xl text-slate-400 font-bold text-xs uppercase";
    },
  },

  methods: {
    async register() {
      this.error = "";

      if (this.form.password !== this.form.confirm_password) {
        this.error = "Passwords do not match.";
        return;
      }

      this.loading = true;

      try {
        const endpoint =
          this.accountType === "individual"
            ? "/auth/register"
            : "/organization";

        const payload =
          this.accountType === "individual"
            ? {
                first_name: this.form.first_name,
                middle_name: this.form.middle_name,
                last_name: this.form.last_name,
                email: this.form.email,
                phone: this.form.phone,
                password: this.form.password,
              }
            : {
                user: {
                  first_name: this.form.first_name,
                  middle_name: this.form.middle_name,
                  last_name: this.form.last_name,
                  email: this.form.email,
                  phone: this.form.phone,
                  password: this.form.password,
                },
                organization: {
                  name: this.form.org_name,
                  official_email: this.form.org_email,
                  address:this.form.address,
                  official_phone: this.form.org_phone,
                  org_type: this.form.org_type,
                  description: this.form.description,
                },
              };

        await this.$apiPost(endpoint, payload);

        this.$refs.toast?.showSuccessToastMessage(
          "Account successfully created."
        );

        setTimeout(() => {
          this.$router.push("/login");
        }, 1200);

      } catch (err) {
        this.error =
          err.response?.data?.detail ||
          err.response?.data?.message ||
          "Registration failed.";
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>

<style scoped>
.section-title {
  @apply text-xs font-black uppercase tracking-widest text-slate-500 mb-2;
}

.input {
  @apply w-full px-4 py-3 bg-white border border-gray-300 rounded-xl
  text-gray-900 text-sm font-bold
  focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary;
}

.custom-label {
  @apply text-[10px] font-black uppercase tracking-widest text-black;
}

.submit-btn {
  @apply w-full bg-slate-900 text-white py-4 rounded-2xl font-black text-xs uppercase tracking-widest;
}

.error-box {
  @apply bg-red-50 text-red-600 p-3 rounded-xl text-xs font-bold;
}

/* Colors */
.bg-primary { background-color: #4F46E5; }
.text-primary { color: #4F46E5; }
.bg-primary-dense { background-color: #3730A3; }
.bg-secondary { background-color: #FF6B00; }
</style>