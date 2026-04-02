
<template>
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
    <div class="bg-white rounded-xl shadow-2xl w-full max-w-sm p-6 text-sm">
      <div class="flex justify-between items-center mb-4 border-b pb-2">
        <h2 class="text-lg font-semibold text-gray-800 ">Edit Transactions </h2>
        <button @click="$emit('close')" class="text-gray-400 hover:text-gray-600">&times;</button>
      </div>

      <form @submit.prevent="submitForm" class="space-y-4">
        
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Reference_no</label>
          <input v-model="form.reference_no" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Sender_id</label>
          <input v-model="form.sender_id" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Amount_original</label>
          <input v-model="form.amount_original" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Currency</label>
          <input v-model="form.currency" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Exchange_rate</label>
          <input v-model="form.exchange_rate" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Amount_etb</label>
          <input v-model="form.amount_etb" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Status</label>
          <input v-model="form.status" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Payment_method</label>
          <input v-model="form.payment_method" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Delivery_method</label>
          <input v-model="form.delivery_method" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Receiver_full_name</label>
          <input v-model="form.receiver_full_name" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Receiver_phone</label>
          <input v-model="form.receiver_phone" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Receiver_email</label>
          <input v-model="form.receiver_email" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Bank_name</label>
          <input v-model="form.bank_name" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
        </div>
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Account_number</label>
          <input v-model="form.account_number" type="text" required class="border border-gray-300 rounded-lg px-4 py-2 text-sm w-full sm:max-w-xs focus:outline-none focus:ring-2 focus:ring-green-500 shadow-sm transition duration-150" />
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
        reference_no: this.data?.reference_no || '',
sender_id: this.data?.sender_id || '',
amount_original: this.data?.amount_original || '',
currency: this.data?.currency || '',
exchange_rate: this.data?.exchange_rate || '',
amount_etb: this.data?.amount_etb || '',
status: this.data?.status || '',
payment_method: this.data?.payment_method || '',
delivery_method: this.data?.delivery_method || '',
receiver_full_name: this.data?.receiver_full_name || '',
receiver_phone: this.data?.receiver_phone || '',
receiver_email: this.data?.receiver_email || '',
bank_name: this.data?.bank_name || '',
account_number: this.data?.account_number || ''
      }
    };
  },
  methods: {
    async submitForm() {
      try {
        if ("Edit" === "Add") {
        const res= await this.$apiPost("/transactions", this.form);
        if(res){
           this.$root.$refs.toast.showToast('Added successfully', 'success');
         }

        } else {
         const res= await this.$apiPut("/transactions",this.data.id ,this.form);
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
