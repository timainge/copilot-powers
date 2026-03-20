---
mode: agent
model: gpt-5.3-codex
tools: ["read", "edit", "search"]
description: "Synthesise system-level architecture document from subsystem summaries (CODEX — premium spend)"
---

# Synthesise System Architecture Document

**WARNING: This prompt uses a premium/codex model. It costs 1 premium request.**

Produce the top-level system architecture document from subsystem summaries.
This is the most durable and expensive artifact in the KB.

## Process

1. Read all `_subsystem.json` files from `/kb/index/`.
2. If `/kb/dependencies/graph.json` exists, read it for structural accuracy.
3. If `/kb/index/_system.json` already exists, read it — you are updating, not replacing from scratch.
4. Synthesise a comprehensive system architecture document covering:
   - **System purpose and scope**
   - **Subsystem inventory** with responsibilities and boundaries
   - **Inter-subsystem communication** patterns and data flows
   - **Key architectural decisions** (inferred from patterns observed)
   - **Domain model overview** (high-level entity relationships across subsystems)
   - **Tech debt landscape** (aggregated severity across subsystems)
   - **External integration points** (APIs, databases, message queues, third-party services)
5. Write to `/kb/index/_system.json`.

## Output Format

The system document is Markdown embedded in JSON for both machine and human readability:

```json
{
  "generated_at_sha": "<HEAD short SHA>",
  "generated_at": "<ISO 8601>",
  "subsystem_sources": ["<list of _subsystem.json files consulted>"],
  "system_doc": "<full Markdown document>"
}
```

## Important

- This is a CODEX task. Be thorough — this artifact is re-generated rarely.
- Ground every claim in specific KB artifacts. Cite source subsystem docs.
- If subsystem coverage is incomplete, note gaps explicitly in the document.
