---
name: memento-8-final-review
description: Step 8 of Memento. Use after implementation is green. Dispatches parallel reviewer subagents (Bugs, CRAP, Simplifier, Devil's Advocate, Tests), reconciles their feedback via the Orchestrator using the step-3 discussion pattern, and opens the PR.
---

# Memento — Final Review

Each task is tagged `[repo: <label>]`; review it in that repo's worktree (the `worktree:` of the matching `repos:` entry). Open **one PR per repo** in `repos:` — each repo's `branch` → its `base`.

Five reviewers in parallel. Orchestrator reconciles. Precedence when they conflict:

**Bugs > CRAP > Simplifier > Devil's Advocate > Tests**

## Protocol

1. For each task's green branch, dispatch **five reviewer subagents in parallel** (single message):
   - **Bugs** (**`model: opus`**) — correctness defects, security, data loss, race conditions
   - **CRAP** (**`model: sonnet`**) — Change Risk Anti-Patterns: high-complexity low-coverage functions
   - **Simplifier** (**`model: sonnet`**) — cuts, merges, premature abstraction, oversized new files
   - **Devil's Advocate** (**`model: sonnet`**) — assumption attacks, edge cases; flags any module, layer, or path in the diff that is **not in the plan's `## Data contract`** — flow the implementer introduced off-contract (no-op when the plan has no contract section)
   - **Tests** (**`model: sonnet`**) — coverage gaps, weak assertions, flaky patterns
2. Each returns a list of findings with severity.
3. **Orchestrator** applies precedence, deduplicates overlapping findings, and decides what to apply / reject / defer.
4. Reuse step-3 discussion pattern if reviewers disagree sharply (round cap: 3).
5. Present consolidated review to the user. For non-trivial changes, **pause for user confirmation before applying**.
6. Once changes are applied and re-verified green, open one PR per repo in `repos:` (each `branch` → its `base`). Set `status: in-review`.
7. **Write the decision record into the PR body — not into the plan.** Cover only:
   - What changed and why (one bullet per non-obvious decision).
   - What was deliberately *not* done, and why. The reviewer's first question is always "why didn't you also fix X, two lines away?" — answer it before they ask.
   - What was deferred + one-line reason, with a ticket link if one exists.

   **Do not write a transcript.** No per-finding accept/reject lists, no Bugs #N / Simplifier #N enumeration, no rationale tree. The diff and the bullets are the record.

## Rules

- Five reviewers, all independent subagents. None of them are the implementer.
- **Models:** Bugs = Opus — correctness/security is the final safety net; don't downgrade it. CRAP, Simplifier, Devil's Advocate, Tests = Sonnet. Orchestrator = Opus: it applies precedence, reconciles, and writes the PR body. Same principle as step 7 — keep the load-bearing roles strong, tier the rest.
- Orchestrator is the only writer.
- Precedence is strict. A Bugs finding beats a Simplifier finding, always.
- **Replace, don't append** — same rule as step 3. If you rewrite a section, remove the old one.
- PR is opened **here**, not earlier.
- **The PR body is the only place the decision record goes.** Never mirror it into the plan. A PR is reachable from the code (`git blame` → commit → PR), durable, and visible to the team; a plan file is local, personal, and invisible to everyone else — nobody debugging a line six months from now will grep a personal vault for it. Writing both is duplicated effort whose second copy no future reader finds. The plan is a live-cycle coordination artifact, not an archive; step 9 deletes it on merge.
- **The cycle always ends with a work summary.** `memento-8c-work-summary` emits it unprompted once the PRs are open — never close out by asking the user whether they want one.
- Simplifier flags **newly created** files >~300 LOC and proposes splits. It does **not** propose splitting pre-existing large files unless the diff makes them substantively worse.

## Transition

After opening the PRs: if the plan's `repos:` list has **2+ entries**, invoke `memento-8b-cross-pr-review` to check the contract between them first — the summary must describe the post-contract-fix state. A single-repo plan goes straight to `memento-8c-work-summary`, which emits the shareable summary and hands on to `memento-9-receiving-review`.

On review feedback from humans on the PR, invoke `memento-9-receiving-review`.

Step 9 may re-invoke this skill when human-review changes are non-trivial (logic changes, multi-file fixes, bug/security fixes, or >~30 lines of substantive diff). When re-invoked, run the same five-reviewer pass against the updated branch — Bugs reviewer takes top priority since the goal is catching regressions introduced by the review-driven changes.
