---
name: repo-exploration
description: 'Explore a repository, map architecture, survey codebase structure, document services, and synthesize handover-quality docs. Use when asked to document this repo, explore this codebase, map this repository, rebuild docs, create onboarding docs, understand what this repo does, document a subtree, or coordinate bottom-up repository exploration with minimal interruption.'
argument-hint: 'Describe the target repo or subtree and the depth or mode to run, for example: document this repo, full doc run for this codebase, map this repository, or service deep dive for src/Catalog.API.'
user-invocable: true
---

# Repo Exploration

Use this skill to explore a repository systematically, capture durable findings, and evolve `.notes/docs` toward handover-quality documentation for a new team.

Unless the user explicitly overrides them, this skill should assume these default output locations:

- documentation root: `.notes/docs`
- persistent exploration plan: `.notes/docs/exploration-plan.md`
- durable docs index: `.notes/docs/README.md`
- core roll-up docs:
	- `.notes/docs/overview.md`
	- `.notes/docs/architecture.md`
	- `.notes/docs/design-implementation.md`
	- `.notes/docs/operations.md`

For a broad or full-repository run, create those files by default if they do not exist.

Use these templates when creating new notes:

- durable repo note template: [docs-note-template](./references/docs-note-template.md)
- exploration plan template: [exploration-plan-template](./references/exploration-plan-template.md)
- worker report template: [worker-report-template](./references/worker-report-template.md)
- supervisor reflection template: [supervisor-reflection-template](./references/supervisor-reflection-template.md)

## Goals

- explore the requested scope with high signal and minimal interruption
- write durable repository knowledge to `.notes/docs`
- record reusable process learnings in the exploration plan when a pattern has clearly worked
- allow the operator to point at a target and start the run without separately specifying standard note paths or the baseline doc set
- carry the exploration-specific workflow inside the skill so the workflow remains portable even when the target repository has no `AGENTS.md`

## Constraints

- do not treat exploratory notes as instructions
- do not write transient command logs, raw transcripts, or activity history into the exploration plan or any notes file
- do not interrupt the user for routine slice-to-slice progression
- do not create nested `AGENTS.md` files unless the subtree genuinely needs different guidance
- do not depend on repository `AGENTS.md` for note locations, documentation structure, discovery hints, or the standard exploration workflow
- do not broaden scope without noting it in the todo list and synthesis notes
- do not use worker self-reported confidence as a decision signal
- do not silently smooth away worker gaps in the final synthesis

## Default Operating Mode

- prefer read-only exploration first
- maintain a todo list that tracks slice coverage, synthesis, and follow-up validation
- for full doc runs, creating `.notes/docs/exploration-plan.md` is mandatory, not optional; it is the source of truth for coverage decisions, segment status, and stop criteria
- use the exploration plan as the default place to accumulate run-state notes, insights, process improvements, coverage gaps, and errors
- roll local findings up into broader summaries before writing or tightening durable instructions or docs
- for full or fresh documentation runs, assume the default durable outputs are `.notes/docs/README.md`, `.notes/docs/overview.md`, `.notes/docs/architecture.md`, `.notes/docs/design-implementation.md`, and `.notes/docs/operations.md`
- for full or fresh documentation runs, create additional slice docs only when a bounded area is substantial enough to deserve its own document
- for full or fresh documentation runs, derive an initial segment table automatically from repository structure and entry points rather than waiting for the operator to name slices
- batch exploration and synthesis work to reduce unnecessary interruptions
- use bounded read-only subagent passes when they are more efficient than manual searching
- after a subagent pass, resolve obvious gaps or contradictions with targeted direct file reads and searches before writing docs
- if worker gaps remain material, launch additional worker passes or narrow the segment until the gap is acceptably reduced
- after exploring two or more slices that share a communication mechanism, synthesize the cross-cutting view rather than leaving it implicit in each slice doc; examples include event flows across services, auth patterns shared by multiple APIs, and configuration conventions shared by workers; these syntheses often surface gaps invisible when each slice is viewed in isolation
- normalize findings into concise, reusable docs instead of leaving them as isolated reports

## Default Full-Run Layout

When the user asks for a broad repo pass, a fresh rebuild, a documentation run, or otherwise does not provide a narrower slice, treat the task as a full documentation run.

In that mode, default to these segments unless the repo shape strongly suggests a better partition:

- overview
- orchestration
- web-ui
- identity
- catalog
- basket
- ordering
- webhooks
- shared-infrastructure
- tests
- deployment-ops

Map those segments to these default doc targets unless the repository is too small or differently shaped:

