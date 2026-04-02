<template>
  <div
    v-if="visible"
    class="fixed inset-0 z-50 bg-black bg-opacity-50 flex items-center justify-center p-4 overflow-auto"
  >
    <div
      class="bg-white w-full sm:w-auto sm:max-w-[500px] md:max-w-[650px] lg:max-w-[750px] xl:max-w-[850px] rounded-lg shadow-lg overflow-hidden relative mx-auto"
    >
      <!-- Header -->
      <div class="bg-primary text-white px-6 py-4 text-2xl font-semibold flex justify-between items-center">
        Add Commission
        <button @click="$emit('close')" class="text-white hover:text-gray-200 text-lg font-bold">
          ✕
        </button>
      </div>

      <!-- Form -->
      <form @submit.prevent="submitForm" class="space-y-4 px-4 py-4">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium mb-1">SaaS Commission</label>
            <input
              v-model="form.saas_commission"
              type="text"
              required
              class="w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium mb-1">Broker Commission</label>
            <input
              v-model="form.broker_commission"
              type="text"
              required
              class="w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium mb-1">Total Commission</label>
            <input
              v-model="form.total_commission"
              type="text"
              required
              class="w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium mb-1">Property Sale</label>
            <select
              v-model.number="form.property_sale"
              required
              class="w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
            >
              <option disabled value="">Select Property Sale</option>
              <option
                v-for="sale in propertySales"
                :key="sale.id"
                :value="sale.id"
              >
                {{ sale.name || sale.code }}
              </option>
            </select>
          </div>
        </div>

        <!-- Actions -->
        <div class="flex justify-end space-x-3 pt-4 border-t mt-4">
          <button
            type="submit"
            class="px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600"
          >
            Save Commission
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: "AddCommission",
  props: {
    visible: Boolean,
  },
  data() {
    return {
      form: {
        saas_commission: "",
        broker_commission: "",
        total_commission: "",
        property_sale: 0,
      },
      propertySales: [],
    };
  },

  
  async mounted() {
    try {
      const res = await this.$apiGet("/get_property_sales");
      this.propertySales = res.data || [];
    } catch (err) {
      console.error("Failed to fetch property sales:", err);
    }
  },


  methods: {
    async submitForm() {
      try {
        const payload = { ...this.form };
        const res = await this.$apiPost("/post_commission", payload);
        console.log("Commission added:", res);
        this.$emit("success");
        this.resetForm();
        this.$emit("close");
      } catch (err) {
        console.error("Failed to add commission:", err);
        alert("Failed to add commission.");
      }
    },
    resetForm() {
      this.form = {
        saas_commission: "",
        broker_commission: "",
        total_commission: "",
        property_sale: 0,
      };
    },
  },
};
</script>
