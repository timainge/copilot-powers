---
mode: agent
model: gpt-5-mini
tools: ["execute", "read", "edit", "search"]
description: "Incremental KB refresh based on git delta since last build"
---

# Incremental KB Refresh

Perform a delta refresh of the knowledge base based on files changed since the
last build.

## Algorithm

### Stage 1: DIFF
1. Read `/kb/.build-state.json` to get `last_delta_sha`.
2. If null, abort with message: "No previous build found. Run full exploration first."
3. Execute: `git diff --name-only {last_delta_sha} HEAD -- "*.cs" "*.csproj"`
   (adapt file extensions to repo language).
4. Store result as `changed_files[]`.

### Stage 2: EXTRACT
For each file in `changed_files[]`:
- If file was deleted: remove its KB entry from `/kb/index/`.
- If file was added or modified: re-run extraction, write updated `/kb/index/{file}.json`.

### Stage 3: ONCE-REMOVED TRAVERSAL
1. Load `/kb/dependencies/graph.json`.
2. For each changed file, find `direct_dependents[]` (one hop in the dep graph).
3. For each dependent NOT already in `changed_files[]`:
   - Read the dependent's current source.
   - Read the updated summary of the changed dependency.
   - Re-synthesise the dependent's KB summary with change context.
   - Use the following prompt approach:
     > "Update this file's summary knowing that {dependency} changed: {change_summary}.
     > Preserve fields that are unaffected. Flag uncertainty with confidence: low."

### Stage 4: MODULE ROLLUP
Find all modules containing any file from `changed_files[] + direct_dependents[]`.
Re-synthesise each affected module's `_dir.json`.

### Stage 5: SUBSYSTEM ROLLUP
Find subsystems containing any affected module.
Re-synthesise each affected `_subsystem.json`.

**DO NOT update `_system.json`.** Instead, write `/kb/.pending-system-update.md`
listing what changed, so the next architecture session has a diff brief.

### Stage 6: UPDATE STATE
Update `/kb/.build-state.json` with new `last_delta_sha` = current HEAD.

## Important

- If `/kb/dependencies/graph.json` does not exist, skip Stage 3 and log a warning.
- This is a mini-model task — zero premium quota spend.