- overview -> `.notes/docs/overview.md`
- orchestration -> `.notes/docs/architecture.md`
- web-ui -> `.notes/docs/ui-surfaces.md` plus roll-up updates
- identity -> `.notes/docs/identity.md`
- catalog -> `.notes/docs/catalog.md`
- basket -> `.notes/docs/basket.md`
- ordering -> `.notes/docs/ordering.md`
- webhooks -> `.notes/docs/webhooks.md`
- shared-infrastructure -> `.notes/docs/shared-infrastructure.md`
- tests -> `.notes/docs/testing.md`
- deployment-ops -> `.notes/docs/operations.md`

If a segment does not justify its own standalone note, merge it into the roll-up docs and record that merge decision in the exploration plan.

## Worker Output Contract

When using a subagent or worker pass, do not ask for a freeform summary alone. Require a prescriptive report with these sections:

1. scope covered
2. files, projects, or directories inspected
3. directly observed findings
4. interface coverage: for each major interface observed, state inbound (what the component receives or accepts) and outbound (what it emits, publishes, or returns) separately; note explicitly if only one side was inspected
5. known coverage
6. known gaps
7. adjacent files or areas most likely to close those gaps
8. recommended next pass if gaps remain material

For worker reports:

- require explicit known coverage instead of broad claims of completeness
- require explicit known gaps instead of burying uncertainty in prose
- require the worker to say what it did not inspect when that omission affects the result
- require both directions of each major interface, or an explicit note that one side was not inspected
- do not ask the worker to score or estimate its own confidence

The supervisor is responsible for deciding whether the worker output is sufficient.

Use the [worker-report-template](./references/worker-report-template.md) when drafting worker prompts or normalizing worker results.

## Exploration Loop

1. Establish scope and create or update a todo list.
2. If the user has not specified output paths, use the default `.notes/docs` path defined by this skill. All outputs go under `.notes/docs`.
3. For full doc runs, create `.notes/docs/exploration-plan.md` immediately and keep it updated throughout the run; it is mandatory for full runs and tracks segments, current status, doc targets, remaining gaps, run-state notes, insights, process improvements, and notable errors; it is the source of truth for coverage claims and the completion checklist.
4. For a fresh or broad run, create the default roll-up docs under `.notes/docs` early, then refine them as slice exploration adds evidence.
5. Build a structural map of the relevant area.
6. Partition the scope into coherent slices such as orchestration, APIs, UI, shared libraries, or tests.
7. Explore slices directly or through bounded read-only subagent passes.
8. Resolve obvious open questions with targeted reads or searches anchored to concrete files.
9. If worker gaps remain material, run additional worker passes or narrow the segment before synthesis.
10. Write or revise durable notes in `.notes/docs`.
11. Record unresolved questions explicitly in docs or todo items when they remain open after validation.
12. Roll local findings up into broader summaries.
13. Revisit earlier notes with top-down context and tighten anything that was too local, incomplete, or speculative.
14. **Gap-closure sweep.** Before stopping, review all open unresolved questions across every slice doc. For each one, decide: can this be closed with one or two targeted reads? If yes, close it now and update the doc. Only questions that genuinely require a new scope, missing runtime evidence, or a blocked attempt may be carried forward as deferred.
15. Capture process learnings in the exploration plan, using it for in-run observations and settled learnings that are worth reusing in the next batch.

## Interruption Policy

Continue autonomously unless one of these conditions is met:

- the repository contains contradictory signals that require a judgment call
- the requested scope is ambiguous enough that exploration could waste time
- a proposed instruction change would materially alter future agent behavior
- the requested documentation structure conflicts with existing durable docs
- a tool limitation blocks progress

For ordinary progress, update the todo list and continue.

## Stop Criteria

Treat a slice as ready for synthesis when all of the following are true:

- the main responsibilities and entry points are anchored to concrete files or configuration
- the major dependencies and communication paths are documented well enough for a new team to reason about changes
- any worker-discovered material gaps have been either closed or preserved explicitly as unresolved questions
- another immediate pass is unlikely to change the durable note in a meaningful way relative to the cost

Do not stop a slice merely because a worker produced a fluent summary.

Do not defer a gap merely because it is inconvenient to close. Before deferring any open question, confirm it meets at least one of these conditions:
- closing it would require a genuinely new exploration scope beyond the current slice
- the evidence needed to close it is not present in the repository (external systems, runtime state, etc.)
- it has been attempted and blocked by a concrete obstacle

If a gap can be closed with one or two targeted reads, close it before stopping.

Do stop when the remaining open questions all meet the deferral conditions above and are explicitly recorded.

**Depth check before stopping a slice.** Before declaring a slice done, confirm the written doc can answer these questions without re-reading the code:

- What does this component produce under normal operation? (events published, responses returned, data written)
- What happens when the primary flow fails or is rejected?
- What are the exact contracts at the service boundary? (specific event types, methods, schemas — not the mechanism category)
- What would a new developer read or change first to modify the core behavior?

