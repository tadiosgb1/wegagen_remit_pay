import axios from "axios";

// Vuex plugin should receive the store instance
export default function apiClientPlugin(store) {
  // Check environment and set base URL
  const isProduction = import.meta.env.MODE === "production";
  const baseUrl = isProduction
    ? import.meta.env.VITE_APP_BASE_URL_PRODUCTION
    : import.meta.env.VITE_APP_BASE_URL_LOCAL;

  // Create the API client
  const apiClient = axios.create({
    baseURL: baseUrl,
  });
  console.log("API Client:", apiClient);

  // You can add `apiClient` to the Vuex store so it is globally available
  store.$apiClient = apiClient;

  // Optionally, you could define some Vuex mutations/actions to interact with this client.
}
