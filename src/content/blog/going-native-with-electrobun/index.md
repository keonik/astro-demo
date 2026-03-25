---
title: "Going Native with Electrobun: Building a Desktop PDF Signer"
date: "Mar 25 2026"
draft: false
summary: Why I picked Electrobun over Electron for a desktop PDF signing app with PKCS#11 smart card integration, and what the Bun-native desktop experience is actually like.
tldr: Electrobun gives you Bun-native desktop apps without the Chromium tax. PKCS#11 smart card signing is painful but doable. The ecosystem is young but promising.
tags:
  - electrobun
  - bun
  - react
  - typescript
  - desktop
---

## Why Build a Desktop App in 2025?

PDF signing with hardware smart cards is one of those things that genuinely needs a desktop app. You're talking to a physical device plugged into a USB port through PKCS#11 — a C interface for cryptographic tokens. Browsers can't do this. Web Crypto API doesn't support external hardware tokens. You need native access.

So the question wasn't whether to build a desktop app — it was which framework to use.

## Why Not Electron?

I've built Electron apps before. It works. It also ships an entire Chromium browser with every install, uses 200MB+ of RAM at idle, and has a dependency tree that makes `node_modules` look modest.

For a focused utility app — open a PDF, sign it, save it — that's way too much overhead.

## Enter Electrobun

[Electrobun](https://electrobun.dev/) is a relatively new framework for building desktop apps with Bun. Instead of bundling Chromium, it uses the system's native webview (WebKit on macOS). The result:

- **Tiny bundles** — no Chromium download
- **Bun-native** — use Bun's FFI, fast startup, native modules
- **TypeScript-first** — the whole API is typed

It's still early (and honestly a bit rough around the edges), but for a Bun-heavy stack like mine, it felt like the natural choice.

## The PKCS#11 Challenge

PKCS#11 is the standard interface for talking to smart cards, HSMs, and other cryptographic hardware. It's a C API from the '90s, and it shows.

The flow for signing a PDF with a smart card looks like this:

1. Load the PKCS#11 shared library (`.dylib` / `.so` / `.dll`)
2. Initialize the library and find the token slot
3. Open a session and authenticate with the user's PIN
4. Find the signing key on the card
5. Hash the PDF content
6. Sign the hash using the private key on the card
7. Embed the signature into the PDF's signature field

Steps 1-6 happen through Bun's FFI (Foreign Function Interface), calling into the native PKCS#11 library. Step 7 requires understanding the PDF specification's signature structure — incremental saves, byte ranges, and PKCS#7 signature containers.

It's not glamorous work, but it's the kind of problem where a desktop app with native access genuinely shines. No server round-trips, no uploading sensitive documents to the cloud, no key material leaving the smart card.

## The Stack

- **Runtime**: Bun
- **Desktop framework**: Electrobun
- **UI**: React with TypeScript
- **Crypto**: PKCS#11 via Bun FFI
- **PDF manipulation**: Native PDF parsing and signature embedding

## What I'd Do Differently

**Test on Windows earlier.** Electrobun's macOS experience is the most polished. If you need cross-platform support, test early and often.

**Abstract the PKCS#11 layer more aggressively.** I started with direct FFI calls and refactored toward a cleaner abstraction as the complexity grew. Should have started there.

**Consider Tauri as an alternative.** Tauri is more mature and has a bigger community. I went with Electrobun because I wanted the full Bun experience, but Tauri would have been a safer choice for a production app.

## The Verdict

Electrobun is promising for Bun developers who need desktop apps. The developer experience is good, the bundle sizes are small, and having Bun's FFI available for native integration is a real differentiator. The ecosystem is young — expect rough edges — but for the right use case, it's worth exploring.

Just PDF is one of those projects where the tech stack choice was driven entirely by the requirements: native hardware access, small footprint, and a TypeScript-first developer experience. Electrobun checked all the boxes.
