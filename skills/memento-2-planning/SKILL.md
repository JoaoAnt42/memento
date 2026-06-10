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
- [ ] T1 [repo: <label>] [disjoint]: ...
- [ ] T2 [repo: <label>] [disjoint]: ...
- [ ] T5 [repo: <label>]: ...   <!-- no [disjoint] → barrier; runs after the parallel group above merges -->

## Open risks
- ...
```

**While questioning** (live), keep the 4 options visible so the user can pick from them. **Once the user answers**, collapse the question to the one-line `Decisions` bullet above and delete the option list. The unselected options are dead weight — the picked answer + reason is the load-bearing record.

## Design seed (optional — new-system / large plans only)

For a **new service, system, or any multi-seam plan**, optionally produce a C4 design document *before* filling `## Data contract`. Skip it for small single-seam features — it's overkill there. Adapted from Fabric's `create_design_document` (C4 model).

Emit the sections below, then **fold the result back into the plan**: the container/component boundaries become `## Data contract` seams; unconfirmed security controls or domain rules become `## Open risks` (BLOCKING-tagged per the confidence gate). It is a *seed*, not a deliverable — it lives inline in the plan, or in a sibling `YYYY-MM-DD-<slug>-design.md` in the same plans dir, and is not re-litigated downstream.

- **Business posture** — priorities, goals, and the top business risks the system addresses.
- **Security posture** — existing controls (prefix each `security control`), `accepted risk`s, recommended high-priority controls not yet present, and security requirements.
- **C4 Context** — mermaid diagram: the system as one box, surrounded by its users and neighbouring systems. Then a table: Name / Type / Description / Responsibilities / Security controls.
- **C4 Container** — mermaid diagram: high-level shape, how responsibilities split across containers, major tech choices, inter-container comms. Same 5-column table.
- **C4 Deployment** — mermaid diagram: how containers map onto infrastructure for the target environment. Same 5-column table.
- **Risk assessment** — what is most worth protecting and why.
- **Questions & assumptions** — open questions plus the default assumptions you took across posture and design.

## Rules

- **Propose-4-options, one question at a time.** Every question where multiple reasonable answers exist: 4 options, pick one, say why. **Ask one question per turn — wait for the user's answer before moving on.** Batching 8 questions at once is daunting and produces shallow answers. The picked option + user response is recorded in the file as each one resolves.
- **Order questions by blast radius.** Ask the decisions that constrain later decisions first (architecture > scope > interface > implementation detail). A later answer should never invalidate an earlier one.
- **Self-research first.** Spawn Agent(Explore) against the codebase. Read relevant code. Never ask what you can discover.
- **Confidence + falsifier on load-bearing claims.** Tag every research finding scope rests on with confidence (high / medium / low), a falsifier, and its source. A claim below HIGH goes in `## Open risks` with its falsifier. A *domain or business-rule* claim below HIGH is not a risk to note — it is a **blocking confirmation**: flag it in `## Open risks` as `BLOCKING — confirm with team leader` and resolve it before the plan leaves planning. (Planning does its own research — re-apply this gate here even if brainstorming already cleared a claim.)
- **Design seed is optional and gated.** Only for new systems or multi-seam plans (see [Design seed](#design-seed-optional--new-system--large-plans-only)). Its C4 boundaries seed `## Data contract`; its unconfirmed security or domain items seed `## Open risks` under the same confidence gate. Never run it for small single-seam features.
- **Append, don't overwrite.** Each subsequent step (auto-review, implementation notes, review outcomes) appends a section.
- **Status frontmatter.** Update `status:` as the cycle advances.
- **Tasks are atomic.** Each task must be independently testable so steps 6–8 can dispatch independent agents.
- **Every task names its repo.** Tag each task `[repo: <label>]` matching a `repos:` entry — this is how steps 6–8 know which worktree to run it in. A single-repo plan still tags; there is just one label.
- **Pin seams, not steps.** For large or multi-seam plans, fill `## Data contract`: fix module boundaries, signatures, and what data crosses each seam. This is the anti-drift anchor steps 6–8 enforce against — tasks decompose *from* it. Pin *boundaries*, not every internal step: over-specifying detail you can't yet know makes the plan brittle and invites rigid-but-wrong implementation. Omit the section entirely for small single-seam tasks.
- **`[disjoint]` authorizes parallelism.** Tag a task `[disjoint]` only when self-research has *verified* it touches a file set no sibling task touches — then steps 6–7 may run it concurrently with other same-repo `[disjoint]` tasks via per-task worktree + merge. A task **without** `[disjoint]` is a **barrier**: it runs sequentially, after the preceding tasks complete and merge (this is how a dependent task sequences behind a group of independent ones). Default to no flag — claim disjointness only when proven, because a wrong claim costs a merge conflict mid-cycle.

## Transition

A plan carrying an unresolved `BLOCKING — confirm with team leader` item in `## Open risks` is not done — it cannot transition. Confirm the claim against the team leader, a written spec, or the prior implementation first.

When the user approves the draft plan and no BLOCKING confirmation is open, invoke `memento-3-auto-review` with the plan path.

## Output discipline

- Plan-write handoff: one line — `Plan written: <path>`. No task recap, no parallelism commentary, no "review and I'll run step 3". The user reads the file.
- Parallelize freely. Independent research agents, file reads, or checks go in a single message. Never narrate "these can run in parallel" — just batch them.
