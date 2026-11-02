import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// In dev (compose.dev.yml) the API is reachable at http://api:3000 on the
// compose network. Outside Docker you can override it with API_URL.
const target = process.env.API_URL || "http://api:3000";

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    watch: { usePolling: true },
    proxy: { "/api": { target, rewrite: (p) => p.replace(/^\/api/, "") } },
  },
});
