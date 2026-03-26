---
title: "Ditching the Theme Toggle: System Theme Detection in Astro"
date: "Mar 24 2026"
draft: false
summary: How I built system theme detection for my portfolio — an inline script for flash prevention, React hooks for reactive switching, and Shiki dual-theme syntax highlighting.
tldr: Inline script in head for initial paint, useEffect for reactive theme changes, matchMedia listener for live system preference updates, and CSS custom properties for Shiki dual themes.
tags:
  - astro
  - react
  - css
  - dark-mode
  - tailwindcss
---

## The Problem

Most sites ship a theme toggle and call it done. But there are three separate problems hiding in "dark mode support":

1. **Initial paint** — the page needs to know the theme before the first pixel renders
2. **Reactive switching** — when the user changes the theme in your UI, the app needs to respond
3. **System preference changes** — when someone toggles dark mode at the OS level while your site is open

Each one needs a different solution. Here's how I handled all three.

## 1. Flash Prevention: The Inline Script

This runs in `<head>` before the browser paints anything. It's the most critical piece — without it, dark mode users get a white flash on every page load.

```html
<script>
  (() => {
    try {
      const theme = localStorage.getItem("theme") || "system";
      const resolved = theme === "system"
        ? window.matchMedia("(prefers-color-scheme: dark)").matches
          ? "dark"
          : "light"
        : theme;
      const root = document.documentElement;
      root.classList.toggle("dark", resolved === "dark");
      root.style.background = resolved === "dark" ? "#000" : "#fff";
    } catch {}
  })();
</script>
```

A few decisions worth explaining:

- **`localStorage.getItem("theme") || "system"`** — three possible states: `"dark"`, `"light"`, or `"system"`. Default is system, meaning the OS decides.
- **`root.style.background`** — setting the background color directly on the root element catches the very first frame. CSS classes can't beat an inline style for speed here.
- **`try/catch`** — `localStorage` can throw in private browsing or restricted contexts. Silent failure is fine — the page just falls back to the default.
- **IIFE** — keeps variables out of global scope. Small thing, but good hygiene.

In Astro, this goes in your base layout with `is:inline` so it doesn't get bundled and deferred:

```astro
<head>
  <!-- Theme init — runs before paint -->
  <script is:inline>
    (() => {
      try {
        const theme = localStorage.getItem("theme") || "system";
        const resolved = theme === "system"
          ? window.matchMedia("(prefers-color-scheme: dark)").matches
            ? "dark"
            : "light"
          : theme;
        const root = document.documentElement;
        root.classList.toggle("dark", resolved === "dark");
        root.style.background = resolved === "dark" ? "#000" : "#fff";
      } catch {}
    })();
  </script>
</head>
```

## 2. Reactive Theme Switching: useEffect

When the user changes the theme through your UI (or you want to support it later), you need the DOM to react. This is where React comes in:

```typescript
useEffect(() => {
  const root = window.document.documentElement;

  root.classList.remove("light", "dark");
  root.style.background = "";

  if (theme === "system") {
    const systemTheme = prefersDarkMode() ? "dark" : "light";
    root.classList.add(systemTheme);
    return;
  }

  root.classList.add(theme);
}, [theme]);
```

What's happening:

- **Strip both classes first** — clean slate on every change. No stale state.
- **Clear inline background** — the inline script set `root.style.background` for the initial paint. Once React hydrates, CSS takes over, so clear it out.
- **Resolve `"system"` at runtime** — if the user picked "system", check `matchMedia` right now and apply the result.
- **`[theme]` dependency** — only re-runs when the theme state actually changes.

The `prefersDarkMode` helper is simple:

```typescript
const prefersDarkMode = () =>
  window.matchMedia("(prefers-color-scheme: dark)").matches;
```

## 3. Live System Changes: matchMedia Listener

If someone switches their OS from light to dark while your site is open, you want to catch it:

```typescript
useEffect(() => {
  const darkThemeMq = window.matchMedia("(prefers-color-scheme: dark)");
  const handleChange = () =>
    setTheme(prefersDarkMode() ? "dark" : "light");
  darkThemeMq.addEventListener("change", handleChange);
  return () => darkThemeMq.removeEventListener("change", handleChange);
}, []);
```

This is a separate effect with an empty dependency array — it mounts once and cleans up on unmount. The `change` event fires whenever the OS-level preference flips, and it updates your React state, which triggers the first `useEffect` to apply the new class.

## Shiki Dual-Theme Syntax Highlighting

Code blocks need to respect the theme too. Astro's Shiki integration supports dual themes:

```typescript
// astro.config.mjs
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

Shiki sets light theme colors as inline styles and stashes dark values as CSS custom properties (`--shiki-dark`). You need CSS to swap them:

```css
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

The `!important` flags override Shiki's inline styles. The `transparent` background on spans prevents each token from getting its own background box.

## Tailwind Typography Gotcha

If you're using `@tailwindcss/typography` for blog content, its prose styles will try to style `<code>` elements inside `<pre>` blocks — adding backgrounds, padding, and border-radius that conflict with Shiki. Scope your inline code styles to exclude code inside `pre`:

```css
/* Inline code only — not inside pre blocks */
.prose :where(code):not(:where(pre *, [class~="not-prose"], [class~="not-prose"] *)) {
  @apply bg-gray-100 dark:bg-gray-800 px-1.5 py-0.5 rounded text-sm;
}

/* Reset code inside pre — let Shiki own it */
.prose :where(pre code):not(:where([class~="not-prose"], [class~="not-prose"] *)) {
  background: none;
  padding: 0;
  border-radius: 0;
  font-size: inherit;
}
```

## The Full Picture

Three layers, each solving a different timing problem:

| Layer | When | What |
|-------|------|------|
| Inline `<script>` | Before first paint | Prevents flash, sets initial theme |
| `useEffect([theme])` | On theme state change | Applies class, clears inline styles |
| `useEffect([])` | On mount | Listens for OS-level theme changes |

The inline script is the foundation. The React effects handle everything after hydration. Together they cover every edge case I've hit — initial load, manual switching, and live system changes.
