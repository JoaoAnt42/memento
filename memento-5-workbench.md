---
name: memento-5-workbench
description: Step 5 of Memento. Use after human approval of the plan. Creates a git worktree per task for isolated development.
---

# Memento — Workbench

Create a git worktree per task. **No PR yet** — PR is opened at the end, not now.

## Protocol

1. Read the task list from the plan file.
2. For each task, create a worktree:
   - Path: `../<repo-name>-worktrees/<task-slug>`
   - Branch: `memento/<task-slug>`
3. Record worktree path + branch into the plan file under each task.
4. Set `status: tdd-red`.

## Rules

- One worktree per task. Enables parallel step 6–7 work without interference.
- Never open a PR here. PRs are for step 8 output, not in-progress code.
- If a worktree for the task already exists, reuse it (don't recreate).

## Transition

Invoke `memento-6-tdd-red` with the plan path.
