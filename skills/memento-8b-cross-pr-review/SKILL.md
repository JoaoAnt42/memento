---
name: memento-8b-cross-pr-review
description: Step 8.5 of Memento — optional cross-PR contract review. Use after memento-8-final-review opens one PR per repo, only when the plan's `repos:` list has 2+ entries. Checks the contract between the per-repo PRs (API shape, shared types, event payloads, migration ordering), then applies fixes in the worktrees and pushes.
---

# Memento — Cross-PR Contract Review

Step 8 reviews each repo's PR in isolation. Nothing yet checks whether the per-repo PRs **cohere as one feature** — backend ships an endpoint the frontend never calls, a shared enum drifts, a migration must merge first. This step closes that gap before human review sees the set.

## Gate

Run this step only when the plan's `repos:` list has **2 or more entries** (a multi-repo plan, one PR per repo). A single-repo plan has no cross-PR contract — skip straight to `memento-9-receiving-review`.

## Protocol

1. Collect the open PRs — one per `repos:` entry — that step 8 just opened (PR URL/number per entry).
2. **Detect the contract surface.** Read each PR's title, body, branch, changed paths, and skim each diff. Infer how they relate, then list the concrete shared surfaces:
   - API request/response shapes — routes, status codes, field names/**casing**
   - Shared types/enums duplicated across repos
   - Event/message payloads (producer ↔ consumer)
   - Migration / merge-ordering dependencies
   - Auth/permission boundaries one side assumes the other enforces
   - Feature-flag coherence

   Present the inferred connection + surface to the user and **wait for confirmation or correction**. If genuinely unrelated, skip to step 8c.
3. Dispatch **one independent contract agent** (**`model: opus`**, not the implementer, not a step-8 reviewer), given all PR diffs together + the confirmed surface. It returns **mismatches only**, each naming the repo/PR where the fix belongs (prefer the consumer side), with severity and a concrete fix:
   - API contract mismatch — casing, missing field, status-code handling
   - Type/enum drift between repos
   - Missing matching change — endpoint with no caller; removed field still referenced
   - Event payload disagreement
   - Migration ordering
   - Auth / feature-flag incoherence
4. Present consolidated findings, sorted by severity. **Pause for confirmation before applying** (same as step 8).
5. On confirmation, for each accepted finding: edit in the **owning repo's worktree** (the matching `repos:` entry), commit, and **push to that repo's existing PR branch**. Re-verify the affected repo green.
6. Append a single short `## Cross-PR review` section to the plan: what was changed (one bullet per fix, with repo + post-fix SHA) and what was deferred + one-line reason. No transcript.

## Rules

- Multi-repo only. Single-repo plans never reach this step.
- The contract agent is independent — not the implementer, not a step-8 reviewer.
- **Model:** contract agent = Opus — cross-repo contract mismatches are correctness-critical, the same tier as the Bugs reviewer in step 8.
- Apply fixes in the worktree and **push to the existing PR branch** — do not open new PRs or post inline comments on your own PRs.
- Fix lands on the side it belongs (usually the consumer). If genuinely cross-cutting, fix the consumer and name the producer in the commit message.
- If a fix is itself a non-trivial logic change in one repo, treat it like step 9's re-review trigger — re-run `memento-8-final-review` on that repo's branch.

## Transition

Done (or unrelated / no findings) → `memento-8c-work-summary`, which emits one summary covering every repo's PR and hands on to `memento-9-receiving-review`.
