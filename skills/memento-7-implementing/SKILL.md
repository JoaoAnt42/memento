---
name: memento-7-implementing
description: Step 7 of Memento. Use after red tests are committed. Dispatches independent implementer agents per task, with the red commit SHA as input, and confirms green — authoritatively via CI re-run at the recorded SHA.
---

# Memento — Implementing

One implementer subagent per task, **independent from the test-writer**. Input: the red commit SHA.

Each task is tagged `[repo: <label>]`. Before dispatching a task's subagents, `cd` into that repo's worktree — the `worktree:` of the matching `repos:` entry — so they inherit the right cwd. Different tasks may run in different repos.

**Concurrency.** Implementers mutate source, so isolation gates parallelism. **Across repos:** fan out — separate worktrees already isolate them. **Same repo:** **sequential by default** — parallel implementers in one worktree race on files and entangle the per-task green commits. Same-repo tasks tagged **`[disjoint]`** fan out via a per-task branch + worktree + a merge after; the plan asserted their file sets don't overlap. A task **without** `[disjoint]` is a **barrier** — it runs after the preceding `[disjoint]` group is merged (this is how a dependent task sequences behind independent ones). git won't check one branch out twice, so the per-task worktree is mandatory for the parallel path.

## Protocol

1. For each task, dispatch an **implementer subagent** (`model: opus`) on the feature branch. Brief:
   - Your job: make the tests green. Do not modify the tests.
   - The red commit is `<SHA>`. Start from there.
   - Surgical: touch only what the task requires. Match existing style.
   - Implementer stays on Opus — code generation is the load-bearing artifact, not a place to compromise.
2. When the implementer returns, dispatch a **green verifier subagent** (`model: haiku`) to run the tests and confirm pass. Verifier is mechanical (run command, parse pass/fail); Haiku is correct.
3. If any test fails, send the failure back to the implementer. Max 3 retries, then escalate to user.
4. **Tests frozen — enforce mechanically.** Tests must be byte-identical to the red SHA: `git diff --quiet <red-SHA> HEAD -- <task test paths>` must exit clean. Any diff to a test file (or to fixtures/conftest under those paths) is a reject — the implementer may not make tests pass by editing them.
5. Commit the green state: `feat|fix: <task-slug>`.
6. **CI re-run at the recorded SHA — authoritative gate.** When all tasks are green locally, push the feature branch so CI runs at the exact green HEAD SHA. The in-loop green-verifier (Haiku) is **advisory**; **CI passing at the recorded SHA is the authoritative verdict** — a deterministic external runner the implementer cannot influence or misreport. Record each task's green SHA + CI run URL/result in the plan. If CI fails, send the failure back to the implementer (max 3 retries, then escalate to user). Do not transition on a red or absent CI run; if the repo has no CI, state that in the plan rather than treating local green as authoritative.
7. Once CI is green at the recorded SHA, check plan frontmatter `needs_human_smoke`:
   - `true` → set `status: human-smoke`, invoke `memento-7b-human-smoke`.
   - `false` → set `status: final-review`, invoke `memento-8-final-review`.

## Rules

- Implementer ≠ test-writer ≠ verifier. Independence is the whole point.
- **Models:** implementer = Opus, verifier = Haiku. Don't downgrade the implementer.
- Tests are immutable during step 7 — enforced by `git diff --quiet <red-SHA> HEAD -- <test paths>`. If tests are wrong, loop back to step 6.
- **CI at the recorded SHA is authoritative; the in-loop Haiku verifier is advisory.** Local green never transitions on its own when CI exists.
- One implementer per task (not multiple competing). Step 8 is the check, not redundant implementation.
- **Parallel across repos, sequential within a repo by default.** Across-repo tasks isolate via separate worktrees and fan out; same-repo tasks run in order unless each gets a per-task branch + worktree + merge. The implementer → verifier → green-commit chain stays sequential within a task.

## Transition

Invoke `memento-8-final-review` with the plan path.
