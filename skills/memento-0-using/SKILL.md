---
name: memento-0-using
description: Entry point for the Memento way-of-work. Use when the user invokes `/use_new_superpowers`, `/memento`, or starts any multi-step coding task that should go through the Memento cycle. Sizes the task (small or large) and routes it. Replaces the superpowers:using-superpowers flow.
---

# Memento

*Memento mori — remember that code will die, or at least your knowledge of it. Do it properly now so it doesn't fail you later.*

Maximize confidence over speed — **but match process weight to task size.** Running the full pipeline on a small task is the most common Memento failure mode: it burns a morning on process tax for a change that needed an hour.

## Step 0a — Prior-art sweep (always do this first, before sizing)

The most expensive Memento failure is scoping a feature that already exists. On VDA, an "approver dropdown" was scoped as a config-table lookup keyed on two fields; the real logic was a ~290-line legacy resolver (`Xpenses.UI/Controllers/ExpensesController.GetExpenseApprovers`, 10 steps) that research never looked for. A whole slice (PR 4685) was built and abandoned.

Before sizing or any scope conclusion, dispatch **parallel `Explore` agents** to hunt for an existing implementation of the requested feature:

- **Legacy / older projects** in the workspace — MVC controllers, predecessor apps, anything the new code replaces.
- **Sibling repos** — the same feature may live in another service, or in the counterpart frontend/backend.
- **Git history + grep** — removed or renamed code paths, prior commits touching the same domain.
- **Docs / specs / existing plans** — a prior design or a team-leader spec already written.

One agent per plausible location; dispatch them in a single batch. **The size decision and every scope conclusion are blocked until the sweep returns.**

If a prior implementation is found, **it is the spec** — scope the task against it, not against the surface request, and cite its location. This almost always makes the task Large.

If the sweep finds nothing, say so explicitly — "no prior implementation found in `<places searched>`". A clean negative is a result; a skipped search is not.

**Companion check (Large route):** the prior-art sweep asks *"does this already exist?"* It does not ask *"is the task's framing even right?"* That second question — wrong target, wrong owner, environment/topology assumed from partial reads — is the **Premise Auditor** in `memento-1-brainstorming`, dispatched in the same parallel batch as this sweep. A frame inherited from the task and never falsified is as expensive as a re-built feature; both gates run before any decision locks.

## Step 0b — Size the task

After the sweep returns, classify the task as **Small** or **Large**. There is no middle tier and no confirmation step — assess, decide, state the chosen size with a one-line reason, and proceed.

| Size | Fits when |
|------|-----------|
| **Small** | ALL of: 1–2 files; localized and self-evident; no new logic branch; touches none of the Large triggers below; prior-art sweep found nothing substantial. |
| **Large** | Anything else — multiple files with real logic, intent unclear, or **any single Large trigger fires, regardless of how small the diff looks.** |

**Large triggers (any one → Large, even for a 1-line diff).** File count is *surface*, not *risk* — a one-field "dropdown" was a ~290-line approval resolver (the 0a story). Size up, not down, when the change touches:

- **A business / domain rule** — approval routing, eligibility, pricing, any calculation. "Looks like two variables" is the tell to dig, not the conclusion.
- **Auth, permissions, or security.**
- **Persisted data** — schema, migration, or anything that writes/alters stored state. Hard to reverse.
- **A shared or public contract** — API, event, or a symbol consumed by other code/repos. Blast radius exceeds the diff.
- **Money, deletion, or any irreversible / external side effect** — payments, emails, deploys.
- **Concurrency or ordering** — async, locks, races.

When genuinely unsure, choose **Large** — over-process costs time, under-process costs a missed bug. The user can still override by saying so; otherwise don't stop for confirmation.

## Step 0c — CLAUDE.md staleness signal

Before routing, check the target repo's `CLAUDE.md` for staleness — a **non-blocking** signal, never an auto-action. Acting on a stale doc can carry wrong assumptions into the cycle; catching it here is cheap.

Run this as **one isolated Bash call** in the repo root and read its stdout. It exits silently on any miss (no tracked `CLAUDE.md`, shallow/detached state), so it can never block routing:

```sh
# GNU date assumed (Linux). Detached HEAD / shallow clone may undercount commits → fails safe (silent).
f=CLAUDE.md; git ls-files --error-unmatch "$f" >/dev/null 2>&1 || f=.claude/CLAUDE.md
git ls-files --error-unmatch "$f" >/dev/null 2>&1 || exit 0          # no tracked doc → silent
sha=$(git log -1 --format=%H -- "$f"); last=$(git log -1 --format=%cI -- "$f")
age=$(( ($(date +%s) - $(date -d "$last" +%s)) / 86400 ))
since=$(git rev-list --count "$sha"..HEAD)                           # 0 when the doc is the newest commit
[ "$age" -gt 21 ] && [ "$since" -gt 25 ] && echo STALE
```

Two-factor on purpose: the doc is untouched for **>21 days** AND **>25 commits** landed since. Both gates together avoid false positives — a calendar age alone fires on stable repos, a commit count alone fires on high-churn / auto-commit repos. Thresholds are heuristic; tune them here if they prove noisy.

