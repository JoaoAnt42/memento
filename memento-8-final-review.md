---
name: memento-8-final-review
description: Step 8 of Memento. Use after implementation is green. Dispatches parallel reviewer subagents (Bugs, CRAP, Simplifier, Devil's Advocate, Tests), reconciles their feedback via the Orchestrator using the step-3 discussion pattern, and opens the PR.
---

# Memento — Final Review

Five reviewers in parallel. Orchestrator reconciles. Precedence when they conflict:

**Bugs > CRAP > Simplifier > Devil's Advocate > Tests**

## Protocol

1. For each task's green branch, dispatch **five reviewer subagents in parallel** (single message):
   - **Bugs** — correctness defects, security, data loss, race conditions
   - **CRAP** — Change Risk Anti-Patterns: high-complexity low-coverage functions
   - **Simplifier** — cuts, merges, premature abstraction
   - **Devil's Advocate** — assumption attacks, edge cases
   - **Tests** — coverage gaps, weak assertions, flaky patterns
2. Each returns a list of findings with severity.
3. **Orchestrator** applies precedence, deduplicates overlapping findings, and decides what to apply / reject / defer.
4. Reuse step-3 discussion pattern if reviewers disagree sharply (round cap: 3).
5. Present consolidated review to the user. For non-trivial changes, **pause for user confirmation before applying**.
6. Once changes are applied and re-verified green, open the PR. Set `status: done`.
7. Append a single short `## Final review changes` section to the plan listing **only**:
   - What was changed (one bullet per change, with the post-review SHA).
   - What was deferred + one-line reason (security/perf items pushed to a follow-up, etc.).

   **Do not write a transcript.** No per-finding accept/reject lists, no Bugs #N / Simplifier #N enumeration, no rationale tree. The diff and the bullets are the record.

## Rules

- Five reviewers, all independent subagents. None of them are the implementer.
- Orchestrator is the only writer.
- Precedence is strict. A Bugs finding beats a Simplifier finding, always.
- **Replace, don't append** — same rule as step 3. If you rewrite a section, remove the old one.
- PR is opened **here**, not earlier.

## Transition

On review feedback from humans on the PR, invoke `memento-9-receiving-review`.

Step 9 may re-invoke this skill when human-review changes are non-trivial (logic changes, multi-file fixes, bug/security fixes, or >~30 lines of substantive diff). When re-invoked, run the same five-reviewer pass against the updated branch — Bugs reviewer takes top priority since the goal is catching regressions introduced by the review-driven changes.
