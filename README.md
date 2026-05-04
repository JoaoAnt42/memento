# Memento

A Claude Code way-of-work cycle. Maximize confidence over speed.

**brainstorm → plan → auto-review → human-review → workbench → TDD-red → implement → smoke → final-review → receiving-review**

Independent agents for test / implement / review. Red-commit SHA is the handoff artifact.

## Install

```
/plugin marketplace add JoaoAnt42/memento
/plugin install memento@memento
```

That's it — skills and the `/use_memento` command are now available.

### Manual install (no plugin system)

```bash
git clone https://github.com/JoaoAnt42/memento
cd memento
for d in skills/*/; do
  name="$(basename "$d")"
  mkdir -p ~/.claude/skills/"$name"
  cp "$d/SKILL.md" ~/.claude/skills/"$name"/SKILL.md
done
cp commands/use_memento.md ~/.claude/commands/use_memento.md
```

## Use

```
/use_memento <task description>
```

Entry point is `memento-0-using`. Each step invokes the next skill in sequence.

## Steps

| Step | Skill | Purpose |
|---|---|---|
| 0 | `memento-0-using` | Entry point, cycle overview |
| 1 | `memento-1-brainstorming` | Explore intent, self-research first |
| 2 | `memento-2-planning` | Write plan in Obsidian, propose-4-options |
| 3 | `memento-3-auto-review` | Devil's Advocate + Simplifier + Orchestrator |
| 4 | `memento-4-human-review` | Submit plan; rejection loops back to step 2 |
| 5 | `memento-5-workbench` | Git worktree per task |
| 6 | `memento-6-tdd-red` | Write failing tests, commit red SHA |
| 7 | `memento-7-implementing` | Independent impl agent, input = red SHA |
| 7.5 | `memento-7b-human-smoke` | Optional; gated by `needs_human_smoke: true` |
| 8 | `memento-8-final-review` | Parallel reviewers, precedence: Bugs > CRAP > Simplifier > DA > Tests |
| 9 | `memento-9-receiving-review` | Verify, push back, or implement. Loops back to step 8 on non-trivial review changes. |

## Requirements

- Claude Code with plugin / skill support
