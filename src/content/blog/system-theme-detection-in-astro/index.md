---
title: "Ditching the Theme Toggle: System Theme Detection in Astro"
date: "Mar 24 2026"
draft: false
summary: Why we removed our manual dark mode toggle in favor of respecting the user's system preference — and how to implement it in Astro with zero JavaScript overhead.
tldr: Use prefers-color-scheme media query and a tiny inline script to match system theme. No toggle, no localStorage, no flash.
tags:
  - astro
  - css
  - dark-mode
  - tailwindcss
---

## The Problem with Theme Toggles

Most portfolio sites ship a little sun/moon toggle in the header. We had one too. It looked something like this:

```astro
<!-- ThemeToggle.astro -->
<button id="theme-toggle" aria-label="Toggle dark mode">
  <!-- sun icon (shown in dark mode) -->
  <svg class="w-5 h-5 hidden dark:block">...</svg>
  <!-- moon icon (shown in light mode) -->
  <svg class="w-5 h-5 block dark:hidden">...</svg>
</button>

<script>
  const toggle = document.getElementById("theme-toggle");

  function getTheme() {
    if (localStorage.getItem("theme")) {
      return localStorage.getItem("theme");
    }
    return window.matchMedia("(prefers-color-scheme: dark)").matches
      ? "dark"
      : "light";
  }

  function setTheme(theme) {
    document.documentElement.classList.toggle("dark", theme === "dark");
    localStorage.setItem("theme", theme);
  }

  setTheme(getTheme());

  toggle?.addEventListener("click", () => {
    const current = getTheme();
    setTheme(current === "dark" ? "light" : "dark");
  });
</script>
```

It worked fine, but we realized: **why fight the OS?** Users already picked their preference at the system level. A manual toggle just adds complexity — localStorage management, flash-of-wrong-theme issues, and a button that most people never click.

## The Simpler Approach

We ripped out the toggle and replaced the whole thing with a single inline script in our base layout:

```html
<script is:inline>
  document.documentElement.classList.toggle(
    "dark",
    window.matchMedia("(prefers-color-scheme: dark)").matches
  );
</script>
```

That's it. Three lines. Here's what's happening:

1. **`window.matchMedia("(prefers-color-scheme: dark)")`** — checks the user's OS-level theme preference
2. **`.matches`** — returns `true` if they're in dark mode
3. **`classList.toggle("dark", ...)`** — adds or removes the `dark` class on `<html>`

Since Tailwind's dark mode uses the `dark` class by default, everything just works.

## Why `is:inline`?

Astro normally bundles and defers scripts. That's great for most things, but theme detection needs to run **before the page paints** to avoid a flash of the wrong theme. The `is:inline` directive tells Astro to drop the script directly into the HTML, blocking render until it executes.

## What About Live Changes?

If someone switches their system theme while your site is open, CSS handles it automatically via the media query. But since we're using Tailwind's class-based dark mode (not the `media` strategy), we need a listener to stay in sync:

```html
<script is:inline>
  // Initial theme
  const mq = window.matchMedia("(prefers-color-scheme: dark)");
  document.documentElement.classList.toggle("dark", mq.matches);

  // Live updates
  mq.addEventListener("change", (e) => {
    document.documentElement.classList.toggle("dark", e.matches);
  });
</script>
```

Now if a user flips from light to dark mode in their system settings, your site updates instantly — no reload needed.

## The CSS-Only Alternative

If you're not locked into Tailwind's class strategy, you can skip JavaScript entirely and use pure CSS:

```css
@media (prefers-color-scheme: dark) {
  :root {
    --bg: #0a0a0a;
    --text: #fafafa;
  }
}

@media (prefers-color-scheme: light) {
  :root {
    --bg: #fafafa;
    --text: #0a0a0a;
  }
}
```

No JS, no flash, no toggle. The browser handles everything. The tradeoff is that Tailwind's `dark:` utility classes won't work — you'd need to use CSS custom properties instead.

## What We Removed

Here's exactly what we deleted:

- **`ThemeToggle.astro`** — the entire component
- **`localStorage` read/write** — no more persisting theme choice
- **Theme init script** — replaced 8 lines with 1

And the header went from this:

```astro
<ThemeToggle />
```

To nothing. Cleaner nav, less code, same result.

## When You Actually Need a Toggle

To be fair, there are cases where a manual toggle makes sense:

- **Content-heavy sites** where users might want dark mode for reading even if their OS is in light mode
- **Apps** where users spend hours and want per-app control
- **Accessibility** — some users set their OS to light but prefer dark on web

For a portfolio site though? System preference is the move. Your visitors are probably developers who already have their theme dialed in.

## TL;DR

```html
<!-- In your base layout <head> -->
<script is:inline>
  document.documentElement.classList.toggle(
    "dark",
    window.matchMedia("(prefers-color-scheme: dark)").matches
  );
</script>
```

Respect the user's choice. Ship less code. Move on to building cool stuff.
