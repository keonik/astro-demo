import { defineConfig } from "astro/config";

import tailwind from "@astrojs/tailwind";

// https://astro.build/config
export default defineConfig({
  site: "https://keonik.github.io/",
  base: "astro-demo",
  integrations: [tailwind()],
});
