---
mode: agent
model: gpt-5.3-codex
tools: ["read", "search"]
description: "Decompose a large task into subtasks with acceptance criteria (CODEX — premium spend)"
---

# Task Decomposition

**WARNING: This prompt uses a premium/codex model. It costs 1 premium request.**

Break down a feature request, bug fix, or change into implementable subtasks.

## Instructions

1. Read the task description provided in your invocation context.
2. Search `/kb/index/` for file and module summaries relevant to the task.
3. If available, read `/kb/dependencies/graph.json` for impact context.
4. Search `/kb/domain/` for relevant business rules and domain entities.
5. Produce a structured plan.

## Output

Write to `/kb/tasks/{task-id}/plan.md` (generate task-id from the task description):

```markdown
# Task: {title}

**Created:** {date}
**KB Sources:** {list of KB files consulted}

## Context
{Brief summary of what the KB tells us about the affected area}

## Impact Analysis
{What modules/files are affected, based on KB + dep graph}

## Subtasks

### 1. {Subtask title}
- **Files:** {target files}
- **Description:** {what to do}
- **Acceptance criteria:**
  - [ ] {criterion 1}
  - [ ] {criterion 2}

### 2. {Subtask title}
...

## Risks & Open Questions
- {Any uncertainties or things to verify}

## Suggested Execution Order
{Which subtasks can be parallelised, which must be sequential}
```

Also create `/kb/tasks/{task-id}/progress.json`:

```json
{
  "task_id": "{task-id}",
  "created_at": "{ISO 8601}",
  "status": "planned",
  "subtasks": [
    {"id": 1, "description": "...", "status": "pending", "completed_at": null, "notes": null}
  ]
}
```

## Important

- Ground the decomposition in KB facts, not assumptions about the codebase.
- Each subtask should be implementable by a mini-model agent in a single session.
- Flag subtasks that might need codex for re-planning.
