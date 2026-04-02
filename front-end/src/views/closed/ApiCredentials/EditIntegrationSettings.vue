
<template>
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
    <div class="bg-white rounded-xl shadow-2xl w-full max-w-sm p-6 text-sm">
      <div class="flex justify-between items-center mb-4 border-b pb-2">
        <h2 class="text-lg font-semibold text-gray-800 ">Edit IntegrationSettings </h2>
        <button @click="$emit('close')" class="text-gray-400 hover:text-gray-600">&times;</button>
      </div>

      <form @submit.prevent="submitForm" class="space-y-4">
        
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Provider_name</label>
          <input v-model="form.provider_name" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Merchant_id</label>
          <input v-model="form.merchant_id" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Profile_id</label>
          <input v-model="form.profile_id" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Access_key</label>
          <input v-model="form.access_key" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Secret_key</label>
          <input v-model="form.secret_key" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Shared_secret_key</label>
          <input v-model="form.shared_secret_key" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Environment</label>
          <input v-model="form.environment" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Is_active</label>
          <input v-model="form.is_active" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>

        <div class="flex justify-end gap-3 pt-2">
          <button type="button" @click="$emit('close')" class="px-4 py-2 border rounded-lg">Cancel</button>
          <button type="submit" class="px-4 py-2 bg-green-500 text-white rounded-lg">Edit</button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  props: { data: Object },
  data() {
    return {
      form: {
        provider_name: this.data?.provider_name || '',
merchant_id: this.data?.merchant_id || '',
profile_id: this.data?.profile_id || '',
access_key: this.data?.access_key || '',
secret_key: this.data?.secret_key || '',
shared_secret_key: this.data?.shared_secret_key || '',
environment: this.data?.environment || '',
is_active: this.data?.is_active || ''
      }
    };
  },
  methods: {
    async submitForm() {
      try {
        if ("Edit" === "Add") {
        const res= await this.$apiPost("/integrationsettings", this.form);
        if(res){
           this.$root.$refs.toast.showToast('Added successfully', 'success');
         }

        } else {
         const res= await this.$apiPut("/integrationsettings",this.data.id ,this.form);
         if(res){
           this.$root.$refs.toast.showToast('Edited successfully', 'success');
         }
        }
        this.$emit("saved");
        this.$emit("close");
      } catch (e) { console.error(e); }
    }
  }
}
</script>
