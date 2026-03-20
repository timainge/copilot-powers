---
mode: agent
model: gpt-5-mini
tools: ["read", "edit", "search"]
description: "Synthesise module-level summaries from file-level KB entries"
---

# Synthesise Module Summaries

Roll up file-level KB summaries into module-level descriptions.

## Process

1. List all directories under `/kb/index/` that contain file summaries.
2. For each directory (module):
   a. Read all `*.json` files in that directory (excluding `_dir.json`).
   b. Synthesise a module summary covering:
      - **Purpose:** What does this module do as a whole?
      - **Key components:** Most important classes/files and their roles.
      - **Public API:** Aggregated public surface (key entry points only, not exhaustive).
      - **Dependencies:** External and internal module dependencies.
      - **Domain concepts:** Union of domain concepts from all files.
      - **Tech debt summary:** Aggregated, most severe items highlighted.
   c. Write the result to `/kb/index/{module}/_dir.json`.

## Output Schema

```json
{
  "generated_at_sha": "<HEAD short SHA>",
  "generated_at": "<ISO 8601>",
  "module": "<module path>",
  "purpose": "<1-3 sentences>",
  "key_components": [{"file": "...", "role": "..."}],
  "public_api": [{"name": "...", "signature": "...", "description": "..."}],
  "internal_dependencies": ["<other modules this depends on>"],
  "external_dependencies": ["<NuGet/npm packages>"],
  "domain_concepts": ["<aggregated>"],
  "tech_debt_summary": {"high": 0, "medium": 0, "low": 0, "top_items": []}
}
```

## Important

- Do NOT read raw source files. Work entirely from existing KB file summaries.
- This is a mini-model task — no premium quota spend.
