---
title: "Running Local LLMs on Apple Silicon with MLX"
date: "Mar 25 2026"
draft: false
summary: A practical guide to running LLMs locally on Mac using MLX — what works, what's fast, and why local inference matters for developers.
tldr: MLX on Apple Silicon gives you 400+ tok/s for small models. Use vLLM-MLX for an OpenAI-compatible server. Great for development, prototyping, and privacy-sensitive workloads.
tags:
  - ai
  - mlx
  - apple-silicon
  - llm
  - python
---

## Why Run Models Locally?

Every AI API call costs money, has latency, and sends your data to someone else's server. For development and prototyping, that friction adds up:

- **Cost** — iterating on prompts against GPT-4 gets expensive fast
- **Latency** — network round-trips slow down your development loop
- **Privacy** — some data shouldn't leave your machine
- **Availability** — API rate limits and outages don't respect your deadlines

Running models locally solves all four. The tradeoff is capability — local models are smaller and less capable than the frontier APIs. But for development, testing, and many production workloads, they're more than good enough.

## MLX: Apple's Answer to PyTorch

[MLX](https://github.com/ml-explore/mlx) is Apple's machine learning framework, designed specifically for Apple Silicon. It's like PyTorch but optimized for the unified memory architecture in M-series chips.

The key advantage: Apple Silicon's unified memory means the GPU and CPU share the same RAM. A 16GB M2 MacBook can load models that would require a dedicated GPU with 16GB VRAM on other hardware. No copying tensors between CPU and GPU memory — it's all the same pool.

## vLLM-MLX: OpenAI-Compatible Local Server

The easiest way to get started is [vLLM-MLX](https://github.com/nicholascelesworthy/vllm-mlx), which gives you an OpenAI-compatible API server running on MLX. Your existing code that calls the OpenAI API works with zero changes — just point it at `localhost`.

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

Same OpenAI SDK, same API shape, running entirely on your Mac.

## What's Actually Fast?

Performance varies dramatically by model size and quantization. On an M2 Pro with 32GB RAM:

| Model | Size | Quantization | Speed |
|-------|------|-------------|-------|
| Llama 3.2 3B | ~2GB | 4-bit | 400+ tok/s |
| Llama 3.1 8B | ~4.5GB | 4-bit | ~150 tok/s |
| Qwen 2.5 14B | ~8GB | 4-bit | ~80 tok/s |
| Llama 3.1 70B | ~38GB | 4-bit | ~15 tok/s |

The 3B and 8B models are fast enough for real-time use. The 70B model is usable but you'll feel the wait. Anything larger needs more RAM than most Macs have.

## 4-bit Quantization: The Sweet Spot

Quantization reduces model precision to shrink the memory footprint. 4-bit quantization (Q4) cuts the size by ~4x with surprisingly minimal quality loss for most tasks.

The [MLX Community](https://huggingface.co/mlx-community) on Hugging Face maintains pre-quantized versions of popular models. Grab them directly:

```bash
# These are ready to use — no conversion needed
vllm-mlx --model mlx-community/Qwen2.5-Coder-14B-Instruct-4bit
```

For coding tasks specifically, I've found Qwen 2.5 Coder 14B to be the best balance of quality and speed on Apple Silicon.

## MCP + Local Models

One thing I've been experimenting with in [Milli](https://github.com/keonik/milli) is running MCP (Model Context Protocol) tools with local models. The idea is to try the local model first — if it handles the task, great, no API cost. If it can't, fall back to a cloud model.

The OpenAI-compatible API from vLLM-MLX means MCP tool calling works the same way it does with cloud APIs. Define your tools, pass them in the request, and the model decides whether to call them.

The practical limitation is that smaller models are worse at tool calling. A 3B model will miss complex multi-step tool use that GPT-4 handles easily. The 14B+ models are much more reliable, but slower.

## When Local Makes Sense

**Great for:**
- Development and prototyping (fast iteration, no cost)
- Privacy-sensitive workloads (data never leaves your machine)
- Coding assistance (Qwen Coder is legitimately good)
- Embeddings and RAG (small embedding models run very fast locally)

**Not great for:**
- Production serving at scale (use cloud GPUs)
- Tasks requiring frontier model capability (GPT-4, Claude)
- Long context windows (local models are typically limited to 8-32K)

## Getting Started

```bash
# 1. Install
pip install vllm-mlx

# 2. Pick a model (start small)
vllm-mlx --model mlx-community/Llama-3.2-3B-Instruct-4bit

# 3. Point your app at localhost
# baseURL: "http://localhost:8000/v1"
```

That's it. Five minutes from zero to a local LLM server. The Apple Silicon hardware you already own is more capable than you think — you just need the right software to unlock it.
