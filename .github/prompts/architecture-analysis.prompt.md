---
mode: agent
model: gpt-5.3-codex
tools: ["read", "search"]
description: "Run architecture analysis on a subsystem (CODEX — premium spend)"
---

# Architecture Analysis

**WARNING: This prompt uses a premium/codex model.**

Invoke the `kb-architect` agent to perform architecture analysis on a specified
subsystem or the full system.

## Instructions

1. Read the target subsystem's `_subsystem.json` from `/kb/index/`.
2. Read module-level `_dir.json` files within the subsystem for detail.
3. If available, read `/kb/dependencies/graph.json` for structural facts.
4. Read `/kb/architecture/current-state.md` if it exists (prior analysis).

## Deliverables

Produce the following in `/kb/architecture/`:

### 1. Current State Document (`current-state.md` or `{subsystem}-current-state.md`)
- Architectural patterns in use
- Layering structure
- Coupling analysis (tight/loose between modules)
- Cohesion assessment per module

### 2. Gap Analysis (`{subsystem}-analysis.md`)
- Structured gap inventory: gap, evidence, severity, affected modules
- Comparison against best practices for the observed architecture style

### 3. Remediation Roadmap (`remediation-roadmap.md`) — system-wide only
- Prioritised by risk (security, reliability) then effort
- Each item: gap reference, proposed change, effort estimate (S/M/L), dependencies

## Important

- All claims must cite specific KB artifacts as evidence.
- Flag areas where KB coverage is insufficient for confident analysis.
