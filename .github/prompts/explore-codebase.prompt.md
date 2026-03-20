---
mode: agent
model: gpt-5-mini
tools: ["execute", "read", "edit", "search"]
description: "Full codebase exploration — produces per-file KB summaries"
---

# Explore Codebase

Invoke the `kb-explorer` agent to traverse the codebase and produce structured
summaries in `/kb/index/`.

## Instructions

1. Determine the primary source language by inspecting the repo root.
2. List all source files (exclude `bin/`, `obj/`, `node_modules/`, `packages/`, generated code).
3. For each file, produce a structured JSON summary per the kb-explorer schema.
4. Write each summary to `/kb/index/{relative-path}.json`.
5. After completing each directory, write a `_dir.json` rollup.
6. Update `.explorer-state.json` after each file for resumability.

## Batch Limit

Process up to **50 files** per session. If more remain, update state and stop
cleanly so the next invocation can resume.

## File Discovery Command

Adapt to the repo's primary language:

- **.NET:** `find src -type f \( -name "*.cs" -o -name "*.csproj" \) | sort`
- **TypeScript:** `find src -type f \( -name "*.ts" -o -name "*.tsx" \) -not -path "*/node_modules/*" | sort`
- **Python:** `find src -type f -name "*.py" -not -path "*/__pycache__/*" | sort`

Use the appropriate variant or combine as needed for polyglot repos.
