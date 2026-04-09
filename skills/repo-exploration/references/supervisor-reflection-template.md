# Supervisor Reflection Template

Use this template after one or more worker passes and before writing durable docs.

## Slice

State the slice being synthesized.

## Worker Coverage Accepted

List the worker findings that appear usable as-is.

## Gaps Closed By Supervisor

List the gaps closed through direct reads, searches, or extra worker passes.

## Unresolved Questions Preserved

List the open questions that remain visible in docs or todo items.

## Depth Check

Before writing the durable note, confirm:

- [ ] Both directions of each major interface are documented or explicitly deferred (inbound and outbound)
- [ ] Failure and error cases are named, even if recorded as unresolved questions
- [ ] At least one concrete mechanic per major responsibility (not just the name of the mechanism)
- [ ] Service boundary contracts are specific (named events, methods, schemas) not general ("uses messaging")
- [ ] Any environment-specific or non-production caveats are labelled

## Reason To Stop

State why the slice is ready for synthesis now rather than needing another pass.

## Next Follow-Up

State the next adjacent slice or question worth exploring later.
