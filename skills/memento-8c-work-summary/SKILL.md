---
name: memento-8c-work-summary
description: Step 8.6 of Memento. Use once the PRs are open — from memento-8-final-review on a single-repo plan, from memento-8b-cross-pr-review on a multi-repo one. Emits the short shareable summary (issue URL - PR URL, what the work was for, review request) for Slack or standup.
---

# Memento — Work Summary

A task is not finished when the PR opens; it is finished when someone else knows it opened. Emit this summary **unprompted** as the closing act of the cycle — the user should never have to ask for it.

Write what a teammate reads in Slack to know what landed and that it needs their eyes. This is **not** the PR body: step 8 wrote the decision record there, for the reviewer already looking at the diff. This is the two-line version for someone who is not.

**Once per PR.** The summary announces a PR becoming reviewable. A step-9 loopback that re-runs step 8 against an already-open PR does not re-emit it — the reviewer is already on the thread, so answer there instead.

## Gather, check, write, then emit — in that order

1. **The PRs** — from step 8 (or 8b) when it handed them over, otherwise `gh pr view --json number,url,title,body,closingIssuesReferences` in each repo's worktree. Never guess a PR number from a branch name.
2. **The issue** — the PR's linked reference, or `Closes #N` / `Fixes #N` in its body; full URL via `gh issue view <n> --json url`. **A missing issue link is not a blocker.** Emit the summary with the PR URL alone and note in one line that no issue is linked. Never stop to ask which issue to use and never invent one — a delegated session (step 0d) has nobody to answer, and the summary is worth more than the link.
3. **The state** — `gh pr view <n> --json state,isDraft,reviewDecision,statusCheckRollup`, **before** emitting anything. Failing checks or a draft PR: do not emit the block at all. Say which PR is not ready and why; emit once it is green. Asking for review on red CI wastes the reviewer's time, and a summary already in the transcript cannot be recalled.

4. **The board note** — write the one-liner to the routed Obsidian board (below), **before** emitting.
   It runs only once the state check in 3 has passed, so a draft or red-CI PR never reaches a board.

## The board note

The summary is also one open line on the author's task board. Skip this entirely — silently, no
mention — when `~/Documents/be_JLA/scripts/work_summary_note.py` is absent; that vault is personal to
this plugin's author and every other user simply gets the printed block.

```sh
NOTE=~/Documents/be_JLA/scripts/work_summary_note.py
[ -f "$NOTE" ] && python3 "$NOTE" --url <full issue URL, or the PR URL when no issue is linked> <<'PROSE'
<the same 1-2 lines that go in the block body>
PROSE
```

The heredoc delimiter is quoted because a summary routinely carries backticks and `$`; unquoted, the
shell eats them before the script sees the prose.

The script prints one status line: `wrote <board>`, `skipped: … already on <board>`, or a notice that
no board is mapped for that owner (exit 3) or that the routed board is missing (exit 4). Report a
notice — those need a human to extend a map or restore a file. Never let any of it stop the block
from being printed: the summary is the deliverable, the board line is a convenience.

## Output — the block is exactly this, nothing else

```
<full issue URL> - <full PR URL>
<what it was done for, 1-2 lines>
Please review when possible.
```

Both links are **full URLs**, never `#1234` — the summary gets pasted where issue shorthand does not resolve.

Multi-repo: one issue, then every PR — `<issue URL> - <PR URL> - <PR URL>` — and the body once. The work was one task; do not write one summary per PR.

## Rules

- **Two lines maximum** for the body, one is usually better. This is the what-and-why, not the changelog.
- **Say what it was for, not what was edited.** "Recommendation copy is now available via the public API and MCP" beats "added a field to mapRecommendationItem and a zod schema". The reader wants the user-visible outcome.
- Plain sentences. No headings, no bullets, no bold, no emoji, no "Summary:" preamble.
- Mention a second issue only when the work genuinely spans both.
- The block is the **last thing in the turn**, so it is what the user copies. Anything to say about check state goes before it.

## Transition

Then `memento-9-receiving-review` — the summary is the handoff into waiting for feedback, not a step that waits for anything itself.
