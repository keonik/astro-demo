---
title: "Gameplan Network"
summary: "Full-stack platform connecting car crash victims with legal and medical services. Crash report analysis, lead generation, and outreach coordination."
demoUrl: https://gameplannetwork.com
tags:
  - typescript
  - react
  - bun
  - hono
  - postgresql
  - tailwindcss
  - tanstack-router
date: 2025-06-01
draft: false
---

A full-stack TypeScript application that connects car crash victims with legal and medical services in Ohio. Features crash report analysis, lead generation, and outreach coordination for chiropractors and attorneys.

Built as a Turbo monorepo with Bun + Hono on the backend, React 19 + TanStack Router on the frontend, PostgreSQL + PostGIS with Drizzle ORM for the database layer, and Better Auth for authentication. Uses a worker process architecture to keep the main server lightweight — heavy dependencies like googleapis and langchain run as short-lived child processes.
