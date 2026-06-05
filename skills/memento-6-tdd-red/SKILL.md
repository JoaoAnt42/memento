---
name: memento-6-tdd-red
description: Step 6 of Memento. Use after the plan is approved and the feature branch is checked out. Dispatches test-writer agents to produce 1 happy + 1 edge test per task, runs them red, and commits the red state as the handoff artifact for step 7.
---

# Memento — TDD Red

Write tests, confirm red, commit the red SHA. That SHA is the contract handed to step 7.

Each task is tagged `[repo: <label>]`. Run its test-writer and verifier in that repo's worktree — the `worktree:` of the matching `repos:` entry — so the red commit lands on that repo's branch. Different tasks may sit in different repos.

**Concurrency.** Dispatch independent tasks' chains in one batch. **Across repos** is the free win — separate worktrees, no collision. **Same-repo** tasks share a worktree, so run them **sequentially** by default; git won't check one branch out in two worktrees, so parallelizing them takes a per-task branch + a later merge — opt-in, only when the speedup beats the merge risk.

## Protocol

1. For each task, dispatch a **test-writer subagent** (**`model: sonnet`**) on the feature branch. Brief: write **1 happy-path + 1 edge-case test** (not two happy paths). No implementation. Sonnet is enough — pattern work from a structured spec. **When the plan has a `## Data contract`,** brief the writer with the seam(s) this task implements — the happy-path test asserts on the data crossing that boundary (the declared signature), so the red test *is* the contract. This re-aims the existing happy test; it never adds a third.
2. When the test-writer returns, dispatch a **separate verifier subagent** (`model: haiku`) to run the tests and confirm they fail for the right reason (not syntax error, not missing import — actual assertion failure). Verifier is mechanical; Haiku is correct.
3. On confirmed red, commit with `test: red for <task-slug>` and record the SHA in the plan file under that task.
4. If tests pass immediately (false red), or fail for the wrong reason, the verifier returns that to the main agent — do NOT proceed. Loop: test-writer fixes, verifier re-checks.
5. When all tasks have a red SHA, set `status: implementing`.

## Rules

- Test-writer ≠ verifier ≠ implementer. Three independent subagents.
- **Parallel across repos, sequential within a repo.** Independent tasks fan out in one batch; same-repo tasks share a worktree → run in order (per-task branch + merge to override). The writer → verifier → red-commit chain stays sequential within a task.
- **Models:** test-writer = Sonnet, verifier = Haiku. Independence > model strength for these roles.
- Exactly 2 tests per task: 1 happy + 1 edge. Not 2 happy. Not 3.
- **Seam-aware happy test.** If the plan has a `## Data contract`, the happy-path test asserts on the seam the task implements — the declared signature / data shape — not just an end result. That is what makes the contract mechanically enforced (implementer can't reroute the flow without going red) rather than hortatory. Still exactly 2 tests; this re-aims the happy one, never adds.
- Red commit is the handoff artifact. No green code lands on top of uncommitted red.
- If a task's tests don't fail, the task is either already done or mis-specified. Flag to user before proceeding.

## Transition

Invoke `memento-7-implementing` with the plan path (each task's red SHA embedded).
