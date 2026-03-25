---
title: "Transcriber I Hardly Knew Her"
summary: "Privacy-first, offline-first audio transcription app. Record and transcribe locally in the browser using Whisper.cpp — no audio leaves your device."
demoUrl: https://transcriberihardlyknewher.com
tags:
  - react
  - typescript
  - whisper
  - bun
  - hono
  - pwa
date: 2025-12-28
draft: false
---

A privacy-focused transcription application that records audio locally in the browser and performs transcription using Whisper.cpp compiled to WebAssembly. Audio never leaves the device unless you choose to export it.

Built with React + Vite on the frontend, Bun + Hono on the backend, and Dexie/IndexedDB for offline-first client-side persistence. Features multi-tenant auth, hierarchical organization (Subjects → Recordings), theme presets, and PWA support.
