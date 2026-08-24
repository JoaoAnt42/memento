---
name: memento-8c-work-summary
description: Step 8.6 of Memento. Use once the PRs are open — from memento-8-final-review on a single-repo plan, from memento-8b-cross-pr-review on a multi-repo one. Emits the short shareable summary (issue URL - PR URL, what the work was for, review request) for Slack or standup.
---

# Memento — Work Summary

A task is not finished when the PR opens; it is finished when someone else knows it opened. Emit this summary **unprompted** as the closing act of the cycle — the user should never have to ask for it.

Write what a teammate reads in Slack to know what landed and that it needs their eyes. This is **not** the PR body: step 8 already wrote the decision record there, for the reviewer who is already looking at the diff. This is the two-line version for someone who is not.

## Output — exactly this, nothing else

```
<full issue URL> - <full PR URL>
<what it was done for, 1-2 lines>
Please review when possible.
```

Both links are **full URLs**, never `#1234` — the summary gets pasted where issue shorthand does not resolve.

Multi-repo: one `<issue URL> - <PR URL>` line per `repos:` entry, then the body once. The work was one task; do not write one summary per PR.

## Gathering

The PR numbers come from step 8 (or 8b) — do not re-derive them by guessing at branches.

1. Per PR: `gh pr view <n> --json number,url,title,body,closingIssuesReferences` — the issue is the linked reference, or `Closes #N` / `Fixes #N` in the body.
2. That issue's URL — full, from `gh issue view <n> --json url`.
3. If a PR closes no issue, say so and ask which issue to link. Never invent one and never ship the summary without it — every PR here carries an issue.

## Rules

- **Two lines maximum** for the body, one is usually better. This is the what-and-why, not the changelog. The PR body holds the decision record; do not restate it.
- **Say what it was for, not what was edited.** "Recommendation copy is now available via the public API and MCP" beats "added a field to mapRecommendationItem and a zod schema". The reader wants the user-visible outcome.
- Plain sentences. No headings, no bullets, no bold, no emoji, no "Summary:" preamble.
- Mention a second issue only when the work genuinely spans both.
- No Claude attribution.
- Emit it as the last thing in the turn, so it is the block the user copies.

## Before handing it over

State the PRs' check and review state in one line **after** the summary — not part of it, so the copied block stays clean:

```sh
gh pr view <n> --json state,isDraft,reviewDecision,statusCheckRollup
```

Failing checks or a draft PR: say so plainly and ask whether to hold the summary. Asking for review on red CI wastes the reviewer's time.

## Transition

Then `memento-9-receiving-review` — the summary is the handoff into waiting for feedback, not a step that waits for anything itself.
