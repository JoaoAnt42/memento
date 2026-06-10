---
name: memento-1-brainstorming
description: Step 1 of Memento. Use when receiving a new task (markdown, screenshots, verbal description) that will go through the Memento cycle, before any planning or code.
---

# Memento — Brainstorming

Explore intent, requirements, constraints. No code yet. No plan file yet.

## Premise Auditor (run first, before any options)

The most expensive misses aren't bad design — they're a **wrong frame inherited from the task** and **environment facts assumed from partial code reads**. Propose-4-options refines *inside* a frame; it cannot break the frame. The auto-review skeptic (step 3) attacks the *plan within locked decisions* — by then it's too late. So before any decision sets, dispatch one **Premise Auditor** subagent (`Explore`-class), in parallel with the `memento-0` prior-art sweep.

**Independence is the mechanism.** Give it the **raw task** (the user's original words) + repo access — *never* your already-narrowed summary. Brief it plainly: *"the framing in this task may be wrong; assume nothing the task asserts is true until checked."* If you feed it your frame, it inherits your blind spot. (Same reason test-writer ≠ implementer.)

**Mandate — attack the premise + environment, NOT the design:**
- Enumerate the **load-bearing assumptions** the task's framing rests on — especially **environment / topology / reachability** facts: where does each system actually run, who connects to whom, what is reachable from where, who owns the data/rule.
- For each: is it **confirmed**, **falsifiable from the repo** (give the file/line that would settle it), or **human-only** (tribal/infra knowledge not in the repo)?
- Construct **at least one alternative frame** — "what if the obvious target/owner/approach in the task is the wrong one?"
- **CLAUDE.md claims** — if briefed that `CLAUDE.md` was flagged stale (step 0c), or it reads stale, include its load-bearing claims among the assumptions you check; you read code, so verify each against the current code. A claim the code contradicts is a confidence blocker, reported with its where-to-check like any other.
- Design trade-offs are out of scope. That's what propose-4-options and auto-review are for.

**Output budget (hard):** return only —
1. ≤5 load-bearing assumptions, ranked, each `{confidence, falsifier, where-to-check}`.
2. The strongest alternative frame it could construct (or "none found").
3. **Human-only questions** — the few things no repo read can settle. This list is the cheap kill-switch: one such question asked early can collapse an entire wrong design.

No 20-item doubt dumps — an unscoped skeptic trains you to ignore it.

**Gate:** brainstorming may not proceed to propose-4-options until the Auditor's human-only questions have been asked and the environment/topology facts it flagged are confirmed (repo evidence or human). A frame-breaking finding loops scope back, not forward.

This is a **pre-decision** instrument only. Do not re-run it as a standing reviewer in later steps — post-decision, it's just noise on top of auto-review.

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

**Premise gate.** The Premise Auditor must have run, its human-only questions been asked, and the environment/topology facts it flagged been confirmed (repo evidence or human). An unresolved frame-breaking finding loops scope back — it does not transition.

**Confidence gate.** Before transitioning to planning, every domain or business-rule claim below HIGH confidence must be confirmed against an authoritative source — the team leader, a written spec, or the prior implementation. List the unconfirmed claims to the user and resolve them; do not start planning on top of unconfirmed business rules. A `CLAUDE.md` claim flagged stale (step 0c or the Auditor) resolves by **additive reconciliation**: edit the doc to *add* missing facts, *fix* provably-wrong references/values, and *annotate* contradictions, while preserving the existing human prose and structure — never wholesale-rewrite, reorder, or recreate it. The user may defer the doc fix and proceed.

When user signals "ok, plan it" (or equivalent) and the confidence gate is clear, invoke `memento-2-planning`.