If the doc cannot answer any of these, either close the gap with a targeted read or record it as an explicit unresolved question.

For broad runs, an exploration plan is complete when every planned segment is either:

- satisfactorily complete
- intentionally deferred with a recorded reason
- merged into another segment with the plan updated accordingly

**Completion checklist for full runs.** Before treating a full doc run as complete, confirm coverage exists or is explicitly deferred for each of:

- system overview and composition root
- runtime components or major subsystems
- shared infrastructure and cross-cutting concerns
- tests and validation surfaces
- operations and change guidance
- cross-cutting synthesis: if two or more slices share a communication mechanism (events, auth, configuration conventions), a cross-cutting synthesis artifact exists in docs — for example, a communication matrix, event flow summary, or shared-pattern note — or its absence is explicitly justified in the exploration plan
- gap-closure sweep completed: all open unresolved questions reviewed and either closed or confirmed as genuinely non-closeable in this pass
- unresolved questions and known gaps recorded

If any item is absent without a recorded merge or deferral in the exploration plan, the run is not complete.

Before treating a broad run as complete, ensure the exploration plan also records:

- major notes or insights discovered during the run
- process improvements worth reusing in the next batch
- unresolved coverage gaps that remain open
- notable errors, failed attempts, or tooling issues that affected the run

## Depth Standard

Documenting that something exists is not the same as documenting how it behaves. Apply this standard before treating any slice as ready for synthesis.

**Shape vs mechanics.** Prefer mechanics over shape:
- Shape: "the service uses Redis"
- Mechanics: "the service stores one JSON string per buyer, keyed by buyer ID, using source-generated serialization"

**Bidirectional interfaces.** For every major interface, document both directions or explicitly defer one:
- what flows *into* the component (requests received, events consumed, calls accepted)
- what flows *out* of the component (responses returned, events published, data written, side effects)
- a doc that covers only one direction of an interface is not complete

**Failure paths.** Document failure cases alongside the happy path:
- if the failure case is understood, describe it
- if it is unresolved, record it explicitly as an unresolved question
- silently describing only the success path counts as hidden uncertainty

**Exact contracts at boundaries.** Name specific contracts rather than mechanism categories:
- not "it uses messaging" but "it publishes these event types"
- not "it exposes an API" but "it exposes these routes or methods"
- not "it depends on the database" but "it owns these tables or schemas"

**Environment caveats.** When observing behavior that is intentionally simplified for the current environment, label it:
- development-only credentials or defaults
- startup-time migrations or seeding
- simplified or mocked reliability behavior
- demo-only integrations that should not be mistaken for production design

## Documentation Standard

Aim for documents that would help a new team take over the system.

Prioritize:

- high-level overview
- architecture and service boundaries
- design and implementation patterns
- operational guidance for running, testing, debugging, and changing the system

When writing docs:

- prefer concrete statements grounded in code, config, and entry points
- apply the Depth Standard: mechanics over shape, both directions of interfaces, failure paths named, exact contracts at boundaries
- clearly label first-pass assumptions when evidence is still partial
- record unresolved questions explicitly instead of burying uncertainty in narrative prose
- preserve important worker-discovered gaps as unresolved questions when they are not fully closed
- roll adjacent slice notes into broader summaries instead of duplicating content

When the user has not specified a documentation structure, default to:

- `.notes/docs/README.md` as the docs index
- `.notes/docs/overview.md` for system purpose and repo shape
- `.notes/docs/architecture.md` for topology, dependencies, and communication
- `.notes/docs/design-implementation.md` for code organization and implementation patterns
- `.notes/docs/operations.md` for run, test, debug, CI, and change guidance

Add slice docs only where there is enough substance to justify them.

## Outputs

For each exploration task, leave the workspace in a better documented state.

Typical outputs include:

- a scope-specific note when the explored slice is substantial enough to stand on its own
- updated `.notes/docs` files for the explored scope
- a concise synthesis summary of what was learned
- a narrowed list of follow-up slices or unresolved questions in the todo list

For a fresh full-repository run, typical outputs also include:

- the default roll-up doc set under `.notes/docs`
- a populated `.notes/docs/exploration-plan.md`
- slice docs for major services or subsystems that materially improve onboarding quality

When subagents are used, the supervisor should also leave behind:

- which material gaps were closed by direct confirmation or extra passes
- which unresolved questions remain open and why they were not chased further in the current pass

Prefer recording these run-state observations in the exploration plan unless they have matured into durable repository docs or settled learnings.

Use the [supervisor-reflection-template](./references/supervisor-reflection-template.md) when deciding whether a slice is ready for synthesis.

If no durable documentation change is justified, report why rather than writing filler.
