---
title: "Ditching the Theme Toggle: System Theme Detection in Astro"
date: "Mar 24 2026"
draft: false
summary: How I removed the manual dark mode toggle from my portfolio and replaced it with system theme detection — complete with Shiki dual-theme syntax highlighting and live theme switching.
tldr: Drop the toggle, use prefers-color-scheme with a tiny inline script, wire up Shiki dual themes, and add a matchMedia listener for live system changes.
tags:
  - astro
  - css
  - dark-mode
  - tailwindcss
---

## Why I Killed the Toggle

I had the standard sun/moon toggle in my header. It worked, but it bothered me. Every visitor already has a theme preference set at the OS level — macOS, Windows, iOS, Android all have dark mode switches. Adding a per-site toggle means:

- Managing `localStorage` to persist their choice
- Dealing with flash-of-wrong-theme on page load
- A button in my nav that almost nobody clicks

For a portfolio site, it's unnecessary complexity. So I ripped it out.

## The Base Layout Setup

The key is an inline script in `<head>` that runs before paint. Here's what my `BaseLayout.astro` looks like:

```astro
---
import { SITE } from "../consts";
import Header from "../components/Header.astro";
import Footer from "../components/Footer.astro";
import "../styles/global.css";

interface Props {
  title?: string;
  description?: string;
  ogImage?: string;
}

const {
  title = SITE.title,
  description = SITE.description,
  ogImage = "/og.png",
} = Astro.props;

const pageTitle = title === SITE.title
  ? title
  : `${title} — ${SITE.title}`;
---

<!doctype html>
<html lang="en" class="dark">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>{pageTitle}</title>

    <!-- Theme init — runs before paint to prevent flash -->
    <script is:inline>
      document.documentElement.classList.toggle(
        "dark",
        window.matchMedia("(prefers-color-scheme: dark)").matches
      );
    </script>
  </head>
  <body class="min-h-screen flex flex-col">
    <Header />
    <main class="flex-1">
      <slot />
    </main>
    <Footer />
  </body>
</html>
```

A few things worth noting:

- **`is:inline`** is critical. Astro normally bundles and defers scripts, but theme detection has to block render. Without `is:inline`, you get a flash of the wrong theme on every page load.
- **`class="dark"` on `<html>`** is the default. The script immediately removes it if the user prefers light mode. This means dark mode users never see a flash — and they're the ones who notice it most.
- **No `localStorage`**. The OS is the source of truth. Period.

## Handling Live Theme Changes

What if someone switches their system theme while your site is open? The initial script only runs once. You need a `matchMedia` listener for live updates:

```typescript
// theme-listener.ts
const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)");

function applyTheme(e: MediaQueryList | MediaQueryListEvent) {
  document.documentElement.classList.toggle("dark", e.matches);
}

// Apply on load
applyTheme(mediaQuery);

// Listen for changes
mediaQuery.addEventListener("change", applyTheme);
```

I keep this as a regular Astro script (not `is:inline`) since it's not blocking-critical — the inline script in `<head>` already handles the initial render. This one just keeps things in sync after that.

## Shiki Dual-Theme Syntax Highlighting

This is the part that tripped me up. Astro uses [Shiki](https://shiki.style/) for syntax highlighting, and it supports dual themes out of the box in `astro.config.mjs`:

```typescript
export default defineConfig({
  markdown: {
    shikiConfig: {
      themes: {
        light: "github-light",
        dark: "github-dark",
      },
    },
  },
});
```

Shiki generates inline styles for the light theme directly on each `<span>`, and stashes the dark theme values as CSS custom properties (`--shiki-dark`). The catch is **you need CSS to actually swap them** in dark mode. Shiki doesn't do this for you.

Here's the CSS that makes it work:

```css
/* Light theme: Shiki sets inline color/background — nothing to do */

/* Dark theme: swap to Shiki's CSS custom properties */
html.dark .astro-code {
  color: var(--shiki-dark) !important;
  background-color: var(--shiki-dark-bg) !important;
}

html.dark .astro-code span {
  color: var(--shiki-dark) !important;
  background-color: transparent !important;
}
```

The `!important` flags aren't great in general, but they're necessary here to override Shiki's inline styles. The `background-color: transparent` on spans prevents each token from getting its own background box in dark mode.

## Tailwind Typography + Code Blocks

If you're using `@tailwindcss/typography` (and you should be for blog posts), there's a conflict with code blocks. The prose styles add `background`, `padding`, and `border-radius` to all `<code>` elements — including the ones inside `<pre>` blocks that Shiki is already styling.

The fix is scoping your inline code styles to exclude code inside `pre`:

```css
/* Inline code — not inside pre blocks */
.prose :where(code):not(:where(pre *, [class~="not-prose"], [class~="not-prose"] *)) {
  @apply bg-gray-100 dark:bg-gray-800 px-1.5 py-0.5 rounded text-sm;
}

/* Code blocks — subtle background differentiation */
.prose :where(pre):not(:where([class~="not-prose"], [class~="not-prose"] *)) {
  @apply bg-gray-50 dark:bg-gray-900/50 border border-gray-200 dark:border-gray-800 rounded-lg;
}

/* Reset code inside pre — let Shiki own it */
.prose :where(pre code):not(:where([class~="not-prose"], [class~="not-prose"] *)) {
  background: none;
  padding: 0;
  border-radius: 0;
  font-size: inherit;
}
```

Without that `:not(:where(pre *, ...))` selector, every syntax-highlighted token gets wrapped in a gray box. Not the look.

## What I Removed

The old `ThemeToggle.astro` component was about 40 lines — a button with two SVG icons, `localStorage` read/write, a click handler, and a system preference listener that was fighting with the manual override. Replaced all of it with:

- 3 lines of inline JS in the layout
- A `matchMedia` change listener
- Some CSS for Shiki theming

Less code, better UX, respects the user's actual preference.

## When You Might Still Want a Toggle

I'll be honest — there are valid cases:

- **Reading-heavy apps** where users want per-app control independent of their OS
- **Accessibility needs** where someone runs light mode OS-wide but prefers dark for specific sites
- **Apps where users spend hours** and the OS preference might not match the context

For a portfolio though? Let the OS handle it. Ship less JavaScript. Move on.
