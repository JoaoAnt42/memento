---
name: memento-6-tdd-red
description: Step 6 of Memento. Use after the plan is approved and the feature branch is checked out. Dispatches test-writer agents to produce 1 happy + 1 edge test per task, runs them red, and commits the red state as the handoff artifact for step 7.
---

# Memento — TDD Red

Write tests, confirm red, commit the red SHA. That SHA is the contract handed to step 7.

Each task is tagged `[repo: <label>]`. Run its test-writer and verifier in that repo's worktree — the `worktree:` of the matching `repos:` entry — so the red commit lands on that repo's branch. Different tasks may sit in different repos.

## Protocol

1. For each task, dispatch a **test-writer subagent** (**`model: sonnet`**) on the feature branch. Brief: write **1 happy-path + 1 edge-case test** (not two happy paths). No implementation. Sonnet is enough — pattern work from a structured spec.
2. When the test-writer returns, dispatch a **separate verifier subagent** (`model: haiku`) to run the tests and confirm they fail for the right reason (not syntax error, not missing import — actual assertion failure). Verifier is mechanical; Haiku is correct.
3. On confirmed red, commit with `test: red for <task-slug>` and record the SHA in the plan file under that task.
4. If tests pass immediately (false red), or fail for the wrong reason, the verifier returns that to the main agent — do NOT proceed. Loop: test-writer fixes, verifier re-checks.
5. When all tasks have a red SHA, set `status: implementing`.

## Rules

- Test-writer ≠ verifier ≠ implementer. Three independent subagents.
- **Models:** test-writer = Sonnet, verifier = Haiku. Independence > model strength for these roles.
- Exactly 2 tests per task: 1 happy + 1 edge. Not 2 happy. Not 3.
- Red commit is the handoff artifact. No green code lands on top of uncommitted red.
- If a task's tests don't fail, the task is either already done or mis-specified. Flag to user before proceeding.

## Transition

Invoke `memento-7-implementing` with the plan path (each task's red SHA embedded).
