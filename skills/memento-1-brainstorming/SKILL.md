---
name: memento-1-brainstorming
description: Step 1 of Memento. Use when receiving a new task (markdown, screenshots, verbal description) that will go through the Memento cycle, before any planning or code.
---

# Memento — Brainstorming

Explore intent, requirements, constraints. No code yet. No plan file yet.

## Rules

- **Prior-art sweep is an input.** `memento-0` ran a prior-art sweep before sizing. If it found an existing/legacy implementation, scope against that — do not re-derive the feature from the surface request. If brainstorming uncovers a domain area the sweep did not cover, dispatch a targeted follow-up `Explore` sweep before concluding.
- **Self-research first.** Read code, docs, config, git history before asking anything.
- **Don't conclude a domain rule is simple without an authoritative source.** Business rules (who approves, what routes where) are rarely a couple of variables. A "this is simple" finding with no prior implementation and no spec behind it is a flag to dig further or ask, not a conclusion.
- **Confidence + falsifier on load-bearing claims.** Every research finding that scope or the plan rests on gets tagged: confidence (high / medium / low), a falsifier (the observation that would change the answer), and its source (prior implementation / written spec / code read / inference). An inference with no authoritative source behind it is medium at best.
- **No question limit.** Ask as many as needed.
- **Propose-4-options.** For every question where multiple reasonable answers exist, generate 4 options, pick one, say why. User confirms or redirects. Banned: dumb binary yes/no when a multi-option framing exists.
- **Group related questions.** Don't drip-feed.
- **Terse.** Fragments OK. No filler.

## Output

A shared understanding of what the user wants and why. No artifact written yet — that happens in step 2 (`memento-2-planning`).

## Transition

**Confidence gate.** Before transitioning to planning, every domain or business-rule claim below HIGH confidence must be confirmed against an authoritative source — the team leader, a written spec, or the prior implementation. List the unconfirmed claims to the user and resolve them; do not start planning on top of unconfirmed business rules.

When user signals "ok, plan it" (or equivalent) and the confidence gate is clear, invoke `memento-2-planning`.
