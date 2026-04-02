<template>
  <transition name="modal-fade">
    <div
      v-if="visible"
      class="fixed inset-0 z-[100] flex items-center justify-center p-4 backdrop-blur-sm bg-slate-900/60"
      @click.self="$emit('close')"
    >
      <div
        class="bg-white w-full max-w-2xl rounded-[2.5rem] shadow-2xl relative overflow-hidden flex flex-col max-h-[90vh] animate-slide-up"
      >
        <div class="h-2 w-full bg-gradient-to-r from-primary via-secondary to-dprimary"></div>

        <div class="p-8 pb-4 flex justify-between items-center bg-white z-10">
          <div>
            <h2 class="text-3xl font-black text-slate-900 tracking-tight">
              Create <span class="text-primary italic">Account</span>
            </h2>
            <p class="text-xs font-bold text-slate-400 uppercase tracking-widest mt-1">
              Join the Alpha Property Network
            </p>
          </div>
          <button
            @click="$emit('close')"
            class="w-10 h-10 rounded-full bg-slate-50 text-slate-400 hover:bg-red-50 hover:text-red-500 transition-all flex items-center justify-center group"
          >
            <i class="fas fa-times group-hover:rotate-90 transition-transform"></i>
          </button>
        </div>

        <div class="flex-1 overflow-y-auto custom-scrollbar p-8 pt-2">
          <form @submit.prevent="submitForm" class="space-y-6">
            
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <div class="relative group">
                <input v-model="form.first_name" required placeholder=" " class="peer floating-input" />
                <label class="floating-label">First Name</label>
              </div>
              <div class="relative group">
                <input v-model="form.middle_name" placeholder=" " class="peer floating-input" />
                <label class="floating-label">Middle Name</label>
              </div>
              <div class="sm:col-span-2 relative group">
                <input v-model="form.last_name" required placeholder=" " class="peer floating-input" />
                <label class="floating-label">Last Name (Family Name)</label>
              </div>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 pt-4">
              <div class="relative group">
                <input v-model="form.email" type="email" required placeholder=" " 
                  class="peer floating-input" :class="{'border-red-400': emailExistsError}" />
                <label class="floating-label">Email Address</label>
                <p v-if="emailExistsError" class="text-[10px] font-bold text-red-500 mt-1 uppercase">{{ emailExistsError }}</p>
              </div>
              <div class="relative group">
                <input v-model="form.phone_number" type="tel" placeholder=" " class="peer floating-input" />
                <label class="floating-label">Phone Number</label>
              </div>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 pt-4">
              <div class="relative group">
                <input v-model="form.password" type="password" required placeholder=" " class="peer floating-input" />
                <label class="floating-label">Password</label>
              </div>
              <div class="relative group">
                <input v-model="form.confirmPassword" type="password" required placeholder=" " 
                  class="peer floating-input" :class="{'border-red-400': passwordMismatch}" />
                <label class="floating-label">Confirm Password</label>
                <p v-if="passwordMismatch" class="text-[10px] font-bold text-red-500 mt-1 uppercase">Mismatch detected</p>
              </div>
            </div>

            <div class="bg-slate-50 rounded-3xl p-6 grid grid-cols-1 sm:grid-cols-2 gap-6">
              <div class="space-y-2">
                <label class="text-[10px] font-black uppercase tracking-widest text-slate-400 ml-1">Membership Start</label>
                <input v-model="form.start_date" type="date" class="date-input" />
              </div>
              <div class="space-y-2">
                <label class="text-[10px] font-black uppercase tracking-widest text-slate-400 ml-1">Membership End</label>
                <input v-model="form.end_date" type="date" class="date-input" />
              </div>
            </div>
          </form>
        </div>

        <div class="p-8 bg-white border-t border-slate-50 flex flex-col sm:flex-row items-center justify-between gap-4">
          <p class="text-[10px] text-slate-400 font-bold uppercase tracking-widest text-center sm:text-left">
            Secured by <span class="text-primary">Alpha Encryption</span>
          </p>
          <button
            @click="submitForm"
            class="w-full sm:w-auto bg-slate-900 hover:bg-primary text-white px-10 py-4 rounded-2xl font-black text-xs uppercase tracking-[0.2em] shadow-xl shadow-slate-200 transition-all active:scale-95"
          >
            Complete Registration
          </button>
        </div>
      </div>
    </div>
  </transition>
