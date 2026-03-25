---
title: "Why I Switched from Next.js to Astro for My Portfolio"
date: "Mar 25 2026"
draft: false
summary: "I've rebuilt my portfolio four times: Gatsby, Next.js, SolidStart, and now Astro. Here's why I keep rewriting it and why Astro is the one that stuck."
tldr: Astro ships zero JS by default, content collections make blog management trivial, and for a content site you don't need React on the client. Stop shipping SPAs for static content.
tags:
  - astro
  - nextjs
  - gatsby
  - solidjs
  - portfolio
---

## The Portfolio Graveyard

Let me be honest about my track record:

| Year | Framework | What Happened |
|------|-----------|---------------|
| 2020 | Gatsby | CMS integration was overkill for a portfolio |
| 2020 | Next.js | Worked fine, got bored |
| 2022 | SolidStart | Wanted to try something new, ecosystem was too young |
| 2026 | Astro | Still here |

Every developer rebuilds their portfolio too many times. I'm not going to pretend I'm above that. But each rewrite taught me something about what a portfolio site actually needs versus what I assumed it needed.

## What a Portfolio Actually Needs

After four versions, here's the real requirements list:

1. **Static content that loads fast** — blog posts, project descriptions, about page
2. **Good SEO** — meta tags, sitemap, RSS feed
3. **Markdown/MDX support** — I write in Markdown, I want to publish in Markdown
4. **Minimal JavaScript on the client** — a portfolio doesn't need hydration
5. **Easy to deploy** — preferably just a `dist/` folder of static files

That's it. No auth, no database, no API routes, no real-time anything.

## Why Gatsby Didn't Last

Gatsby in 2020 was powerful but opinionated in ways that didn't match my needs. GraphQL for querying local files felt like using a crane to move a coffee cup. The plugin ecosystem was huge but fragile — every Gatsby upgrade broke at least two plugins.

The build times were also rough. For a site with 6 blog posts, waiting 30+ seconds for a build felt wrong.

## Why Next.js Was Fine But Wrong

Next.js is great. I use it professionally. But for a portfolio, it's bringing a framework designed for full-stack web applications to a problem that needs a static site generator.

With Next.js, you're shipping React to the client by default. Your "About" page — which is literally just text and a photo — gets hydrated with a full React runtime. You can optimize this with server components and static exports, but you're fighting the framework's defaults instead of working with them.

## Why SolidStart Was Too Early

I genuinely like Solid.js. The reactivity model is elegant, the performance is great, and the DX is good. But in 2022, SolidStart was brand new. The routing was in flux, the ecosystem was small, and building a portfolio on it felt like beta-testing someone else's framework.

I'd consider SolidStart again for an app. For a content site, it has the same fundamental problem as Next.js — it's an app framework being used for static content.

## Why Astro Stuck

Astro is built for content sites. Not adapted for them, not capable of them — *built for them*. The defaults match my requirements:

**Zero JavaScript by default.** An Astro page ships zero client-side JS unless you explicitly add an interactive island. My blog posts are pure HTML and CSS. No hydration, no runtime, no bundle.

**Content Collections.** Define a schema, drop Markdown files in a folder, and Astro gives you typed, validated content with frontmatter parsing:

```typescript
const posts = await getCollection("blog");
const projects = await getCollection("projects");
```

No GraphQL, no custom loaders, no CMS integration. Files in, typed data out.

**Component flexibility.** I write my components in `.astro` files, but I could use React, Svelte, Vue, or Solid for interactive bits. For this site, I don't need any of them — but the option exists without framework lock-in.

**Build performance.** The entire site — 10+ pages, blog posts with syntax highlighting, sitemap, RSS — builds in under a second. Gatsby took 30+.

**Markdown + Shiki.** Code blocks get syntax highlighted at build time with Shiki. No client-side highlighting library, no layout shift while code loads. The HTML ships with inline styles already applied.

## The Migration

Moving from Next.js to Astro was straightforward:

1. **Blog posts** — already Markdown, just moved to `src/content/blog/`
2. **Components** — rewrote JSX to `.astro` syntax (similar enough)
3. **Layouts** — same slot-based pattern
4. **Styling** — Tailwind works identically
5. **Config** — `astro.config.mjs` instead of `next.config.js`

The biggest change was mental: stopping myself from reaching for `useState` and `useEffect`. In Astro, if you need state, you probably need an island. For a portfolio, you almost never need state.

## When to Not Use Astro

If your site has significant interactivity — dashboards, forms, real-time features — Astro isn't the right choice. Use Next.js, Remix, or SolidStart.

If your site is primarily content with occasional interactivity, Astro is the best tool I've used. It's the first framework where the defaults matched what I actually needed, and I didn't have to fight it to get a fast, simple site.

Four portfolio rewrites later, I think this one might actually stick.
