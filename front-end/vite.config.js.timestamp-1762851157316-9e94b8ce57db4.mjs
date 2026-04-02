// vite.config.js
import { defineConfig } from "file:///C:/Users/WEGAGEN/Documents/PMS/PMS/front-end/node_modules/vite/dist/node/index.js";
import vue from "file:///C:/Users/WEGAGEN/Documents/PMS/PMS/front-end/node_modules/@vitejs/plugin-vue/dist/index.mjs";
import path from "path";
import commonjs from "file:///C:/Users/WEGAGEN/Documents/PMS/PMS/front-end/node_modules/vite-plugin-commonjs/dist/index.mjs";
var __vite_injected_original_dirname = "C:\\Users\\WEGAGEN\\Documents\\PMS\\PMS\\front-end";
var vite_config_default = defineConfig({
  plugins: [
    vue(),
    commonjs()
  ],
  resolve: {
    alias: {
      "@": path.resolve(__vite_injected_original_dirname, "src")
    }
  },
  server: {
    host: "0.0.0.0",
    port: 3e3,
    allowedHosts: "all"
  },
  preview: {
    host: "0.0.0.0",
    port: 3e3
  },
  optimizeDeps: {
    include: ["rtcpeerconnection-shim", "sdp"]
  },
  assetsInclude: ["**/*.PNG", "**/*.JPG", "**/*.jpeg", "**/*.gif", "**/*.svg"]
});
export {
  vite_config_default as default
};
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcuanMiXSwKICAic291cmNlc0NvbnRlbnQiOiBbImNvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9kaXJuYW1lID0gXCJDOlxcXFxVc2Vyc1xcXFxXRUdBR0VOXFxcXERvY3VtZW50c1xcXFxQTVNcXFxcUE1TXFxcXGZyb250LWVuZFwiO2NvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9maWxlbmFtZSA9IFwiQzpcXFxcVXNlcnNcXFxcV0VHQUdFTlxcXFxEb2N1bWVudHNcXFxcUE1TXFxcXFBNU1xcXFxmcm9udC1lbmRcXFxcdml0ZS5jb25maWcuanNcIjtjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfaW1wb3J0X21ldGFfdXJsID0gXCJmaWxlOi8vL0M6L1VzZXJzL1dFR0FHRU4vRG9jdW1lbnRzL1BNUy9QTVMvZnJvbnQtZW5kL3ZpdGUuY29uZmlnLmpzXCI7aW1wb3J0IHsgZGVmaW5lQ29uZmlnIH0gZnJvbSAndml0ZSdcclxuaW1wb3J0IHZ1ZSBmcm9tICdAdml0ZWpzL3BsdWdpbi12dWUnXHJcbmltcG9ydCBwYXRoIGZyb20gJ3BhdGgnXHJcbmltcG9ydCBjb21tb25qcyBmcm9tICd2aXRlLXBsdWdpbi1jb21tb25qcydcclxuXHJcbmV4cG9ydCBkZWZhdWx0IGRlZmluZUNvbmZpZyh7XHJcbiAgcGx1Z2luczogW1xyXG4gICAgdnVlKCksXHJcbiAgICBjb21tb25qcygpXHJcbiAgXSxcclxuXHJcbiAgcmVzb2x2ZToge1xyXG4gICAgYWxpYXM6IHtcclxuICAgICAgJ0AnOiBwYXRoLnJlc29sdmUoX19kaXJuYW1lLCAnc3JjJylcclxuICAgIH1cclxuICB9LFxyXG5cclxuICBzZXJ2ZXI6IHtcclxuICAgIGhvc3Q6ICcwLjAuMC4wJyxcclxuICAgIHBvcnQ6IDMwMDAsXHJcbiAgICBhbGxvd2VkSG9zdHM6ICdhbGwnXHJcbiAgfSxcclxuXHJcbiAgcHJldmlldzoge1xyXG4gICAgaG9zdDogJzAuMC4wLjAnLFxyXG4gICAgcG9ydDogMzAwMFxyXG4gIH0sXHJcblxyXG4gIG9wdGltaXplRGVwczoge1xyXG4gICAgaW5jbHVkZTogWydydGNwZWVyY29ubmVjdGlvbi1zaGltJywgJ3NkcCddXHJcbiAgfSxcclxuXHJcbiAgYXNzZXRzSW5jbHVkZTogWycqKi8qLlBORycsICcqKi8qLkpQRycsICcqKi8qLmpwZWcnLCAnKiovKi5naWYnLCAnKiovKi5zdmcnXVxyXG59KVxyXG4iXSwKICAibWFwcGluZ3MiOiAiO0FBQW9VLFNBQVMsb0JBQW9CO0FBQ2pXLE9BQU8sU0FBUztBQUNoQixPQUFPLFVBQVU7QUFDakIsT0FBTyxjQUFjO0FBSHJCLElBQU0sbUNBQW1DO0FBS3pDLElBQU8sc0JBQVEsYUFBYTtBQUFBLEVBQzFCLFNBQVM7QUFBQSxJQUNQLElBQUk7QUFBQSxJQUNKLFNBQVM7QUFBQSxFQUNYO0FBQUEsRUFFQSxTQUFTO0FBQUEsSUFDUCxPQUFPO0FBQUEsTUFDTCxLQUFLLEtBQUssUUFBUSxrQ0FBVyxLQUFLO0FBQUEsSUFDcEM7QUFBQSxFQUNGO0FBQUEsRUFFQSxRQUFRO0FBQUEsSUFDTixNQUFNO0FBQUEsSUFDTixNQUFNO0FBQUEsSUFDTixjQUFjO0FBQUEsRUFDaEI7QUFBQSxFQUVBLFNBQVM7QUFBQSxJQUNQLE1BQU07QUFBQSxJQUNOLE1BQU07QUFBQSxFQUNSO0FBQUEsRUFFQSxjQUFjO0FBQUEsSUFDWixTQUFTLENBQUMsMEJBQTBCLEtBQUs7QUFBQSxFQUMzQztBQUFBLEVBRUEsZUFBZSxDQUFDLFlBQVksWUFBWSxhQUFhLFlBQVksVUFBVTtBQUM3RSxDQUFDOyIsCiAgIm5hbWVzIjogW10KfQo=
