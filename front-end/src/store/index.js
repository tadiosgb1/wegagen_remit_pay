import { createStore } from 'vuex';
import auth from './modules/auth';
import apiClientPlugin from "./plugins/apiClientPlugin"; // Import the plugin

const store = createStore({
  modules: {
    auth,
  },
  plugins: [apiClientPlugin],
});

export default store;