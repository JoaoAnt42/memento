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
type: feat|fix|refactor|chore|docs|test|style|perf|ci|build   # required. Drives the branch prefix (`<type>/<slug>`) and the eventual conventional-commit / PR title.
needs_human_smoke: true|false   # required, no default. true for user-visible behavior; false for pure internal work.
worktree:                        # set by step 4 on approve. Absolute path to the per-plan git worktree. Empty during planning.
---

# <Title>

## Context
<what, why, constraints>

## Decisions
- **Q1 <topic>:** <picked answer> — <one-line reason>. (User: confirm | override → <new>)
- **Q2 <topic>:** <picked answer> — <one-line reason>. (User: confirm)

## Tasks
- [ ] T1: ...
- [ ] T2: ...

## Open risks
- ...
```

**While questioning** (live), keep the 4 options visible so the user can pick from them. **Once the user answers**, collapse the question to the one-line `Decisions` bullet above and delete the option list. The unselected options are dead weight — the picked answer + reason is the load-bearing record.

## Rules

- **Propose-4-options, one question at a time.** Every question where multiple reasonable answers exist: 4 options, pick one, say why. **Ask one question per turn — wait for the user's answer before moving on.** Batching 8 questions at once is daunting and produces shallow answers. The picked option + user response is recorded in the file as each one resolves.
- **Order questions by blast radius.** Ask the decisions that constrain later decisions first (architecture > scope > interface > implementation detail). A later answer should never invalidate an earlier one.
- **Self-research first.** Spawn Agent(Explore) against the codebase. Read relevant code. Never ask what you can discover.
- **Append, don't overwrite.** Each subsequent step (auto-review, implementation notes, review outcomes) appends a section.
- **Status frontmatter.** Update `status:` as the cycle advances.
- **Tasks are atomic.** Each task must be independently testable so steps 6–8 can dispatch independent agents.

## Transition

When user approves the draft plan, invoke `memento-3-auto-review` with the plan path.

## Output discipline

- Plan-write handoff: one line — `Plan written: <path>`. No task recap, no parallelism commentary, no "review and I'll run step 3". The user reads the file.
- Parallelize freely. Independent research agents, file reads, or checks go in a single message. Never narrate "these can run in parallel" — just batch them.
