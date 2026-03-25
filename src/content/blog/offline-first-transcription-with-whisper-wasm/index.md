---
title: "Offline-First Audio Transcription with Whisper.cpp in the Browser"
date: "Mar 25 2026"
draft: false
summary: How I built Transcriber I Hardly Knew Her — a privacy-first transcription app that records and transcribes audio entirely in the browser using Whisper.cpp compiled to WebAssembly.
tldr: Whisper.cpp compiles to WASM and runs entirely in the browser. IndexedDB via Dexie handles offline storage. No audio ever leaves the device. It's slower than server-side but the privacy tradeoff is worth it.
tags:
  - whisper
  - webassembly
  - react
  - typescript
  - pwa
  - privacy
---

## The Privacy Problem with Transcription

Every transcription service works the same way: upload your audio to a server, wait for it to process, get text back. That's fine for meeting notes. It's not fine for medical conversations, legal consultations, therapy sessions, or anything where the content is sensitive.

I wanted to build a transcription app where audio never leaves the device. Not "we promise we delete it" — actually never leaves. The only way to guarantee that is to do everything client-side.

## Whisper.cpp in the Browser

[Whisper.cpp](https://github.com/ggerganov/whisper.cpp) is a C/C++ port of OpenAI's Whisper model. It's fast, it's lightweight, and crucially — it compiles to WebAssembly.

The architecture:

1. **Record audio** in the browser using the MediaRecorder API
2. **Store the recording** in IndexedDB (never hits a server)
3. **Load the Whisper model** as a WASM module (downloaded once, cached locally)
4. **Transcribe** by passing audio samples to the WASM module
5. **Store the transcript** alongside the recording in IndexedDB

The Whisper model itself is about 75MB for the base model. It downloads once and gets cached by the browser. After that, everything runs offline.

## The Performance Reality

Let's be honest: WASM transcription is slower than server-side. A 5-minute recording might take 2-3 minutes to transcribe on a decent laptop. On a phone, longer. Server-side with GPU acceleration, the same recording transcribes in seconds.

But the tradeoff is explicit: **speed vs. privacy**. For the use cases I'm targeting — sensitive conversations where data sovereignty matters — the slower speed is acceptable. The audio literally cannot be intercepted because it never traverses a network.

## Offline-First with Dexie and IndexedDB

The entire data layer runs on [Dexie](https://dexie.org/), a wrapper around IndexedDB. The schema is straightforward:

```typescript
const db = new Dexie("TranscriberDB");

db.version(1).stores({
  subjects: "++id, name, createdAt",
  recordings: "++id, subjectId, blob, transcript, createdAt",
});
```

Everything — audio blobs, transcripts, metadata — lives in IndexedDB. The app works without any network connection after the initial load. Open it on a plane, record a conversation, transcribe it. No Wi-Fi needed.

## The Architecture

The app is structured as a monorepo with Turbo:

- **Client**: React + Vite + Tailwind CSS
- **Server**: Bun + Hono (handles auth only)
- **Transcription**: Whisper.cpp (WebAssembly, runs in client)
- **Client DB**: Dexie / IndexedDB
- **Server DB**: bun:sqlite (auth sessions only)

The server exists purely for multi-tenant authentication — separating profiles on shared devices. All the real work happens in the browser.

```
┌─────────────────────────────────────┐
│ Browser                              │
│ ┌─────────┐  ┌──────────────────┐   │
│ │ React UI│──│ Whisper.cpp WASM │   │
│ └────┬────┘  └──────────────────┘   │
│      │                               │
│ ┌────▼──────────────┐               │
│ │ Dexie / IndexedDB │               │
│ │ (audio + text)    │               │
│ └───────────────────┘               │
└─────────────────────────────────────┘
         │ (auth only)
    ┌────▼────┐
    │ Bun API │
    │ bun:sqlite│
    └─────────┘
```

## Hierarchical Organization

Transcriptions are organized as **Subjects → Recordings**. A subject might be a patient, a client, a project — whatever makes sense for the user's context. Each subject contains multiple recordings, each with its audio blob and transcript.

This maps well to real workflows. A therapist has patients. A journalist has interviews. A student has lectures. The hierarchy keeps things organized without being prescriptive about the use case.

## PWA: Install It Like an App

The whole thing is a Progressive Web App. Add it to your home screen and it behaves like a native app — full screen, offline support, its own icon. For a privacy-focused tool, this is ideal: no app store review process, no binary distribution, just a URL that works.

## What I'd Improve

**Web Workers for transcription.** Currently the WASM transcription runs on the main thread, which blocks the UI during processing. Moving it to a Web Worker would keep the interface responsive during long transcriptions.

**Streaming transcription.** Right now you record first, then transcribe. Real-time streaming transcription with Whisper is possible but significantly more complex — you need to handle chunking, context windows, and partial results.

**Model selection.** The base Whisper model is a good balance of size and accuracy. Offering the tiny model (faster, less accurate) and the small model (slower, more accurate) would let users choose their tradeoff.

## The Point

Privacy-first doesn't have to mean bad UX. WebAssembly makes it possible to run real ML models in the browser, IndexedDB provides robust local storage, and PWAs make web apps feel native.

Audio transcription is one of those problems where the server-side solution is so convenient that nobody questions sending their audio to a third party. Sometimes it's worth building the harder version.

[Try it at transcriberihardlyknewher.com](https://transcriberihardlyknewher.com)
