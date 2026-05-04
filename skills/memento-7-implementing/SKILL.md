---
name: memento-7-implementing
description: Step 7 of Memento. Use after red tests are committed. Dispatches independent implementer agents per task, with the red commit SHA as input, and confirms green.
---

# Memento — Implementing

One implementer subagent per task, **independent from the test-writer**. Input: the red commit SHA.

## Protocol

1. For each task, dispatch an **implementer subagent** (`model: opus`) into the task's worktree. Brief:
   - Your job: make the tests green. Do not modify the tests.
   - The red commit is `<SHA>`. Start from there.
   - Surgical: touch only what the task requires. Match existing style.
   - Implementer stays on Opus — code generation is the load-bearing artifact, not a place to compromise.
2. When the implementer returns, dispatch a **green verifier subagent** (`model: haiku`) to run the tests and confirm pass. Verifier is mechanical (run command, parse pass/fail); Haiku is correct.
3. If any test fails, send the failure back to the implementer. Max 3 retries, then escalate to user.
4. If the implementer modifies the tests themselves, reject the work — tests are frozen at the red SHA for the duration of this step.
5. Commit the green state: `feat|fix: <task-slug>`.
6. When all tasks are green, check plan frontmatter `needs_human_smoke`:
   - `true` → set `status: human-smoke`, invoke `memento-7b-human-smoke`.
   - `false` → set `status: final-review`, invoke `memento-8-final-review`.

## Rules

- Implementer ≠ test-writer ≠ verifier. Independence is the whole point.
- **Models:** implementer = Opus, verifier = Haiku. Don't downgrade the implementer.
- Tests are immutable during step 7. If tests are wrong, loop back to step 6.
- One implementer per task (not multiple competing). Step 8 is the check, not redundant implementation.

## Transition

Invoke `memento-8-final-review` with the plan path.
