---
title: "Running Local LLMs on Apple Silicon with MLX"
date: "Feb 2 2026"
draft: false
summary: A practical guide to running LLMs locally on Mac using MLX — what works, what's fast, and why local inference matters for developers.
tldr: MLX on Apple Silicon gives you 400+ tok/s for small models. Use vLLM-MLX for an OpenAI-compatible server. Great for development, prototyping, and privacy-sensitive workloads. Five minute setup.
tags:
  - ai
  - mlx
  - apple-silicon
  - llm
  - python
---

## Why run models locally?

Every AI API call costs money, has latency, and sends your data to someone else's server. For development and prototyping, that friction adds up fast:

- **Cost** — iterating on prompts against GPT-4 gets expensive
- **Latency** — network round-trips slow down your dev loop
- **Privacy** — some data shouldn't leave your machine
- **Availability** — API rate limits don't respect your deadlines

Running models locally solves all four. The tradeoff is capability — local models are smaller and less capable than frontier APIs. But for development, testing, and many production workloads? More than good enough.

![Dwight - I can do anything better than you can](https://media.giphy.com/media/3kIcyN7fUtlUA/giphy.gif)

## MLX: Apple's answer

[MLX](https://github.com/ml-explore/mlx) is Apple's machine learning framework, designed specifically for Apple Silicon. Think PyTorch but optimized for the unified memory architecture in M-series chips.

The key advantage: Apple Silicon's unified memory means the GPU and CPU share the same RAM. A 16GB M2 MacBook can load models that would require a dedicated GPU with 16GB VRAM on other hardware. No copying tensors between CPU and GPU memory — it's all the same pool.

This is honestly one of the best things about Apple Silicon for ML work. The hardware you already own might be more capable than you think.

## vLLM-MLX: OpenAI-compatible local server

The easiest way to get started is [vLLM-MLX](https://github.com/nicholascelesworthy/vllm-mlx). It gives you an OpenAI-compatible API server running on MLX. Your existing code that calls the OpenAI API works with **zero changes** — just point it at `localhost`.

```bash
# Install
pip install vllm-mlx

# Start with a model
vllm-mlx --model mlx-community/Llama-3.2-3B-Instruct-4bit
```

Now you have a local server at `http://localhost:8000` that speaks the OpenAI API:

```typescript
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "http://localhost:8000/v1",
  apiKey: "not-needed",
});

const response = await client.chat.completions.create({
  model: "mlx-community/Llama-3.2-3B-Instruct-4bit",
  messages: [{ role: "user", content: "Explain PKCS#11 in simple terms" }],
});
```

Same OpenAI SDK. Same API shape. Running entirely on your Mac. The `apiKey` is literally "not-needed" because there's nobody to authenticate with 😊

![Michael Scott - It's happening](https://media.giphy.com/media/MNmyTin5qt5LSXirUd/giphy.gif)

## What's actually fast?

Performance varies dramatically by model size and quantization. Here's what I've seen on an M2 Pro with 32GB RAM:

- **Llama 3.2 3B** (4-bit, ~2GB) — 400+ tok/s 🔥
- **Llama 3.1 8B** (4-bit, ~4.5GB) — ~150 tok/s
- **Qwen 2.5 14B** (4-bit, ~8GB) — ~80 tok/s
- **Llama 3.1 70B** (4-bit, ~38GB) — ~15 tok/s

The 3B and 8B models are fast enough for real-time use. The 70B model is usable but you'll feel the wait. Anything larger needs more RAM than most Macs have.

## 4-bit quantization: the sweet spot

Quantization reduces model precision to shrink the memory footprint. 4-bit quantization (Q4) cuts the size by ~4x with surprisingly minimal quality loss for most tasks.

The [MLX Community](https://huggingface.co/mlx-community) on Hugging Face maintains pre-quantized versions of popular models. Grab them directly — no conversion needed:

```bash
vllm-mlx --model mlx-community/Qwen2.5-Coder-14B-Instruct-4bit
```

For coding tasks specifically, I've found **Qwen 2.5 Coder 14B** to be the best balance of quality and speed on Apple Silicon. It's legitimately good at code generation and review.

![Jim - Impressed](https://media.giphy.com/media/GCvktC0KFy9l6/giphy.gif)

## Local models + MCP

One thing I've been experimenting with in [Milli](https://github.com/keonik/milli) is running MCP tools with local models. The idea: try the local model first. If it handles the task, great — no API cost. If it can't, fall back to a cloud model.

The OpenAI-compatible API means MCP tool calling works the same way as with cloud APIs. Define your tools, pass them in the request, done.

The practical limitation: smaller models are worse at tool calling. A 3B model will miss complex multi-step tool use that GPT-4 handles easily. The 14B+ models are much more reliable, but slower. It's a tradeoff.

## When local makes sense

**Great for:**
- Development and prototyping (fast iteration, no cost)
- Privacy-sensitive workloads (data stays on your machine)
- Coding assistance (Qwen Coder is genuinely good)
- Embeddings and RAG (small embedding models run fast locally)

**Not great for:**
- Production serving at scale (use cloud GPUs)
- Tasks requiring frontier capability (GPT-4, Claude)
- Long context windows (local models typically cap at 8-32K)

## Getting started

```bash
# 1. Install
pip install vllm-mlx

# 2. Pick a model (start small)
vllm-mlx --model mlx-community/Llama-3.2-3B-Instruct-4bit

# 3. Point your app at localhost
# baseURL: "http://localhost:8000/v1"
```

Five minutes from zero to a local LLM server. If you've got an M-series Mac, you're already set 🎉

![Michael Scott - You have no idea how high I can fly](https://media.giphy.com/media/GCSIwtwqAMBTq/giphy.gif)
