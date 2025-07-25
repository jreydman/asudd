import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";
import react from "@vitejs/plugin-react";
import path from "path";

export default () => {
  const env = import.meta.env;

  const PORT = Number(env.WEBCLIENT_PORT ?? 3000);

  const config = defineConfig({
    server: {
      host: "0.0.0.0",
      port: PORT,
      watch: {
        usePolling: true,
      },

      proxy: {
        "/api": {
          target: `http://${env.APISERVER_HOST}:${env.APISERVER_PORT}`,
          secure: false,
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/api/, ""),
        },
      },
    },
    resolve: {
      alias: {
        "@src": path.resolve(__dirname, "./src"),
        "@assets": path.resolve(__dirname, "./src/assets"),
        "@components": path.resolve(__dirname, "./src/components"),
        "@utils": path.resolve(__dirname, "./src/utils"),
      },
    },
    plugins: [react(), tailwindcss()],
  });

  return config;
};
