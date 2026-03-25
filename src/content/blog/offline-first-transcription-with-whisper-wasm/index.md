---
title: "Offline-First Audio Transcription with Whisper.cpp in the Browser"
date: "Jan 18 2026"
draft: false
summary: How I built Transcriber I Hardly Knew Her — a privacy-first transcription app that records and transcribes audio entirely in the browser using Whisper.cpp compiled to WebAssembly.
tldr: Whisper.cpp compiles to WASM and runs in the browser. IndexedDB via Dexie handles offline storage. Audio never leaves the device. Slower than server-side but the privacy tradeoff is worth it.
tags:
  - whisper
  - webassembly
  - react
  - typescript
  - pwa
  - privacy
---

## The privacy problem

Every transcription service works the same way: upload your audio, wait for processing, get text back. Fine for meeting notes. Not fine for medical conversations, legal consultations, therapy sessions, or anything where the content is sensitive.

"We promise we delete it" isn't good enough. I wanted a transcription app where audio **never** leaves the device. The only way to guarantee that is to do everything client-side.

![Dwight - Security threat](https://media.giphy.com/media/tlGD7PDy1w8fK/giphy.gif)

## Whisper.cpp in the browser

[Whisper.cpp](https://github.com/ggerganov/whisper.cpp) is a C/C++ port of OpenAI's Whisper model. It's fast, it's lightweight, and crucially — it compiles to WebAssembly.

The architecture:

1. **Record audio** in the browser using the MediaRecorder API
2. **Store the recording** in IndexedDB (never hits a server)
3. **Load the Whisper model** as a WASM module (downloaded once, cached locally)
4. **Transcribe** by passing audio samples to the WASM module
5. **Store the transcript** alongside the recording in IndexedDB

The Whisper model itself is about 75MB for the base model. Downloads once, gets cached by the browser. After that, everything runs offline. Airplane mode? No problem.

![Michael Scott - I declare privacy](https://media.giphy.com/media/8VrtSBgi5MnuTSJTYJ/giphy.gif)

## Let's be honest about performance

WASM transcription is slower than server-side. A 5-minute recording might take 2-3 minutes to transcribe on a decent laptop. On a phone, longer. Server-side with GPU acceleration, the same recording transcribes in seconds.

But the tradeoff is explicit: **speed vs. privacy**. For the use cases I'm targeting — sensitive conversations where data sovereignty matters — slower speed is acceptable. The audio literally cannot be intercepted because it never traverses a network.

Worth it? For this use case, absolutely.

## Offline-first with Dexie

The entire data layer runs on [Dexie](https://dexie.org/), a wrapper around IndexedDB:

```typescript
const db = new Dexie("TranscriberDB");

db.version(1).stores({
  subjects: "++id, name, createdAt",
  recordings: "++id, subjectId, blob, transcript, createdAt",
});
```

Everything — audio blobs, transcripts, metadata — lives in IndexedDB. The app works without any network connection after the initial load. Open it on a plane, record a conversation, transcribe it. No Wi-Fi needed.

![Kevin - Nice](https://media.giphy.com/media/ynRrAHj5SWAu8RA002/giphy.gif)

## The architecture

The app is a Turbo monorepo:

- **Client**: React + Vite + Tailwind CSS
- **Server**: Bun + Hono (handles auth only)
- **Transcription**: Whisper.cpp (WebAssembly, runs in client)
- **Client DB**: Dexie / IndexedDB
- **Server DB**: bun:sqlite (auth sessions only)

The server exists purely for multi-tenant authentication — separating profiles on shared devices. That's it. All the real work happens in the browser.

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

## Organizing transcriptions

Transcriptions are organized as **Subjects → Recordings**. A subject might be a patient, a client, a project — whatever makes sense. Each subject contains multiple recordings with their audio and transcript.

A therapist has patients. A journalist has interviews. A student has lectures. The hierarchy keeps things organized without being prescriptive about the use case.

## PWA: install it like an app

The whole thing is a Progressive Web App. Add it to your home screen and it behaves like a native app — full screen, offline support, its own icon. For a privacy-focused tool, this is ideal: no app store review process, no binary distribution, just a URL that works.

![Dwight - It's beautiful](https://media.giphy.com/media/ZB95y3XSFbljaNu7mT/giphy.gif)

## What I'd improve

**Web Workers for transcription.** Currently the WASM runs on the main thread, which blocks the UI during processing. Moving it to a Web Worker would keep things responsive during long transcriptions.

**Streaming transcription.** Right now you record first, then transcribe. Real-time streaming with Whisper is possible but significantly more complex — chunking, context windows, partial results.

**Model selection.** The base model is a good balance of size and accuracy. Offering tiny (faster, less accurate) and small (slower, more accurate) would let users choose their tradeoff.

## The point

Privacy-first doesn't have to mean bad UX. WebAssembly makes it possible to run real ML models in the browser, IndexedDB provides robust local storage, and PWAs make web apps feel native.

Sometimes it's worth building the harder version. Your users' data is worth it.

[Try it at transcriberihardlyknewher.com](https://transcriberihardlyknewher.com) 🎉

![Michael Scott - I'm not crying](https://media.giphy.com/media/OcZp0maz6ALok/giphy.gif)
