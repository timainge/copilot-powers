# Worker Report Template

Use this template when asking for or normalizing a worker or subagent exploration pass.

## Scope Covered

State the exact area the worker treated as in scope.

## Inspected Inputs

List the files, projects, directories, or configs the worker actually inspected.

## Directly Observed Findings

List only findings supported by inspected code or configuration.

## Interface Coverage

For each major interface observed, state both directions or note explicitly if one side was not inspected:

- **Inbound**: what does this component receive, accept, or respond to? (event types consumed, API routes served, methods exposed)
- **Outbound**: what does this component emit, publish, or write? (event types published, responses returned, data written, side effects)

One-sided interface coverage is a known gap, not complete coverage.

## Known Coverage

State which parts of the requested slice were definitely covered.

## Known Gaps

State what remains uninspected, weakly supported, or out of scope.

## Gap-Closure Targets

List the next files, projects, or adjacent areas most likely to close the current gaps.

## Recommended Next Pass

State whether the next best action is direct confirmation, another worker pass, or narrowing the segment.
