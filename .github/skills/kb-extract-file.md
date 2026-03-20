# KB Extract File Summary

Extract a structured summary for a single source file into the knowledge base.

## Usage

Invoke with a file path: `@kb-extract-file src/Services/PaymentProcessor.cs`

## Process

1. Read the specified source file.
2. Analyse its contents and produce a structured JSON summary.
3. Write the summary to `/kb/index/{relative-path}.json`.
4. Update `/kb/.explorer-state.json` to reflect the newly indexed file.

## Output Schema

The JSON summary must conform to the schema defined in the `kb-explorer` agent
documentation. Key fields:

- `generated_at_sha`: current HEAD short SHA
- `generated_at`: ISO 8601 timestamp
- `file`: relative path
- `purpose`: 1-2 sentence description
- `public_surface`: array of public API elements
- `dependencies`: array of imports/references
- `domain_concepts`: array of business terms
- `tech_debt_signals`: array of code smells with severity

## Notes

- This skill is called by agents and prompts, not typically invoked directly.
- Uses mini model — zero premium cost.
