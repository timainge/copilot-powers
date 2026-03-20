---
mode: agent
model: gpt-5-mini
tools: ["read", "edit", "search"]
description: "Synthesise subsystem-level summaries from module-level KB entries"
---

# Synthesise Subsystem Summaries

Roll up module-level KB summaries into subsystem-level descriptions.

## Process

1. Read `/kb/index/` structure to identify subsystem boundaries.
   Subsystems are typically top-level directories under `src/` (e.g., `src/Api/`,
   `src/Domain/`, `src/Infrastructure/`). Adapt to the actual repo structure.
2. For each subsystem:
   a. Read all `_dir.json` (module summaries) within the subsystem.
   b. Synthesise a subsystem summary covering:
      - **Purpose:** What role does this subsystem play in the overall architecture?
      - **Modules:** List of modules with brief role descriptions.
      - **External interfaces:** How other subsystems or external consumers interact with it.
      - **Key domain concepts:** Most important business concepts owned by this subsystem.
      - **Architecture patterns:** Observable patterns (e.g., repository pattern, CQRS, event-driven).
      - **Cross-cutting concerns:** Logging, auth, caching strategies observed.
   c. Write to `/kb/index/{subsystem}/_subsystem.json`.

## Output Schema

```json
{
  "generated_at_sha": "<HEAD short SHA>",
  "generated_at": "<ISO 8601>",
  "subsystem": "<subsystem path>",
  "purpose": "<1-3 sentences>",
  "modules": [{"name": "...", "role": "..."}],
  "external_interfaces": [{"consumer": "...", "mechanism": "...", "description": "..."}],
  "domain_concepts": ["<key concepts owned by this subsystem>"],
  "architecture_patterns": ["<observed patterns>"],
  "cross_cutting_concerns": ["<observed concerns>"],
  "tech_debt_summary": {"high": 0, "medium": 0, "low": 0}
}
```

## Important

- Work entirely from module `_dir.json` files. Do NOT read file-level summaries or source.
- This is a mini-model task — no premium quota spend.
