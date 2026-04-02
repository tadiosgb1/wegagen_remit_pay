<template>
  <div class="flex flex-col items-center justify-center h-screen">
    <h1 class="text-4xl font-bold text-red-500">
      403 - Access Denied or Page Not Found
    </h1>
    <p class="text-gray-600 mt-4">
      No such like page accessible for you please!!!
    </p>
    <!-- <button
        class="bg-red-500 hover:bg-red-600 text-white font-bold py-2 px-4 rounded mt-8"
        @click="goBack"
      >
        Go Back
      </button> -->
  </div>
</template>
<!-- ppp -->
<script>
export default {
  name: "AccessDenied",
  methods: {
    goBack() {
      this.$router.go(-1);
    },
  },
};
</script>
