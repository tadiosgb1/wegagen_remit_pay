import { apiGet } from '../../utils/utils';
const state = {
  userId: localStorage.getItem('userId') || null,
  token: localStorage.getItem('token') || null,
  locale: localStorage.getItem('locale') || 'en',
  name: localStorage.getItem('name') || null,
  phoneNumber: localStorage.getItem('phoneNumber') || null,
  role: localStorage.getItem('role') || null,
  userCode: localStorage.getItem('userCode') || null,
  email: localStorage.getItem('email') || null,
  reloading: localStorage.getItem('reloading') || null,
  activeItem: localStorage.getItem('activeItem') || 'dashboard', // Default to 'dashboard'
  serviceBanks: localStorage.getItem('serviceBanks') || [],
  blockBanks: localStorage.getItem('blockBanks') || [],

};

const mutations = {

  setServiceBanks(state, banks) {
    state.serviceBanks = banks;
    localStorage.setItem('serviceBanks', banks);
  },
  setBlockBanks(state, banks) {
    localStorage.setItem('blockBanks', banks);
    state.blockBanks = banks;
  },
  setUserCode(state, userCode) {
    state.userCode = userCode;
    localStorage.setItem('userCode', userCode);
    console.log("userCode in mutation", userCode);
  },
  setUserId(state, userId) {
    state.userId = userId;
    localStorage.setItem('userId', userId);
    console.log("userId in mutation", userId);
  },
  setToken(state, token) {
    state.token = token;
    localStorage.setItem('token', token);
  },
  setName(state, name) {
    console.log("name in mutation", name);
    localStorage.setItem('name', name);
    state.name = name;
  },
  setPhoneNumber(state, phoneNumber) {
    console.log("phoneNumber in mutation", phoneNumber);
    localStorage.setItem('phoneNumber', phoneNumber);
    state.phoneNumber = phoneNumber;
  },
  setLocale(state, locale) {
    state.locale = locale;
    localStorage.setItem('locale', locale);
  },
  setRole(state, role) {
    console.log("role in mutation", role);
    state.role = role;
    localStorage.setItem('role', role);
  },
  setEmail(state, email) {
    console.log("role in mutation", email);
    state.email = email;
    localStorage.setItem('email', email);
  },
  setActiveItem(state, activeItem) { // Mutation to set activeItem
    state.activeItem = activeItem;
    localStorage.setItem('activeItem', activeItem); // Save activeItem in localStorage
  },

  setReloading(state, reloading) {
    state.reloading = reloading;
    localStorage.setItem('reloading', reloading);
  },

  logout(state) {
    state.userCode = null;
    state.name = null;
    state.userId = null;
    state.token = null;
    state.role = null;
    state.email = null;
    state.reloading = null;
    state.activeItem = 'dashboard'; // Reset to default when logging out
    localStorage.removeItem('activeItem'); // Clear from localStorage
  },
};

const actions = {
  async fetchBanks({ commit }) {
    if (localStorage.getItem('token') != null) {
      // try { 

      // await apiGet("/api/v1/organization")
      // .then((response) => {
      //     console.log("response from the store", response);
      //     const serviceBanks =response.organization.serviceBankAccounts;
      //     const blockBanks =response.organization.blockBankAccounts;
      //     commit('setServiceBanks',serviceBanks,);
      //     commit('setBlockBanks',blockBanks);
      //  })}catch(error)
      //   {
      //  console.log(error);
      // }finally{

      // };
    }
  },
  login({ commit }, { token }) {
    console.log("token in commit ", token);
    commit('setToken', token);
    localStorage.setItem('token', token);
  },
  commitId({ commit }, { userId }) {
    console.log('user in commit action', userId);
    commit('setUserId', userId);
    localStorage.setItem('userId', userId);
  },
  commitUserCode({ commit }, { userCode }) {
    console.log('userCode in commit action', userCode);
    commit('setUserCode', userCode);
    localStorage.setItem('userCode', userCode);
  },
  commitName({ commit }, { name }) {
    console.log("commit name is called", name);
    commit('setName', name);
    localStorage.setItem('name', name);
  },
  commitPhoneNumber({ commit }, { phoneNumber }) {
    console.log("commit Phone number is called", phoneNumber);
    commit('setPhoneNumber', phoneNumber);
    localStorage.setItem('phoneNumber', phoneNumber);
  },

  /*************  ✨ Windsurf Command ⭐  *************/
  /**
   * Set the locale to be used in the app
   * @param {Object} context - Vuex context
   * @param {Object} data - Data containing the locale
   * @param {string} data.locale - Locale to be set
   */
  /*******  297720e6-9eef-49ec-ac01-080272e6d70c  *******/
  setLocale({ commit }, { locale }) {
    commit('setLocale', locale);
  },
  commitRole({ commit }, { role }) {
    console.log("commit role is called", role);
    commit('setRole', role);
    localStorage.setItem('role', role);
  },
  commitEmail({ commit }, { email }) {
    console.log("commit role is called", email);
    commit('setEmail', email);
    localStorage.setItem('email', email);
  },
  commitActiveItem({ commit }, { activeItem }) { // Action to commit activeItem
    console.log("commit activeItem is called", activeItem);
    commit('setActiveItem', activeItem);
  },

  commitReloading({ commit }, { reloading }) { // Action to commit activeItem
    console.log("commit reloading is called", reloading);
    commit('setReloading', reloading);
  },

  logout({ commit }) {
    commit('logout');
    localStorage.removeItem('userId');
    localStorage.removeItem('userCode');
    localStorage.removeItem('name');
    localStorage.removeItem('role');
    localStorage.removeItem('locale');
    localStorage.removeItem('token');
    localStorage.removeItem('serviceBanks'),
      localStorage.removeItem('blockBanks'),
      localStorage.removeItem('reloading');
  },
};

const getters = {

  serviceBanks: (state) => state.serviceBanks,
  blockBanks: (state) => state.blockBanks,

  isAuthenticated(state) {
    return !!state.token;
  },
  getToken(state) {
    return state.token;
  },
  getName(state) {
    console.log("get name", state.name);
    return state.name;
  },
  getUserId(state) {
    return state.userId;
  },
  getUserCode(state) {
    console.log("usercode in usercode get", state.userCode);
    return state.userCode;
  },
  getRole(state) {
    return state.role;
  },

  getEmail(state) {
    return state.email;
  },
  getPhoneNumber(state) {
    return state.phoneNumber;
  },

  getLocale(state) {
    return state.locale;
  },
  getActiveItem(state) { // Getter to retrieve activeItem
    return state.activeItem;
  },
  getReloading(state) {
    return state.reloading;
  },
  // getters, // If you have other getters in your module, include them here
};

export default {
  state,
  mutations,
  actions,
  getters,
};
