<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-b from-white via-slate-50 to-slate-100 p-6">
    <div class="max-w-lg w-full bg-white/90 backdrop-blur-md shadow-xl rounded-2xl p-10 text-center border border-white/60">
      <div class="flex flex-col items-center">
        <div class="bg-emerald-50 rounded-full p-4 mb-4">
          <svg aria-hidden="true" class="w-10 h-10 text-emerald-600" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M5 13l4 4L19 7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </div>
        <h1 class="text-2xl sm:text-3xl font-semibold text-slate-900">Email Activation Sent</h1>
        <p class="mt-3 text-slate-600 text-sm sm:text-base max-w-md">
          We’ve sent an activation link to your registered email address. Please open your inbox and follow the link to activate your account before signing in.
        </p>
        <p class="mt-2 text-slate-500 text-sm">If you don’t see the email, check your spam or junk folder.</p>

        <div class="mt-8">
          <router-link
            to="/"
            class="inline-block px-6 py-2.5 bg-primary text-white rounded-lg text-sm font-medium hover:bg-orange-700 shadow-md focus:outline-none focus:ring-2 focus:ring-emerald-400 focus:ring-offset-2"
          >
            Go to Login
          </router-link>
        </div>
      </div>

      <footer class="mt-8 text-xs text-slate-400 text-center">
        Use your account professionally and in accordance with our Terms of Service.
      </footer>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EmailActivationNotice'
}
</script>

<style scoped>
</style>
