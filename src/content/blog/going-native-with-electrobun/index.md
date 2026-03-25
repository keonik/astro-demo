---
title: "Going Native with Electrobun: Building a Desktop PDF Signer"
date: "Mar 25 2026"
draft: false
summary: Why I picked Electrobun over Electron for a desktop PDF signing app with PKCS#11 smart card integration, and what the Bun-native desktop experience is actually like.
tldr: Electrobun gives you Bun-native desktop apps without the Chromium tax. PKCS#11 smart card signing is painful but doable through Bun FFI. Young ecosystem but promising for the right use case.
tags:
  - electrobun
  - bun
  - react
  - typescript
  - desktop
---

## Why a desktop app in 2025?

I know, I know. Everything should be a web app. But hear me out.

PDF signing with hardware smart cards is one of those things that genuinely needs native access. You're talking to a physical device through PKCS#11 — a C interface for cryptographic tokens. Browsers can't do this. Web Crypto API doesn't support external hardware tokens. You need to talk to a USB port.

![Dwight - I'm fast](https://media.giphy.com/media/TL6poLzwbHuF2/giphy.gif)

So the question wasn't whether to build a desktop app — it was which framework to use.

## Why not Electron?

I've built Electron apps before. It works. It also ships an entire Chromium browser with every install. For a focused utility app — open a PDF, sign it, save it — that's like renting a moving truck to go get coffee.

200MB+ of RAM at idle. A dependency tree that makes `node_modules` look modest. For what? A file picker and a signature button.

![Michael Scott - No](https://media.giphy.com/media/12XMGIWtrHBl5e/giphy.gif)

## Enter Electrobun

[Electrobun](https://electrobun.dev/) is a relatively new framework for building desktop apps with Bun. Instead of bundling Chromium, it uses the system's native webview (WebKit on macOS). The result:

- **Tiny bundles** — no Chromium download
- **Bun-native** — use Bun's FFI, fast startup, native modules
- **TypeScript-first** — the whole API is typed

It's still early and honestly a bit rough around the edges. But for a Bun-heavy stack like mine, it felt like the natural choice.

## The PKCS#11 adventure

PKCS#11 is the standard interface for talking to smart cards, HSMs, and other cryptographic hardware. It's a C API from the '90s. And it shows.

![Stanley - Did I stutter](https://media.giphy.com/media/SqmkZ5IdwzTP2/giphy.gif)

The flow for signing a PDF with a smart card:

1. Load the PKCS#11 shared library (`.dylib` / `.so` / `.dll`)
2. Initialize the library and find the token slot
3. Open a session and authenticate with the user's PIN
4. Find the signing key on the card
5. Hash the PDF content
6. Sign the hash using the private key on the card
7. Embed the signature into the PDF's signature field

Steps 1-6 happen through Bun's FFI (Foreign Function Interface), calling into the native PKCS#11 library. Step 7 requires understanding the PDF specification's signature structure — incremental saves, byte ranges, and PKCS#7 signature containers.

It's not glamorous work. But it's the kind of problem where a desktop app with native access genuinely shines. No server round-trips, no uploading sensitive documents to the cloud, no key material leaving the smart card.

## The stack

- **Runtime**: Bun
- **Desktop framework**: Electrobun
- **UI**: React with TypeScript
- **Crypto**: PKCS#11 via Bun FFI
- **PDF**: Native PDF parsing and signature embedding

Nothing too wild individually. The interesting part is how they all fit together in a desktop context.

## Lessons from the trenches

### Test on other platforms early

Electrobun's macOS experience is the most polished. If you need cross-platform, test early and often. Don't ask me how I learned this.

![Jim - Camera stare](https://media.giphy.com/media/6JB4v4xPTAQFi/giphy.gif)

### Abstract the PKCS#11 layer aggressively

I started with direct FFI calls scattered everywhere and refactored toward a cleaner abstraction as the complexity grew. Should have started there. Direct C interop calls throughout your React app is... not great for readability.

### Consider Tauri as an alternative

Tauri is more mature and has a bigger community. I went with Electrobun because I wanted the full Bun experience, but Tauri would have been a safer choice for a production app. If you're evaluating both, try Tauri first and switch to Electrobun only if you specifically need Bun's runtime.

## Would I use Electrobun again?

For the right use case — yes. A focused desktop app where you need native access and you're already in the Bun ecosystem? It's a solid fit. For a complex cross-platform app with lots of native integrations? Probably go Tauri or even Electron (I know, I know).

Just PDF is one of those projects where the tech stack was driven entirely by the requirements: native hardware access, small footprint, and TypeScript-first DX. Electrobun checked all the boxes.

![Michael Scott - That's what I'm talking about](https://media.giphy.com/media/MNmyTin5qt5LSXirUd/giphy.gif)
