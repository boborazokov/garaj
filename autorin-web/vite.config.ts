import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import path from 'node:path'

export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  server: {
    host: true,
    port: 5173,
    // Same-origin in the browser (works from phone/LAN). Vite forwards to Nest.
    proxy: {
      "/api": {
        target: "http://127.0.0.1:7007",
        changeOrigin: true,
      },
      "/upload": {
        target: "http://127.0.0.1:7007",
        changeOrigin: true,
      },
      "/media": {
        target: "http://127.0.0.1:7007",
        changeOrigin: true,
      },
      "/debug": {
        target: "http://127.0.0.1:7007",
        changeOrigin: true,
      },
    },
  },
})