</template>

<style scoped>
/* Scrollbar Management */
.custom-scrollbar::-webkit-scrollbar {
  width: 6px;
}
.custom-scrollbar::-webkit-scrollbar-track {
  background: transparent;
}
.custom-scrollbar::-webkit-scrollbar-thumb {
  background: #e2e8f0;
  border-radius: 10px;
}
.custom-scrollbar::-webkit-scrollbar-thumb:hover {
  background: var(--color-primary, #fbbf24);
}

/* Floating Input Logic */
.floating-input {
  @apply w-full bg-transparent border-b-2 border-slate-100 py-3 outline-none focus:border-primary transition-all font-bold text-slate-800 text-sm;
}
.floating-label {
  @apply absolute left-0 top-3 text-slate-300 font-black text-[10px] uppercase tracking-widest transition-all pointer-events-none;
}
.floating-input:focus ~ .floating-label,
.floating-input:not(:placeholder-shown) ~ .floating-label {
  @apply -top-4 text-primary text-[9px];
}

/* Date Input Styles */
.date-input {
  @apply w-full bg-white border border-slate-200 rounded-xl px-4 py-3 text-sm font-bold text-slate-700 focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all;
}

/* Animations */
.animate-slide-up {
  animation: slideUp 0.5s cubic-bezier(0.16, 1, 0.3, 1);
}
@keyframes slideUp {
  from { opacity: 0; transform: translateY(40px); }
  to { opacity: 1; transform: translateY(0); }
}

.modal-fade-enter-active, .modal-fade-leave-active {
  transition: opacity 0.3s ease;
}
.modal-fade-enter-from, .modal-fade-leave-to {
  opacity: 0;
}
</style>

<script>
import axios from "axios";

export default {
  props: {
    visible: Boolean,
    selectedPlan: Number,
  },
  data() {
    return {
      form: {
        plan: this.selectedPlan || null,
        first_name: "",
        middle_name: "",
        last_name: "",
        email: "",
        phone_number: "",
        start_date: "",
        end_date: "",
        password: "",
        confirmPassword: "",
      },
      passwordMismatch: false,
      emailExistsError: "",
    };
  },
  watch: {
    selectedPlan(newVal) {
      this.form.plan = newVal;
    },
  },
  methods: {
    async submitForm() {
      this.passwordMismatch = false;
      this.emailExistsError = "";
      // Validate password confirmation
      if (this.form.password !== this.form.confirmPassword) {
        this.passwordMismatch = true;
        return;
      }
      try {
        // Prepare payload
        const payload = { ...this.form };
        delete payload.confirmPassword; // don't send confirmPassword to backend

        // Axios POST request to registration API
        const response = await axios.post(
          "https://alphapms.sunriseworld.org/api/sign_up",
          payload
        );
        console.log("User registered successfully:", response);
        // Optionally send password reset email
        if (response) {
          this.$router.push('/email-activate-message')
          // const resetPayload = { email: this.form.email };
          // const resetResponse = await axios.post(
          //   "https://alphapms.sunriseworld.org/api/send_password_reset_email",
          //   resetPayload
          // );
          // console.log("Password reset email sent:", resetResponse.data);

          // if(resetResponse){
          //   this.$router.push('/email-activate-mail')
          // }
        }
        // Close modal
        //this.$emit("close");
      } catch (error) {
        // Handle errors
        const errorMsg = error.response?.data?.error;

        if (errorMsg === "This email already exists in the system") {
          this.emailExistsError = errorMsg;
        } else {
          this.emailExistsError = "";
          alert(errorMsg || "Registration failed.");
        }
      }
    },
  },
};
</script>


