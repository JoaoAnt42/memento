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

## Closing out: delete the plan

Once **every** `repos:` entry's PR has merged and its worktree is gone, **delete the plan file.** No status flip to `done`, no closing summary, no ceremony — `rm` it and say so in one line.

The plan is a live-cycle coordination artifact, not an archive. Everything decided before merge already lives in the PR body (step 8 put it there), which is reachable from the code by `git blame` → commit → PR and visible to the team. A plan file is local and personal — keeping it produces a second copy nobody will ever look for, and a directory of hundreds of dead `status: done` files whose upkeep is pure tax.

**Do not delete if the PR did not merge.** An abandoned or rejected task has no PR to hold its reasoning, so the plan is the only record of the research — leave it, set `status: abandoned`, and note why in one line.

### The graduation exception

Some work has a life *after* merge that a PR structurally cannot record — a PR closes at merge and cannot say "this was reverted 90 minutes later, and here is why the canary lied." If the plan has accrued, or is expected to accrue, any of:

- a revert + postmortem,
- a staged rollout, canary, or flag-enable still pending,
- a manual operator run or runbook,
- deploy-gated follow-up ("merged flag-off; enabling still gated on X"),

then it stopped being a plan and became a runbook. **Move it out of `plans/`** rather than deleting it, and tell the user where it went. Deleting that content loses the only copy.

When unsure, ask — deletion is cheap to skip and impossible to undo.

## Rules

- **Push back when feedback is wrong.** Bad assumption, misread code, worse alternative — say so with evidence before complying. If reviewer insists after hearing the case, proceed.
- **Verify before implementing.** Reproduce the concern. Read the cited code. If you can't reproduce, ask.
- **No performative agreement.** "Good catch!" without verification is a lie. Either you verified and agree, or you haven't verified and should.
- **Never silently ignore feedback.** Every comment gets a reply: implemented, declined-with-reason, or clarification-requested.
- **Draft replies, don't post them.** A reply on a review thread is prose on a channel the team reads, and the global rule (`~/.claude/CLAUDE.md`, *Never post prose to an issue, ticket, or PR thread unless I ask*) applies. Write the full set into the conversation, wait for the user's go-ahead, then post the batch. One approval for the set, not one per comment. Same register as the PR body — no "Good catch", no marketing adjectives, no hedging.
- **Resolve after posting.** Once the batch is up, mark each replied thread resolved. Skip the resolve only if the reviewer explicitly said not to, or the reply is a clarification-request still waiting on the reviewer.
- **The PR thread is the record of feedback, not the plan.** Each comment's resolution lives in the reply to that comment. Do not mirror it into the plan — the plan is deleted on merge, and the reply is where a future reader looks anyway. Update the plan only when feedback changes the *plan itself* (scope, task list, a decision the rest of the cycle depends on), because later steps still read it while the cycle is live.

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
5. Draft a reply per comment with its resolution, show the whole set to the user, and post only on their go-ahead. After posting, mark each replied thread resolved (GraphQL `resolveReviewThread` mutation with the thread node ID). Skip the resolve only when waiting on the reviewer or when the reviewer explicitly said not to.
6. If blockers remain unresolved, loop back to appropriate earlier step (usually step 7 or step 6 if tests are wrong).

## Rule of thumb

If the reviewer is wrong 1% of the time, you push back 1% of the time — not 0%. Silence is not respect.
