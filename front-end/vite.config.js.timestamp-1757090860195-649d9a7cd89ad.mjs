// vite.config.js
import { defineConfig } from "file:///C:/Users/user/Documents/PMS/front-end/node_modules/vite/dist/node/index.js";
import vue from "file:///C:/Users/user/Documents/PMS/front-end/node_modules/@vitejs/plugin-vue/dist/index.mjs";
import path from "path";
import commonjs from "file:///C:/Users/user/Documents/PMS/front-end/node_modules/vite-plugin-commonjs/dist/index.mjs";
var __vite_injected_original_dirname = "C:\\Users\\user\\Documents\\PMS\\front-end";
var vite_config_default = defineConfig({
  assetsInclude: ["**/*.PNG", "**/*.JPG"],
  logLevel: "info",
  // or 'debug'
  plugins: [
    vue(),
    commonjs()
  ],
  resolve: {
    alias: {
      "@": path.resolve(__vite_injected_original_dirname, "src")
    }
  },
  optimizeDeps: {
    include: ["rtcpeerconnection-shim", "sdp"]
  },
  server: {
    host: "0.0.0.0",
    port: 5173,
    allowedHosts: "all"
    // ✅ Correct RegExp format
  }
});
export {
  vite_config_default as default
};
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcuanMiXSwKICAic291cmNlc0NvbnRlbnQiOiBbImNvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9kaXJuYW1lID0gXCJDOlxcXFxVc2Vyc1xcXFx1c2VyXFxcXERvY3VtZW50c1xcXFxQTVNcXFxcZnJvbnQtZW5kXCI7Y29uc3QgX192aXRlX2luamVjdGVkX29yaWdpbmFsX2ZpbGVuYW1lID0gXCJDOlxcXFxVc2Vyc1xcXFx1c2VyXFxcXERvY3VtZW50c1xcXFxQTVNcXFxcZnJvbnQtZW5kXFxcXHZpdGUuY29uZmlnLmpzXCI7Y29uc3QgX192aXRlX2luamVjdGVkX29yaWdpbmFsX2ltcG9ydF9tZXRhX3VybCA9IFwiZmlsZTovLy9DOi9Vc2Vycy91c2VyL0RvY3VtZW50cy9QTVMvZnJvbnQtZW5kL3ZpdGUuY29uZmlnLmpzXCI7XHJcbmltcG9ydCB7IGRlZmluZUNvbmZpZyB9IGZyb20gJ3ZpdGUnXHJcbmltcG9ydCB2dWUgZnJvbSAnQHZpdGVqcy9wbHVnaW4tdnVlJ1xyXG5pbXBvcnQgcGF0aCBmcm9tICdwYXRoJ1xyXG5pbXBvcnQgY29tbW9uanMgZnJvbSAndml0ZS1wbHVnaW4tY29tbW9uanMnXHJcblxyXG5leHBvcnQgZGVmYXVsdCBkZWZpbmVDb25maWcoe1xyXG4gIGFzc2V0c0luY2x1ZGU6IFsnKiovKi5QTkcnLCAnKiovKi5KUEcnXSxcclxuICBsb2dMZXZlbDogJ2luZm8nLCAvLyBvciAnZGVidWcnXHJcbiAgcGx1Z2luczogW1xyXG4gICAgdnVlKCksXHJcbiAgICBjb21tb25qcygpXHJcbiAgXSxcclxuICByZXNvbHZlOiB7XHJcbiAgICBhbGlhczoge1xyXG4gICAgICAnQCc6IHBhdGgucmVzb2x2ZShfX2Rpcm5hbWUsICdzcmMnKVxyXG4gICAgfVxyXG4gIH0sXHJcbiAgb3B0aW1pemVEZXBzOiB7XHJcbiAgICBpbmNsdWRlOiBbJ3J0Y3BlZXJjb25uZWN0aW9uLXNoaW0nLCAnc2RwJ11cclxuICB9LFxyXG4gIHNlcnZlcjoge1xyXG4gICAgaG9zdDogJzAuMC4wLjAnLFxyXG4gICAgcG9ydDogNTE3MyxcclxuICAgIGFsbG93ZWRIb3N0czogJ2FsbCcsICAvLyBcdTI3MDUgQ29ycmVjdCBSZWdFeHAgZm9ybWF0XHJcbiAgfVxyXG59KSJdLAogICJtYXBwaW5ncyI6ICI7QUFDQSxTQUFTLG9CQUFvQjtBQUM3QixPQUFPLFNBQVM7QUFDaEIsT0FBTyxVQUFVO0FBQ2pCLE9BQU8sY0FBYztBQUpyQixJQUFNLG1DQUFtQztBQU16QyxJQUFPLHNCQUFRLGFBQWE7QUFBQSxFQUMxQixlQUFlLENBQUMsWUFBWSxVQUFVO0FBQUEsRUFDdEMsVUFBVTtBQUFBO0FBQUEsRUFDVixTQUFTO0FBQUEsSUFDUCxJQUFJO0FBQUEsSUFDSixTQUFTO0FBQUEsRUFDWDtBQUFBLEVBQ0EsU0FBUztBQUFBLElBQ1AsT0FBTztBQUFBLE1BQ0wsS0FBSyxLQUFLLFFBQVEsa0NBQVcsS0FBSztBQUFBLElBQ3BDO0FBQUEsRUFDRjtBQUFBLEVBQ0EsY0FBYztBQUFBLElBQ1osU0FBUyxDQUFDLDBCQUEwQixLQUFLO0FBQUEsRUFDM0M7QUFBQSxFQUNBLFFBQVE7QUFBQSxJQUNOLE1BQU07QUFBQSxJQUNOLE1BQU07QUFBQSxJQUNOLGNBQWM7QUFBQTtBQUFBLEVBQ2hCO0FBQ0YsQ0FBQzsiLAogICJuYW1lcyI6IFtdCn0K