If the check prints `STALE`, surface a **non-blocking** prompt, default **no**: *"`CLAUDE.md` last changed >21d ago with N commits since — may be stale. Reconcile it against the code first? [y/N]"* Step 0c never edits the doc and never writes a plan (none exists yet on the Large route) — it only carries the verdict forward:

- **No** (default) — route unchanged.
- **Yes, Large route** — carry the flag into step 1: brief the Premise Auditor to verify `CLAUDE.md`'s load-bearing claims against the code (it reads code, so it reconciles additively there). If still unresolved when step 2 writes the plan, that step records the staleness under `## Open risks`.
- **Yes, Small route** — the Small route writes a minimal plan now, so add a one-line note to its `## Context` (*"CLAUDE.md flagged stale at step 0c — review assumptions while implementing"*). Inform-only: no reconcile pass, and never rewrite or recreate the doc.

Prints nothing → say nothing, route.

## Routes

Steps 6–8 use **independent agents** — the test-writer cannot also be the implementer. Any step can loop back to an earlier step; this is a cycle, not a pipeline.

### Small route

A Small task still produces a plan file and a PR — it just skips brainstorm, planning Q&A, auto-review, human-review, and the TDD agent hand-off. Run these in order:

- **Derive** a conventional-commit `type`, a kebab-case `slug`, and the target repo (root path + its integration branch) from the task.
- **Write a minimal plan file** at `~/Documents/be_JLA/work/plans/YYYY-MM-DD-<slug>.md` — frontmatter (`name`, `status: implementing`, `created`, `type`, `needs_human_smoke: false`, and a one-element `repos:` list — `label: repo`, `path` = the target repo root, `base` = its integration branch, `branch: <type>/<slug>`, empty `worktree:`) plus a short `## Context` paragraph. No Decisions / Tasks / Open-risks sections. This file is what `memento-8` reads the worktree from and appends its review summary to.
- **Create the worktree.** Run the **Safe-prune sweep** and **Worktree creation** procedures exactly as documented in `memento-4-human-review` — the shell procedure there is generic; ignore its "on approve" framing, do not restate it here. Record the worktree path back into the `repos:` entry's `worktree:`.
- **Implement directly** — normal editing, no agent dispatch, no red-SHA hand-off. Honour CLAUDE.md TDD where it fits, but no `memento-6` / `memento-7` ceremony.
- Invoke `memento-8-final-review` — parallel reviewers + Orchestrator reconciliation, opens the PR, sets `status: done`.

If the task turns out larger than it looked, stop and restart it as Large.

### Large route — the full cycle

1. `memento-1-brainstorming` — receive task, explore intent
2. `memento-2-planning` — write plan markdown in Obsidian, propose-4-options on every question
3. `memento-3-auto-review` — Devil's Advocate + Simplifier + Orchestrator discussion, Orchestrator rewrites the plan
4. `memento-4-human-review` — submit plan to user; rejection → back to step 2. On approve, safe-prune merged worktrees, then create one **git worktree per `repos:` entry** (each forked from its `base`, on its `branch`). Each later task runs in its tagged repo's worktree.
6. `memento-6-tdd-red` — test-writer agents produce red tests (1 happy + 1 edge per task), **commit the red SHA**
7. `memento-7-implementing` — independent impl agents, input = red SHA, confirm green
7.5. `memento-7b-human-smoke` — **optional**, gated by plan flag `needs_human_smoke: true`. Start services, hand user a click-checklist, wait for verdict. Loops back on found-issue.
8. `memento-8-final-review` — parallel reviewers (Bugs, CRAP, Simplifier, Devil's Advocate, Tests) + Orchestrator reconciliation. Precedence: Bugs > CRAP > Simplifier > Devil's Advocate > Tests
8.5. `memento-8b-cross-pr-review` — **optional**, multi-repo only (`repos:` ≥2). Checks the contract between the per-repo PRs (API/type/event/migration coherence); applies fixes in the worktrees and pushes. Skipped for single-repo plans.
9. `memento-9-receiving-review` — consume review feedback with technical rigor, not performative agreement

## Rules

- **Plan file is the source of truth.** Lives at `~/Documents/be_JLA/work/plans/YYYY-MM-DD-<slug>.md`. Frontmatter `status:` tracks current step. Appended across steps, never overwritten. Small writes a minimal version (frontmatter + Context only); Large writes the full structure.
- **Independent agents for 6–8.** Test-writer ≠ implementer ≠ reviewer. Bias guardrail. (Large only — Small implements directly.)
- **Red commit SHA is the handoff artifact** from step 6 to step 7. Impl cannot start before red is committed. (Large only.)
- **Loop back freely.** If reality contradicts the plan, update the plan. Don't silently bypass it. If a Small task outgrows its size, restart it as Large.
- **User overrides always win.** CLAUDE.md and direct instructions beat this skill — including the size choice.
- **One worktree per repo.** Each `repos:` entry gets a worktree at `<repo_parent>/<repo_name>-worktrees/<slug>`, recorded in that entry's `worktree:`. A task runs in the worktree of the repo it is tagged with. Cleanup happens via the safe-prune sweep before worktree creation (only merged + clean worktrees are removed) and explicitly in step 9 after each PR merges.

## When to skip Memento entirely

Trivial one-line fixes, typo corrections, config tweaks, doc edits. Below even the Small route — just do it. Memento is for multi-step implementation work.
