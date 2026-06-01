---
name: memento-9-receiving-review
description: Step 9 of Memento. Use when receiving human code review feedback on a Memento PR. Requires technical rigor — verify, push back, or implement. Never performative agreement.
---

# Memento — Receiving Review

Review feedback is a hypothesis, not an instruction. Verify before implementing.

Review feedback arrives on a specific repo's PR — work in that repo's worktree (the matching `repos:` entry). After **each** repo's PR merges, remove that repo's worktree:

```sh
# For each merged `repos:` entry — REPO=<entry.path>  WT=<entry.worktree>  BRANCH=<entry.branch>
git -C "$REPO" worktree remove "$WT"
git -C "$REPO" branch -d "$BRANCH" 2>/dev/null || true
```

If `worktree remove` refuses (dirty / unmerged), stop and ask the user — don't `--force`.

## Rules

- **Push back when feedback is wrong.** Bad assumption, misread code, worse alternative — say so with evidence before complying. If reviewer insists after hearing the case, proceed.
- **Verify before implementing.** Reproduce the concern. Read the cited code. If you can't reproduce, ask.
- **No performative agreement.** "Good catch!" without verification is a lie. Either you verified and agree, or you haven't verified and should.
- **Never silently ignore feedback.** Every comment gets a reply: implemented, declined-with-reason, or clarification-requested.
- **Reply AND resolve by default.** After replying, mark the thread resolved. Skip the resolve only if the reviewer explicitly said not to, or the reply is a clarification-request still waiting on the reviewer.
- **Update the plan file.** Append review feedback + resolutions under a `## Human review` section.

## Protocol

1. Group feedback by severity (blocker / nit / question).
2. For each item: verify → decide (implement, push back, clarify) → act.
3. Batch implementation changes into one commit per logical concern: `fix: <concern>` or `refactor: <concern>`.
4. **If review changes are non-trivial, loop back to step 8 before pushing.** Re-invoke `memento-8-final-review` on the post-change branch when any of the following holds:
   - Changed business logic or control flow
   - Touched multiple files beyond a single concern
   - Fixed a bug or addressed a security finding
   - Diff exceeds ~30 lines of substantive change (excludes formatting, comments, renames)

   Trivial changes (typos, renames, comments, formatting, docs-only) skip re-review. The point: human feedback can introduce new bugs — verify nothing broke before pushing.
5. Reply to every comment with the resolution, then mark the thread resolved (use the GraphQL `resolveReviewThread` mutation with the thread node ID). Skip the resolve only when waiting on the reviewer or when the reviewer explicitly said not to.
6. If blockers remain unresolved, loop back to appropriate earlier step (usually step 7 or step 6 if tests are wrong).

## Rule of thumb

If the reviewer is wrong 1% of the time, you push back 1% of the time — not 0%. Silence is not respect.
