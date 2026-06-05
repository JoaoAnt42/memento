---
name: memento-2-planning
description: Step 2 of Memento. Use after brainstorming converges, to write a durable plan markdown in the Obsidian plans directory. Enforces propose-4-options questioning and keeps plans out of the repo.
---

# Memento — Planning

Write the plan to `~/Documents/be_JLA/work/plans/YYYY-MM-DD-<slug>.md`. Never into the repo.

## Plan file structure

```markdown
---
name: <slug>
status: planning
created: YYYY-MM-DD
type: feat|fix|refactor|chore|docs|test|style|perf|ci|build   # required. The conventional-commit / PR-title prefix.
needs_human_smoke: true|false   # required, no default. true for user-visible behavior; false for pure internal work.
repos:                           # required. One entry per repo the plan touches. A single-repo plan is a one-element list.
  - label: <short-id>            #   short id (backend, frontend, or `repo` for a single-repo plan). Tasks reference it.
    path: <abs-path>             #   absolute path to the source repo root.
    base: <branch>               #   branch the worktree forks from (main, DEV_Verdo, …). Default main.
    branch: <type>/<slug>        #   the feature branch; may continue an existing branch.
    worktree:                    #   absolute path — set by step 4 on approve. Empty during planning.
---

# <Title>

## Context
<what, why, constraints>

## Decisions
- **Q1 <topic>:** <picked answer> — <one-line reason>. (User: confirm | override → <new>)
- **Q2 <topic>:** <picked answer> — <one-line reason>. (User: confirm)

## Data contract   <!-- large / multi-seam plans only; omit for small single-seam tasks -->
Pin the **seams**, not the internal steps. For each boundary the work crosses:
- **<module/function>** — signature `<in> → <out>`; consumes `<data>`, produces `<data>`.
- Flow: `<source> → <seam> → <seam> → <sink>`.

Anything not listed here is **out of contract**: the implementer may not introduce a new module, layer, or path without amending this section first.

## Tasks
- [ ] T1 [repo: <label>]: ...
- [ ] T2 [repo: <label>]: ...

## Open risks
- ...
```

**While questioning** (live), keep the 4 options visible so the user can pick from them. **Once the user answers**, collapse the question to the one-line `Decisions` bullet above and delete the option list. The unselected options are dead weight — the picked answer + reason is the load-bearing record.

## Rules

- **Propose-4-options, one question at a time.** Every question where multiple reasonable answers exist: 4 options, pick one, say why. **Ask one question per turn — wait for the user's answer before moving on.** Batching 8 questions at once is daunting and produces shallow answers. The picked option + user response is recorded in the file as each one resolves.
- **Order questions by blast radius.** Ask the decisions that constrain later decisions first (architecture > scope > interface > implementation detail). A later answer should never invalidate an earlier one.
- **Self-research first.** Spawn Agent(Explore) against the codebase. Read relevant code. Never ask what you can discover.
- **Confidence + falsifier on load-bearing claims.** Tag every research finding scope rests on with confidence (high / medium / low), a falsifier, and its source. A claim below HIGH goes in `## Open risks` with its falsifier. A *domain or business-rule* claim below HIGH is not a risk to note — it is a **blocking confirmation**: flag it in `## Open risks` as `BLOCKING — confirm with team leader` and resolve it before the plan leaves planning. (Planning does its own research — re-apply this gate here even if brainstorming already cleared a claim.)
- **Append, don't overwrite.** Each subsequent step (auto-review, implementation notes, review outcomes) appends a section.
- **Status frontmatter.** Update `status:` as the cycle advances.
- **Tasks are atomic.** Each task must be independently testable so steps 6–8 can dispatch independent agents.
- **Every task names its repo.** Tag each task `[repo: <label>]` matching a `repos:` entry — this is how steps 6–8 know which worktree to run it in. A single-repo plan still tags; there is just one label.
- **Pin seams, not steps.** For large or multi-seam plans, fill `## Data contract`: fix module boundaries, signatures, and what data crosses each seam. This is the anti-drift anchor steps 6–8 enforce against — tasks decompose *from* it. Pin *boundaries*, not every internal step: over-specifying detail you can't yet know makes the plan brittle and invites rigid-but-wrong implementation. Omit the section entirely for small single-seam tasks.

## Transition

A plan carrying an unresolved `BLOCKING — confirm with team leader` item in `## Open risks` is not done — it cannot transition. Confirm the claim against the team leader, a written spec, or the prior implementation first.

When the user approves the draft plan and no BLOCKING confirmation is open, invoke `memento-3-auto-review` with the plan path.

## Output discipline

- Plan-write handoff: one line — `Plan written: <path>`. No task recap, no parallelism commentary, no "review and I'll run step 3". The user reads the file.
- Parallelize freely. Independent research agents, file reads, or checks go in a single message. Never narrate "these can run in parallel" — just batch them.
