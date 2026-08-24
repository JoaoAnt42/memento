---
name: memento-3-auto-review
description: Step 3 of Memento. Use after a plan is drafted, before human review. Runs a multi-turn discussion between Devil's Advocate, Simplifier, and Orchestrator subagents to stress-test and rewrite the plan in place.
---

# Memento — Auto-Review Discussion

Three subagents debate the plan. **The Orchestrator rewrites the plan file in place** and appends the transcript.

## Roles

- **Devil's Advocate** — attacks assumptions, finds edge cases, surfaces bad design smells, challenges scope. On large plans, checks `## Data contract` actually pins the seams — flags any flow left open to implementer invention (the under-specification that causes drift in steps 6–8).
- **Simplifier** — argues for cuts, merges, removals. Hunts premature abstraction and hypothetical requirements.
- **Orchestrator** — mediates, **guards resolved user decisions**, resolves conflicts, decides, **rewrites the plan file** with updated tasks + decisions, and appends the full transcript.

## Protocol

1. Orchestrator reads the current plan file (`status: planning` → set to `auto-review`). Extracts the list of **resolved user decisions** from `## Decisions` — these are constraints, not up for debate.
2. Dispatch Devil's Advocate and Simplifier (**`model: sonnet`**) **in parallel** (single message, two Agent calls). Each returns a critique. Brief both: resolved decisions are constraints; challenge the plan *within* them.
3. Orchestrator reconciles. **If a proposal contradicts a resolved user decision, Orchestrator pushes back** — cites the decision, the user's stated reason, and asks the proposing agent to revise or justify with new information the user didn't have. Never silently flip a resolved answer.
4. If the critiques conflict with each other (not with user), send them back to each other via Orchestrator for round 2.
5. **Round cap: 3.** Orchestrator may exit earlier on convergence.
6. Orchestrator **rewrites the plan in place** — REPLACE the affected sections, do not append duplicates. After the rewrite, the plan must contain exactly one `## Tasks`, one `## Open risks`, and — if the plan has them — one `## Data contract` and one `## Diagnosis`. Then append a single short `## Auto-review changes` section listing only:
   - Concrete changes made (one bullet each, no rationale tree).
   - Items surfaced for human override (proposals that contradicted a resolved user decision).

   **Do not write a transcript.** No round-by-round dialogue, no DA #N / Simplifier #N numbering, no accept/reject lists. Process residue, not signal.
7. Task descriptions must be self-contained — never reference `(DA #4)` or `(Simplifier #5)`. Those numbers die with the transcript.
8. Set `status: human-review`.

## Rules

- Devil's Advocate ≠ Simplifier ≠ Orchestrator. Independent subagents. Dispatch DA + Simplifier in parallel each round.
- **Models:** Devil's Advocate + Simplifier = Sonnet — plan-stage critique, pre-code and human review still follows. Orchestrator = Opus: it reconciles, guards resolved user decisions, and rewrites the plan. Tier the critics, not the writer.
- Orchestrator is the only one that writes to the plan file.
- **Replace, don't append.** Editing a section means rewriting it in place. Duplicate `## Tasks` / `## Open risks` / `## Data contract` blocks are a workflow bug — the second one always wins, the first must be removed.
- Resolved user decisions are load-bearing. Overriding one requires surfacing it to the user in step 4 (human-review), not doing it silently here.
- If the plan is declared unsalvageable, set `status: planning` and loop back to `memento-2-planning`.

## Transition

Invoke `memento-4-human-review` with the updated plan path.
