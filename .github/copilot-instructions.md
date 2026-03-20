# Copilot Instructions

## Knowledge Base System

This repository contains a codebase intelligence system built on Copilot-native
primitives. The `/kb/` directory is the persistent knowledge base.

## Model Routing Rules

| Task | Model | Prompt/Agent | Cost |
|------|-------|--------------|------|
| File-level extraction | mini | `explore-codebase` prompt | Free |
| Module synthesis | mini | `synthesise-modules` prompt | Free |
| Subsystem synthesis | mini | `synthesise-subsystems` prompt | Free |
| System architecture doc | **codex** | `synthesise-system` prompt | 1 premium |
| Architecture analysis | **codex** | `architecture-analysis` prompt | 1 premium |
| Domain extraction | mini | `kb-domain-extractor` agent | Free |
| Task decomposition | **codex** | `task-decompose` prompt | 1 premium |
| Task execution | mini | `kb-executor` agent | Free |
| KB delta refresh | mini | `kb-refresh` prompt | Free |

**Rule:** Always start with the cheapest option. Only escalate to codex when
synthesis or architectural reasoning is required.

## KB-First Retrieval

Before reading raw source files, check if a KB summary exists:
1. Search `/kb/index/{file-path}.json` for file-level summaries.
2. Search `/kb/index/{module}/_dir.json` for module summaries.
3. Use the `kb` MCP server tools for search: `kb_search`, `get_file_summary`, etc.

Only read raw source when the KB entry is missing or explicitly marked stale.

## Agent Constraints

- `kb-explorer` and `kb-domain-extractor`: write only to `/kb/`.
- `kb-architect`: read-only, writes only to `/kb/architecture/`.
- `kb-executor`: follows plan files in `/kb/tasks/`, writes code and progress.

## Build Sequence

See `PLAN.md` for the phased build plan and current progress.
