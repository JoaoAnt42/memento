---
name: memento-7-implementing
description: Step 7 of Memento. Use after red tests are committed. Dispatches independent implementer agents per task, with the red commit SHA as input, and confirms green locally before the branch is pushed.
---

# Memento — Implementing

One implementer subagent per task, **independent from the test-writer**. Input: the red commit SHA. A task whose latest test commit is `(already green)` is skipped.

Each task is tagged `[repo: <label>]`. Before dispatching a task's subagents, `cd` into that repo's worktree — the `worktree:` of the matching `repos:` entry — so they inherit the right cwd. Different tasks may run in different repos.

**Concurrency.** Implementers mutate source, so isolation gates parallelism. **Across repos:** fan out — separate worktrees already isolate them. **Same repo:** **sequential by default** — parallel implementers in one worktree race on files and entangle the per-task green commits. Same-repo tasks tagged **`[disjoint]`** fan out via a per-task branch + worktree + a merge after; the plan asserted their file sets don't overlap. A task **without** `[disjoint]` is a **barrier** — it runs after the preceding `[disjoint]` group is merged (this is how a dependent task sequences behind independent ones). git won't check one branch out twice, so the per-task worktree is mandatory for the parallel path.

## Protocol

1. For each task, dispatch an **implementer subagent** (`model: opus`) on the feature branch. Brief:
   - Your job: make the tests green. Do not modify the tests.
   - The red commit is `<SHA>`. Start from there.
   - Surgical: touch only what the task requires. Match existing style.
   - Implementer stays on Opus — code generation is the load-bearing artifact, not a place to compromise.
2. When the implementer returns, dispatch a **green verifier subagent** (`model: haiku`) to run the tests and confirm pass. Where the task's criteria carry a `check` verifier, the same verifier re-runs those `## Checks` commands and confirms each check now green against the expectation in the plan. Verifier is mechanical (run command, parse pass/fail); Haiku is correct.
3. If any test fails, send the failure back to the implementer. Max 3 retries, then escalate to user.
4. **Tests frozen — enforce mechanically.** Tests must be byte-identical to the repo's `Red HEAD` in the plan (step 6): `git diff --quiet <Red HEAD> HEAD -- <task test paths>` must exit clean. Any diff to a test file (or to fixtures/conftest under those paths) is a reject — the implementer may not make tests pass by editing them.
5. **Check commands are frozen.** Step 7 freezes them the same way it freezes test files: a `## Checks` command must be byte-identical to the one step 6 ran red. Editing a command to make its check pass is a reject; a check whose command is wrong loops back to step 6.
6. Commit the green state: `feat|fix: <task-slug>`.
7. When all tasks are green locally, push the feature branch and record each task's green SHA in the plan. Most target repos run their workflows on `pull_request` and on pushes to the base branch, so a feature-branch push on its own starts no CI run. The CI verdict is read at step 8c (`memento-8c-work-summary`), once the PR exists.
8. With local green confirmed and the branch pushed, check plan frontmatter `needs_human_smoke`:
   - `true` → set `status: human-smoke`, invoke `memento-7b-human-smoke`.
   - `false` → set `status: final-review`, invoke `memento-8-final-review`.

## Rules

- Implementer ≠ test-writer ≠ verifier. Independence is the whole point.
- **Models:** implementer = Opus, verifier = Haiku. Don't downgrade the implementer.
- Tests are immutable during step 7 — enforced by `git diff --quiet <Red HEAD> HEAD -- <test paths>`. If tests are wrong, loop back to step 6; a wrong criterion follows **Re-scope after approval** in `memento-4-human-review`.
- **Local green is what this step confirms; CI is step 8c's call.** Don't claim a CI result here — no run has been read yet.
- One implementer per task (not multiple competing). Step 8 is the check, not redundant implementation.
- **Parallel across repos, sequential within a repo by default.** Across-repo tasks isolate via separate worktrees and fan out; same-repo tasks run in order unless each gets a per-task branch + worktree + merge. The implementer → verifier → green-commit chain stays sequential within a task.

## Transition

Invoke `memento-8-final-review` with the plan path.
