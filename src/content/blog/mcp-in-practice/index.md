---
title: "MCP in Practice: Connecting AI to Real Data Sources"
date: "Mar 25 2026"
draft: false
summary: What Model Context Protocol actually looks like in production — lessons from integrating MCP into Gameplan Network and Milli, beyond the hype.
tldr: MCP is a standard protocol for giving AI models access to tools and data. It works well for structured integrations. The protocol is simple but the implementation details matter — especially error handling, timeouts, and deciding what to expose.
tags:
  - ai
  - mcp
  - typescript
  - ai-sdk
---

## MCP Beyond the Hype

Model Context Protocol (MCP) is everywhere right now. Every AI tool announcement mentions it. Every framework supports it. But most of the content about MCP is either "here's what it is" or "here's a toy example." I've been using it in two real projects — [Gameplan Network](https://gameplannetwork.com) and [Milli](https://github.com/keonik/milli) — and the reality is both more useful and more nuanced than the marketing suggests.

## What MCP Actually Is

MCP is a protocol for connecting AI models to external tools and data sources. Think of it as a standardized way to say "the model can call these functions with these parameters and get these results."

Before MCP, every AI integration was bespoke. OpenAI had function calling. Anthropic had tool use. LangChain had tools. They all did roughly the same thing with slightly different interfaces. MCP standardizes the interface so a tool written once works with any model that speaks the protocol.

```typescript
// An MCP tool definition
{
  name: "search_crash_reports",
  description: "Search Ohio crash reports by date range, location, or involved parties",
  inputSchema: {
    type: "object",
    properties: {
      county: { type: "string", description: "Ohio county name" },
      dateFrom: { type: "string", format: "date" },
      dateTo: { type: "string", format: "date" },
    },
    required: ["county"],
  },
}
```

The model sees this definition, decides when to call it based on the user's request, and receives structured results back. The protocol handles the communication; you handle the implementation.

## Gameplan: MCP for Data Integration

Gameplan Network connects car crash victims with legal and medical services. The data pipeline involves crash reports, geocoding, contact databases, and outreach tracking. MCP gives the AI layer structured access to all of this.

The tools I've exposed via MCP:

- **Crash report search** — query by county, date range, severity
- **Contact lookup** — find chiropractors and attorneys by location
- **Geocoding** — resolve addresses to coordinates (backed by the Go geocoding API)
- **Outreach status** — check what contacts have been made for a given crash

The key insight: **MCP tools should be narrow and focused.** My first attempt was a single "query_database" tool that accepted raw SQL. That's technically powerful but practically useless — the model would generate bad queries, hit edge cases in the schema, and return confusing errors.

Breaking it into purpose-built tools with constrained inputs made the model significantly more reliable. Instead of generating SQL, it picks the right tool and fills in typed parameters.

## Milli: MCP with Local Models

[Milli](https://github.com/keonik/milli) is an AI interface that tries local open-source models before falling back to cloud APIs. MCP tool calling works the same way with both — the protocol doesn't care whether the model is running locally or in the cloud.

But the behavior is very different.

**Cloud models (GPT-4, Claude)** are excellent at tool calling. They understand complex tool descriptions, chain multiple calls together, and handle errors gracefully.

**Local models (8B-14B parameters)** are decent at single tool calls with simple schemas. Multi-step tool chains are unreliable. Complex parameter schemas confuse them. The smaller the model, the simpler your tools need to be.

My approach in Milli: start with the local model. If it fails to use the tool correctly (malformed parameters, wrong tool selection), fall back to a cloud model for that specific request. The local model handles the majority of simple queries; the cloud model handles the complex ones.

## Implementation with AI SDK

I'm using Vercel's [AI SDK](https://sdk.vercel.ai/) for the MCP integration. It abstracts the protocol layer and works with both local (via OpenAI-compatible APIs) and cloud providers:

```typescript
import { generateText, tool } from "ai";
import { z } from "zod";

const result = await generateText({
  model: yourModel,
  tools: {
    searchCrashReports: tool({
      description: "Search Ohio crash reports",
      parameters: z.object({
        county: z.string().describe("Ohio county name"),
        dateFrom: z.string().optional(),
        dateTo: z.string().optional(),
      }),
      execute: async ({ county, dateFrom, dateTo }) => {
        // Your actual data query
        return await db.crashReports.search({ county, dateFrom, dateTo });
      },
    }),
  },
  prompt: userMessage,
});
```

The `tool()` wrapper handles MCP serialization, parameter validation via Zod, and result formatting. Swap the model from a local Llama to GPT-4 and the same tools work without changes.

## Lessons Learned

**Timeouts matter more than you think.** Some tools hit external APIs or databases that can be slow. Without timeouts, the model sits waiting and the user gets a hung interface. Set aggressive timeouts and return meaningful error messages.

**Tool descriptions are prompts.** The quality of your tool's `description` field directly impacts how well the model uses it. Be specific: "Search Ohio crash reports by county and date range" beats "Search crash reports." Include examples in the description if the model struggles.

**Limit the tool count.** I started by exposing 12 tools to the model. It got confused and picked wrong ones regularly. Cutting to 5-6 focused tools improved accuracy significantly. If you need more, consider routing — use one tool to determine the category, then expose a focused set of tools for that category.

**Error handling is the whole game.** When a tool fails, the model needs to understand what went wrong. Return structured error messages, not stack traces. "No crash reports found for Delaware county in that date range" is useful. "TypeError: Cannot read property 'rows' of undefined" is not.

**Test with the dumbest model you support.** If your MCP tools work with a 3B parameter local model, they'll work with everything. This forces you to write clear descriptions, simple schemas, and robust error handling.

## The Verdict

MCP is a good standard solving a real problem. The protocol itself is simple and well-designed. The hard part isn't implementing MCP — it's designing good tools that models can actually use reliably.

If you're building AI features that need to interact with your data, MCP is the right protocol to use. Just be thoughtful about tool design, test with smaller models, and expect to iterate on your descriptions more than your implementation.
