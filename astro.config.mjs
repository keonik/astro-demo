import { defineConfig } from "astro/config";
import mdx from "@astrojs/mdx";
import sitemap from "@astrojs/sitemap";
import tailwind from "@astrojs/tailwind";
import solidJs from "@astrojs/solid-js";
import remarkToc from "remark-toc";
import { rehypeAccessibleEmojis } from "rehype-accessible-emojis";
import { rehypeHeadingIds } from "@astrojs/markdown-remark";

// https://astro.build/config
export default defineConfig({
  site: "https://keonik.github.io",
  base: "astro-demo",
  output: "static",
  markdown: {
    // Applied to .md and .mdx files
    remarkPlugins: [[remarkToc, { heading: "toc" }]],
    rehypePlugins: [
      rehypeAccessibleEmojis,
      [rehypeHeadingIds, { behavior: "append" }],
    ],
  },
  integrations: [
    mdx(),
    sitemap(),
    solidJs(),
    tailwind({ applyBaseStyles: false }),
  ],
});
