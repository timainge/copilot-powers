# Docs Note Template

Use this template for durable repository notes in `.notes/docs`.

## Title

Use a stable, descriptive title for the system area.

## Purpose

Describe what this area does and why it exists.

## Scope

State what is included and what is intentionally out of scope.

## Entry Points

List the main files, projects, executables, or configuration roots that define the area.

## Evidence Anchors

List the files or code paths that support the main claims in the note.

## Responsibilities

Summarize the primary jobs this area performs.

## Dependencies

Capture important inbound and outbound dependencies, including infrastructure or shared libraries.

## Inbound Interfaces

What this component receives, accepts, or responds to. Name the mechanism and the specific contracts (event types, API routes, method signatures, queue topics, etc.).

## Outbound Interfaces

What this component emits, publishes, or writes. Name the mechanism and the specific contracts. Include side effects on shared state such as database writes or cache updates.

## Failure Behavior

How the component behaves when inputs are invalid, dependencies are unavailable, or processing fails. Record as an unresolved question if not inspected in this pass.

## Operational Notes

Record anything a new team needs to run, debug, test, or change the area safely.

## Unresolved Questions

List important gaps that need deeper exploration.

## Follow-Up

List open questions, weak assumptions, or adjacent areas that need exploration.
