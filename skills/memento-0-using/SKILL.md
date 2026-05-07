---
name: memento-0-using
description: Entry point for the Memento way-of-work. Use when the user invokes `/use_new_superpowers`, `/memento`, or starts any multi-step coding task that should go through the full cycle (brainstorm → plan → auto-review → human-review → tdd-red → implement → final-review → receiving-review). Replaces the superpowers:using-superpowers flow.
---

# Memento

*Memento mori — remember that code will die, or at least your knowledge of it. Do it properly now so it doesn't fail you later.*

Maximize confidence over speed. Steps 6–8 use **independent agents** — the test-writer cannot also be the implementer.

## The cycle

Invoke the step skills in order. Any step can loop back to step 2 — this is a cycle, not a pipeline.

1. `memento-1-brainstorming` — receive task, explore intent
2. `memento-2-planning` — write plan markdown in Obsidian, propose-4-options on every question
3. `memento-3-auto-review` — Devil's Advocate + Simplifier + Orchestrator discussion, Orchestrator rewrites the plan
4. `memento-4-human-review` — submit plan to user; rejection → back to step 2. On approve, safe-prune merged worktrees, then create a per-plan **git worktree** at `<repo_parent>/<repo_name>-worktrees/<plan-slug>` on branch `<type>/<plan-slug>` from `main` (where `<type>` is the plan frontmatter `type:`). All subsequent steps run from inside that worktree.
6. `memento-6-tdd-red` — test-writer agents produce red tests (1 happy + 1 edge per task), **commit the red SHA**
7. `memento-7-implementing` — independent impl agents, input = red SHA, confirm green
7.5. `memento-7b-human-smoke` — **optional**, gated by plan flag `needs_human_smoke: true`. Start services, hand user a click-checklist, wait for verdict. Loops back on found-issue.
8. `memento-8-final-review` — parallel reviewers (Bugs, CRAP, Simplifier, Devil's Advocate, Tests) + Orchestrator reconciliation. Precedence: Bugs > CRAP > Simplifier > Devil's Advocate > Tests
9. `memento-9-receiving-review` — consume review feedback with technical rigor, not performative agreement

## Rules

- **Plan file is the source of truth.** Lives at `~/Documents/be_JLA/work/plans/YYYY-MM-DD-<slug>.md`. Frontmatter `status:` tracks current step. Appended across steps, never overwritten.
- **Independent agents for 6–8.** Test-writer ≠ implementer ≠ reviewer. Bias guardrail.
- **Red commit SHA is the handoff artifact** from step 6 to step 7. Impl cannot start before red is committed.
- **Loop back freely.** If reality contradicts the plan, update the plan. Don't silently bypass it.
- **User overrides always win.** CLAUDE.md and direct instructions beat this skill.
- **One worktree per plan.** Lives at `<repo_parent>/<repo_name>-worktrees/<plan-slug>`, recorded in plan frontmatter as `worktree:`. Steps 6–9 cwd into it. Cleanup happens via the safe-prune sweep at the start of step 4 (only merged + clean worktrees are removed) and explicitly in step 9 after PR merge.

## When to skip

Trivial one-line fixes, typo corrections, config tweaks, doc edits. Memento is for multi-step implementation work.
