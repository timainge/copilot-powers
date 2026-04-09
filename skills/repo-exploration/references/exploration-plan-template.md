# Exploration Plan Template

Use this template for `.notes/docs/exploration-plan.md` when a run is broad enough to need persistent coverage state.

## Scope

State the overall area the run is trying to cover.

## Structural Map Source

Record how the initial map was derived, such as `tree`, `find`, `rg --files`, workspace file tools, or platform equivalents.

## Stop Condition

State what counts as done for the current run.

Use this section to keep the stop decision internal to the workflow.

Do not interrupt the user for routine progression between segments or checkpoint windows.

Only pause the user when blocked, when the repo sends contradictory signals, or when a meaningful decision is required.

Example:

- every planned segment is complete, deferred with reason, or merged into another segment

## Segment Table

Use a table like this:

| Segment | Scope | Planned Pass | Status | Target Docs | Main Gaps Or Notes |
|---|---|---|---|---|---|
| orchestration | AppHost, service composition | worker + confirm | planned | architecture.md | map runtime dependencies |

Recommended statuses:

- `planned`
- `in-progress`
- `partial`
- `complete`
- `deferred`
- `merged`

## Supervisor Notes

Use this section for cross-segment observations, merge decisions, and reasons for deferring work.

## Run Notes And Insights

Use this section for notable observations that affect the current run but are not yet durable enough for a longer-lived note.

Examples:

- patterns noticed across several segments
- surprising architectural linkages
- emerging onboarding themes

## Process Improvements

Use this section for workflow changes that appear to be helping during the current run.

Examples:

- better slice boundaries
- improved worker prompt wording
- better confirmation strategy

## Coverage Gaps

Use this section for gaps that are visible at the run level rather than only inside one segment.

Examples:

- repeated missing coverage in processors or background workers
- infrastructure reliability questions still affecting multiple slices

## Errors And Failed Attempts

Use this section for tool failures, bad segment splits, false leads, or other issues that affected the run and may influence the next batch.

Keep entries short and factual.

## Next Checkpoint Window

List the next coherent set of segments intended for active work.

Choose a set that can still be synthesized reliably in one pass.

Do not treat this as a fixed numeric batch size.

Advancing to the next checkpoint window should normally happen autonomously.

Do not interrupt the user just to move from one coherent set of segments to the next.
