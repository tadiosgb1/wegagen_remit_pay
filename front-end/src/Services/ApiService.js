// ApiService.js

import axios from 'axios';
const API_BASE_URL = 'https://api.example.com';
const ApiService = {
  async fetchData() {
    try {
      const response = await axios.get(`${API_BASE_URL}/data`);
      return response.data;
    } catch (error) {
      console.error('Error fetching data:', error);
      throw new Error('Failed to fetch data');
    }
  },

  async postData(payload) {
    try {
      const response = await axios.post(`${API_BASE_URL}/data`, payload);
      return response.data;
    } catch (error) {
      console.error('Error posting data:', error);
      throw new Error('Failed to post data');
    }
  },
  chackService(){
   console.log("I am Api Called from the remote")
  }
};

export default ApiService;