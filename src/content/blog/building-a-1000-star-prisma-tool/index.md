---
title: "Building a 1000⭐ Open Source Prisma Tool"
date: "Mar 25 2026"
draft: false
summary: How prisma-erd-generator went from a weekend hack to 1000+ stars, 64 forks, and 23 contributors — and what I learned maintaining open source along the way.
tldr: Start small, solve your own problem, make it easy to contribute, and be patient. Also, Prisma generators are underrated.
tags:
  - open-source
  - prisma
  - typescript
  - mermaidjs
---

## The Origin

In 2021 I was working on a project with a growing Prisma schema and kept losing track of the relationships between models. I'd scroll through `schema.prisma`, try to hold the mental model in my head, and inevitably miss something.

[@Skn0tt](https://github.com/Skn0tt) had built a [web app](https://prisma-erd.simonknott.de/) that could generate ER diagrams from Prisma schemas, and it was great — but I wanted something that ran automatically. Every time I ran `npx prisma generate`, I wanted a fresh diagram sitting in my repo without thinking about it.

So I built [prisma-erd-generator](https://github.com/keonik/prisma-erd-generator).

## How It Works

The concept is dead simple: it's a Prisma generator. You add it to your `schema.prisma`:

```prisma
generator erd {
  provider = "prisma-erd-generator"
}
```

Run `npx prisma generate`, and it outputs an ER diagram as SVG, PNG, PDF, or Markdown. Under the hood, it parses the Prisma DMMF (Data Model Meta Format), converts it to a Mermaid.js diagram definition, and renders it using `@mermaid-js/mermaid-cli`.

The key insight was making it a generator rather than a standalone CLI. Prisma generators hook into the existing workflow — developers don't have to remember an extra command or add a build step. It just happens.

## Getting to 1000 Stars

It didn't happen overnight. The repo sat at double-digit stars for a while. A few things helped it grow:

**Solving a real pain point.** Every team with a non-trivial Prisma schema eventually wants to visualize it. I wasn't the only one scrolling through 500-line schema files trying to remember what connects to what.

**Making configuration easy.** I added options incrementally based on what people asked for — output format, themes, disabling specific models, table-only mode. Each one was a small PR but made the tool work for more use cases.

```prisma
generator erd {
  provider = "prisma-erd-generator"
  output = "../docs/ERD.svg"
  theme = "forest"
  disableEmoji = true
}
```

**Supporting Prisma version bumps.** Prisma moves fast. Every major version changes something in the DMMF or generator API. Keeping up with Prisma 4 → 5 was non-trivial, but if your tool breaks on the latest Prisma version, people move on fast.

**All-contributors and good first issues.** 23 people have contributed to this project. Most of them found the repo through a bug they hit or a feature they needed. Making it easy to contribute — clear README, labeled issues, the all-contributors bot — turned users into maintainers.

## What I Learned

**Maintenance is the real work.** Writing the initial generator took a weekend. Maintaining it for 4+ years is an ongoing commitment. Dependency updates, Prisma compatibility, edge cases in schemas I'd never write — that's where the time goes.

**Puppeteer is a heavy dependency.** Mermaid CLI uses Puppeteer to render diagrams, which means downloading Chromium. It works, but it's the number one source of installation issues. If I were starting over, I'd explore lighter rendering options.

**Generators are an underrated Prisma feature.** Most people know about `prisma-client-js`, but the generator API is powerful. You get the full parsed schema as a typed object and can output anything. ERD diagrams, TypeGraphQL resolvers, Zod schemas, documentation — the possibilities are wide open.

**Stars don't equal quality, but they do equal feedback.** The real value of 1000+ stars isn't vanity — it's that 1000+ people used the tool and a meaningful percentage filed issues, suggested features, and submitted fixes. That feedback loop made the tool significantly better than anything I'd have built alone.

## Current State

The project is on v2.x now, supporting Prisma 5+. Still actively maintained, still getting PRs. It's the kind of project I'm proud of — not because it's technically complex, but because it reliably solves a real problem for a lot of people.

If you're using Prisma and don't have an ER diagram in your repo, give it a try:

```bash
npm i -D prisma-erd-generator @mermaid-js/mermaid-cli puppeteer
```

And if you find a bug, open an issue. Or better yet, a PR.
