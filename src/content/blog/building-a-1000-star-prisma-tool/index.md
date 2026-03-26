---
title: "Building a 1000⭐ Open Source Prisma Tool"
date: "Jul 15 2024"
draft: false
summary: How prisma-erd-generator went from a weekend hack to 1000+ stars, 64 forks, and 23 contributors — and what I learned maintaining open source along the way.
tldr: Solve your own problem, make it a Prisma generator so it runs automatically, make it easy to contribute, and be patient. Stars come from solving real pain points.
tags:
  - open-source
  - prisma
  - typescript
  - mermaidjs
---

## Story time

Back in 2021 I was deep in a project with a growing Prisma schema. Like... really growing. I kept scrolling through `schema.prisma` trying to hold the mental model in my head. Models, relations, one-to-many, many-to-many... I'd inevitably miss something and break a query.

![Michael Scott - I am dead inside](https://media.giphy.com/media/ISOckXUybVfQ4/giphy.gif)

[@Skn0tt](https://github.com/Skn0tt) had already built a [web app](https://prisma-erd.simonknott.de/) that could generate ER diagrams from Prisma schemas. Super useful! But I wanted something that ran automatically. Every single time I hit `npx prisma generate`, I wanted a fresh diagram sitting in my repo. No extra steps. No extra commands.

So I built [prisma-erd-generator](https://github.com/keonik/prisma-erd-generator). Because I'm lazy in the best possible way 😊

## How it works

The concept is honestly dead simple. It's a Prisma generator. You add it to your `schema.prisma`:

```prisma
generator erd {
  provider = "prisma-erd-generator"
}
```

Run `npx prisma generate`, and boom — ER diagram as SVG, PNG, PDF, or Markdown. Under the hood it parses the Prisma DMMF (Data Model Meta Format), converts it to a Mermaid.js diagram definition, and renders it using `@mermaid-js/mermaid-cli`.

The key insight was making it a **generator** rather than a standalone CLI. Prisma generators hook into the existing workflow. Developers don't have to remember an extra command or add a build step. It just... happens.

![Michael Scott - That's what she said](https://media.giphy.com/media/5xtDarIELDLO7lSFQJi/giphy.gif)

## Making it configurable

People started using it and immediately had opinions. Good opinions! I added options incrementally based on what folks asked for:

```prisma
generator erd {
  provider = "prisma-erd-generator"
  output = "../docs/ERD.svg"
  theme = "forest"
  disableEmoji = true
}
```

Output format, themes, disabling specific models, table-only mode. Each one was a small PR but made the tool work for more use cases. The lesson here: **ship the minimal thing first, then let your users tell you what's missing.**

## Getting to 1000 stars

It didn't happen overnight. The repo sat at double-digit stars for a long while. I'd check periodically and wonder if anyone was even using this thing.

![Dwight - Waiting](https://media.giphy.com/media/FoH28ucxZFJZu/giphy.gif)

A few things helped it grow:

### Solving a real pain point

Every team with a non-trivial Prisma schema eventually wants to visualize it. I wasn't the only one scrolling through 500-line schema files. Turns out a lot of people were doing the same thing and just suffering in silence 💪

### Supporting Prisma version bumps

Prisma moves FAST. Every major version changes something in the DMMF or generator API. Keeping up with Prisma 4 → 5 was non-trivial. But here's the thing — if your tool breaks on the latest Prisma version, people move on **immediately**. Staying compatible is the price of admission.

### Making it easy to contribute

23 people have contributed to this project! Most of them found the repo through a bug they hit or a feature they needed. Clear README, labeled issues, the all-contributors bot — it turns users into maintainers.

![Michael Scott - You get a car](https://media.giphy.com/media/ui1hpFSyBDWlG/giphy.gif)

## What I learned maintaining open source

### Maintenance is the real work

Writing the initial generator took a weekend. Maintaining it for 4+ years is an ongoing commitment. Dependency updates, Prisma compatibility, edge cases in schemas I'd never write — that's where the actual time goes. If you think shipping v1 is the hard part...

![Dwight - False](https://media.giphy.com/media/3kIcyN7fUtlUA/giphy.gif)

### Puppeteer is a heavy dependency

Mermaid CLI uses Puppeteer to render diagrams, which means downloading Chromium. It works, but it's the number one source of installation issues. Every other GitHub issue is "Puppeteer won't install on my CI." If I were starting over, I'd explore lighter rendering options.

### Generators are underrated

Most people know about `prisma-client-js`, but the generator API is powerful. You get the full parsed schema as a typed object and can output anything. ERD diagrams, TypeGraphQL resolvers, Zod schemas, documentation — the possibilities are wide open. If you've got a repetitive task around your Prisma schema, a generator can probably automate it.

### Stars ≠ quality, but stars = feedback

The real value of 1000+ stars isn't vanity — it's that 1000+ people used the tool and a meaningful percentage filed issues, suggested features, and submitted fixes. That feedback loop made the tool significantly better than anything I'd have built alone.

## Current state

The project is on v2.x now, supporting Prisma 5+. Still actively maintained, still getting PRs. It's the kind of project I'm proud of — not because it's technically complex, but because it reliably solves a real problem for a lot of people.

If you're using Prisma and don't have an ER diagram in your repo, give it a try:

```bash
npm i -D prisma-erd-generator @mermaid-js/mermaid-cli puppeteer
```

And if you find a bug, open an issue. Or better yet, a PR 🎉

![Michael Scott - I love you guys](https://media.giphy.com/media/OcZp0maz6ALok/giphy.gif)
