---
title: "MCP in Practice: Connecting AI to Real Data Sources"
date: "Mar 25 2026"
draft: false
summary: What Model Context Protocol actually looks like in production — lessons from integrating MCP into Gameplan Network and Milli, beyond the hype.
tldr: MCP standardizes how AI models access tools and data. The protocol is simple but tool design is everything — keep tools narrow, descriptions specific, and test with the dumbest model you support.
tags:
  - ai
  - mcp
  - typescript
  - ai-sdk
---

## MCP beyond the hype

Model Context Protocol is everywhere right now. Every AI tool announcement mentions it. Every framework supports it. But most content about MCP is either "here's what it is" or "here's a toy example."

I've been using it in two real projects — [Gameplan Network](https://gameplannetwork.com) and [Milli](https://github.com/keonik/milli) — and the reality is more nuanced than the marketing suggests. Let's get into it.

![Michael Scott - I'm ready](https://media.giphy.com/media/ui1hpFSyBDWlG/giphy.gif)

## What MCP actually is

MCP is a protocol for connecting AI models to external tools and data sources. A standardized way to say "the model can call these functions with these parameters and get these results."

Before MCP, every AI integration was bespoke. OpenAI had function calling. Anthropic had tool use. LangChain had tools. They all did roughly the same thing with slightly different interfaces. MCP standardizes it so a tool written once works with any model that speaks the protocol.

```typescript
{
  name: "search_crash_reports",
  description: "Search Ohio crash reports by date range and county",
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

The model sees this, decides when to call it, and receives structured results. The protocol handles communication; you handle implementation.

## Gameplan: MCP for data integration

Gameplan Network connects car crash victims with legal and medical services. The data pipeline involves crash reports, geocoding, contact databases, and outreach tracking. MCP gives the AI layer structured access to all of this.

The tools I've exposed:

- **Crash report search** — query by county, date range, severity
- **Contact lookup** — find chiropractors and attorneys by location
- **Geocoding** — resolve addresses to coordinates
- **Outreach status** — check what contacts have been made

### The lesson: narrow tools > broad tools

My first attempt was a single "query_database" tool that accepted raw SQL. Technically powerful. Practically useless.

![Dwight - False](https://media.giphy.com/media/3kIcyN7fUtlUA/giphy.gif)

The model would generate bad queries, hit edge cases in the schema, and return confusing errors. Breaking it into purpose-built tools with constrained inputs made it significantly more reliable. Instead of generating SQL, it picks the right tool and fills in typed parameters.

## Milli: MCP with local models

[Milli](https://github.com/keonik/milli) is an AI interface that tries local open-source models before falling back to cloud APIs. MCP tool calling works the same way with both — the protocol doesn't care whether the model is running locally or in the cloud.

But the **behavior** is very different.

**Cloud models (GPT-4, Claude)** are excellent at tool calling. They understand complex tool descriptions, chain multiple calls, and handle errors gracefully.

**Local models (8B-14B)** are decent at single tool calls with simple schemas. Multi-step tool chains? Unreliable. Complex parameter schemas? Confusing. The smaller the model, the simpler your tools need to be.

My approach: start with the local model. If it fails to use the tool correctly, fall back to cloud for that specific request. Local handles the majority of simple queries; cloud handles the complex ones.

![Jim - Balanced](https://media.giphy.com/media/GCvktC0KFy9l6/giphy.gif)

## Implementation with AI SDK

I'm using Vercel's [AI SDK](https://sdk.vercel.ai/) for the MCP integration. It abstracts the protocol layer and works with both local and cloud providers:

```typescript
import { generateText, tool } from "ai";
import { z } from "zod";

const result = await generateText({
  model: yourModel,
  tools: {
    searchCrashReports: tool({
      description: "Search Ohio crash reports by county and date range",
      parameters: z.object({
        county: z.string().describe("Ohio county name"),
        dateFrom: z.string().optional(),
        dateTo: z.string().optional(),
      }),
      execute: async ({ county, dateFrom, dateTo }) => {
        return await db.crashReports.search({ county, dateFrom, dateTo });
      },
    }),
  },
  prompt: userMessage,
});
```

The `tool()` wrapper handles MCP serialization, Zod parameter validation, and result formatting. Swap the model from local Llama to GPT-4 and the same tools work. Zero changes.

## Lessons learned

### Timeouts matter more than you think

Some tools hit external APIs or databases that can be slow. Without timeouts, the model sits waiting and the user gets a hung interface. Set aggressive timeouts and return meaningful error messages.

### Tool descriptions are prompts

The quality of your tool's `description` field directly impacts how well the model uses it. "Search Ohio crash reports by county and date range" beats "Search crash reports." Be specific. Include examples if the model struggles.

### Limit the tool count

I started by exposing 12 tools. The model got confused and picked wrong ones regularly. Cutting to 5-6 focused tools improved accuracy significantly.

![Kevin - Why use many tools when few tools do trick](https://media.giphy.com/media/TfWhFbURIirNtbOlas/giphy.gif)

If you need more, consider routing — use one tool to determine the category, then expose a focused subset.

### Error handling is the whole game

When a tool fails, the model needs to understand what went wrong. "No crash reports found for Delaware county in that date range" is useful. "TypeError: Cannot read property 'rows' of undefined" is not.

Return structured error messages. Not stack traces.

### Test with the dumbest model you support

If your MCP tools work with a 3B parameter local model, they'll work with everything. This forces clear descriptions, simple schemas, and robust error handling. It's like building your UI for mobile first — if it works on the smallest screen, it works everywhere.

## The verdict

MCP is a good standard solving a real problem. The protocol itself is simple and well-designed. The hard part isn't implementing MCP — it's designing good tools that models can actually use reliably.

If you're building AI features that interact with your data, MCP is the right protocol. Just be thoughtful about tool design, test with smaller models, and expect to iterate on your descriptions more than your implementation 🎉

![Michael Scott - I knew exactly what to do](https://media.giphy.com/media/OcZp0maz6ALok/giphy.gif)
