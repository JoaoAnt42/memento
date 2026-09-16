---
name: memento-6-tdd-red
description: Step 6 of Memento. Use after the plan is approved and the feature branch is checked out. Dispatches test-writer agents to give every acceptance criterion exactly one verifier, grouped by owning task, runs them red, and commits the red state as the handoff artifact for step 7.
---

# Memento — TDD Red

Write tests, confirm red, commit the red SHA. That SHA is the contract handed to step 7.

Each task is tagged `[repo: <label>]`. Run its test-writer and verifier in that repo's worktree — the `worktree:` of the matching `repos:` entry — so the red commit lands on that repo's branch. Different tasks may sit in different repos.

**Concurrency.** Dispatch independent tasks' chains in one batch. **Across repos** is the free win — separate worktrees, no collision. **Same-repo** tasks share a worktree, so they run **sequentially** by default. Same-repo tasks tagged **`[disjoint]`** fan out in parallel via a per-task branch + worktree + a later merge — the plan has already asserted they touch disjoint file sets. A task **without** `[disjoint]` is a **barrier**: it runs after the preceding parallel group merges. git won't check one branch out in two worktrees, so the per-task worktree is what makes the fan-out legal.

## Protocol

1. For each task, dispatch a **test-writer subagent** (**`model: sonnet`**) on the feature branch. Brief: the criteria this task owns with a `test` verifier, or its seam test when it owns none (see Rules). No implementation. Sonnet is enough — pattern work from a structured spec. **When the plan has a `## Data contract`,** brief the writer with the seam(s) this task implements (see **Seam-aware tests**). **When the plan has a `## Diagnosis`,** brief the writer with its `Mechanism` for the criterion the fix satisfies (see `memento-5-diagnosing`); ignore `Refuted:` entries. On a re-scope after approval (`memento-4-human-review`), run this for the owning task only; a test already green on arrival is committed as `test: <task-slug> (already green)` instead of looping, and a dropped criterion's test is deleted in the same commit.
2. When the test-writer returns, dispatch a **separate verifier subagent** (`model: haiku`) to run the tests and confirm they fail for the right reason (not syntax error, not missing import — actual assertion failure). Verifier is mechanical; Haiku is correct.
3. Run each `check` in the plan's `## Checks` before implementation, in the worktree of the repo the entry is tagged for, and record its failing output under that entry in the plan. Stop when a criterion's check id is missing from `## Checks`, when two entries share an id, and when an entry's `[repo: <label>]` names no `repos:` entry; an untagged entry runs in the plan's only repo. A check that is already green before implementation is a false red: stop and re-scope the criterion per **Re-scope after approval**. `observe` entries don't run here — they only work after deploy.
4. Before committing, `grep -rn '\[DEBUG-' .` in the worktree must return nothing — step 5's instrumentation is its own to clean, and a probe committed into the red SHA becomes unremovable once step 7 freezes the test paths. Any hit: stop, clean, re-verify.
5. On confirmed red, commit with `test: red for <task-slug>` and record the SHA in the plan file under that task. Write the test ids (`<file>::<name>`) into the plan's `## Acceptance criteria` in place of `test` on each criterion they cover.
6. If tests pass immediately (false red), or fail for the wrong reason, the verifier returns that to the main agent — do NOT proceed. Loop: test-writer fixes, verifier re-checks.
7. When all tasks have a red SHA and any per-task branches have merged, record `Red HEAD: <sha>` per repo in the plan (a re-run re-records it) and set `status: implementing`.

## Rules

- Test-writer ≠ verifier ≠ implementer. Three independent subagents.
- **Parallel across repos, sequential within a repo.** Independent tasks fan out in one batch; same-repo tasks share a worktree → run in order (per-task branch + merge to override). The writer → verifier → red-commit chain stays sequential within a task.
- **Models:** test-writer = Sonnet, verifier = Haiku. Independence > model strength for these roles.
- **One verifier per criterion:**
  - Every acceptance criterion has exactly one verifier: a test, a `check` or `observe` command from `## Checks`, or a `smoke` item on step 7b's checklist.
  - Write the fewest tests that cover all criteria with a `test` verifier.
  - One test covers several criteria only when they share the same setup and action.
  - Unhappy-path tests come only from criteria, with no separate edge budget.
- **Tests are grouped by owning task** — the `(T<k>)` on each criterion line — so a task's brief is the criteria it turns green. A task with no criterion test gets its `## Data contract` seam test, so every task still hands step 7 a red artifact — a red test, or a `check` recorded red under its `## Checks` entry. A task with no criterion test, no `check`, and no seam test → stop and loop back to `memento-2-planning` to merge it; never write a test with no criterion behind it.
- **Seam-aware tests.** If the plan has a `## Data contract`, a criterion test that crosses the seam the task implements asserts on the seam's data — the declared signature / data shape — not just an end result. That is what makes the contract mechanically enforced (implementer can't reroute the flow without going red) rather than hortatory. This re-aims a criterion test, never adds one.
- **A `check` that can't run here is an `observe`.** It was classified wrong at planning (the gate is in `memento-2-planning`); reclassifying a `check` as `observe` stops the cycle and follows **Re-scope after approval** in `memento-4-human-review`.
- Red commit is the handoff artifact. No green code lands on top of uncommitted red.
- If a task's tests don't fail, the task is either already done or mis-specified. Flag to user before proceeding.

## Transition

Invoke `memento-7-implementing` with the plan path (each task's red SHA embedded).
