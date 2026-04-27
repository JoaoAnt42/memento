---
name: memento-9-receiving-review
description: Step 9 of Memento. Use when receiving human code review feedback on a Memento PR. Requires technical rigor — verify, push back, or implement. Never performative agreement.
---

# Memento — Receiving Review

Review feedback is a hypothesis, not an instruction. Verify before implementing.

## Rules

- **Push back when feedback is wrong.** Bad assumption, misread code, worse alternative — say so with evidence before complying. If reviewer insists after hearing the case, proceed.
- **Verify before implementing.** Reproduce the concern. Read the cited code. If you can't reproduce, ask.
- **No performative agreement.** "Good catch!" without verification is a lie. Either you verified and agree, or you haven't verified and should.
- **Never silently ignore feedback.** Every comment gets a reply: implemented, declined-with-reason, or clarification-requested.
- **Update the plan file.** Append review feedback + resolutions under a `## Human review` section.

## Protocol

1. Group feedback by severity (blocker / nit / question).
2. For each item: verify → decide (implement, push back, clarify) → act.
3. Batch implementation changes into one commit per logical concern: `fix: <concern>` or `refactor: <concern>`.
4. Reply to every comment with the resolution.
5. If blockers remain unresolved, loop back to appropriate earlier step (usually step 7 or step 6 if tests are wrong).

## Rule of thumb

If the reviewer is wrong 1% of the time, you push back 1% of the time — not 0%. Silence is not respect.
