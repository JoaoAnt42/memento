---
name: memento-4-human-review
description: Step 4 of Memento. Use after auto-review. Submits the updated plan to the user for approval, rejection, or revision. Loops back to planning on rejection.
---

# Memento — Human Review

Submit the updated plan to the user. Wait for verdict.

## Protocol

1. Summarize the plan in ≤10 bullets (title, task list, top 3 decisions, top 3 risks). Link the plan file path.
2. Ask for verdict: **approve / revise / reject**.
3. Responses:
   - **approve** → run the **safe-prune sweep** (below), then create a per-plan worktree and `cd` into it. Set `status: tdd-red`, invoke `memento-6-tdd-red`.
   - **revise** → capture requested changes, set `status: planning`, invoke `memento-2-planning` to amend.
   - **reject** → set `status: planning`, loop back to `memento-1-brainstorming` (premise is wrong).

## Worktree creation (on approve)

Path convention: `<repo_parent>/<repo_name>-worktrees/<plan-slug>`. Branch: `<type>/<plan-slug>` from `main`, where `<type>` is the plan frontmatter `type:` (`feat`, `fix`, `refactor`, …). Same prefix used for the eventual conventional-commit message and PR title.

```sh
REPO=$(git rev-parse --show-toplevel)
ROOT=$(dirname "$REPO")/$(basename "$REPO")-worktrees
mkdir -p "$ROOT"
WT="$ROOT/<plan-slug>"
BRANCH="<type>/<plan-slug>"
# Reuse if branch + worktree already exist; otherwise create both.
git worktree add "$WT" -b "$BRANCH" main 2>/dev/null \
  || git worktree add "$WT" "$BRANCH"
cd "$WT"
```

Record the worktree path in the plan frontmatter as `worktree: <abs-path>`. All subsequent steps (6, 7, 7b, 8, 9) operate from this directory — subagents inherit cwd.

## Safe-prune sweep

Run before creating the new worktree. **Only prune worktrees that live under `<repo>-worktrees/` AND whose branch is merged into `main` AND whose working tree is clean.** No age cutoff. No exceptions for unmerged or dirty trees. The path filter is the safety guard — keeps memento away from worktrees it didn't create.

```sh
REPO=$(git rev-parse --show-toplevel)
ROOT=$(dirname "$REPO")/$(basename "$REPO")-worktrees
git -C "$REPO" fetch --prune origin main 2>/dev/null || true
git -C "$REPO" worktree list --porcelain | awk '
  /^worktree /{wt=$2} /^branch /{br=$2; print wt "\t" br}
' | while IFS=$'\t' read -r wt br; do
  [ "$wt" = "$REPO" ] && continue
  # Path filter: only worktrees memento manages.
  case "$wt" in "$ROOT"/*) ;; *) continue ;; esac
  short=${br#refs/heads/}
  # Merged into main?
  if ! git -C "$REPO" merge-base --is-ancestor "$short" main 2>/dev/null; then
    continue
  fi
  # Clean working tree?
  if [ -n "$(git -C "$wt" status --porcelain 2>/dev/null)" ]; then
    continue
  fi
  git -C "$REPO" worktree remove "$wt"
  git -C "$REPO" branch -d "$short" 2>/dev/null || true
done
```

If a worktree is skipped (unmerged or dirty), leave it. Don't warn unless the user asks.

## Rule

Never proceed past approval without explicit approval. "Looks fine" counts; silence does not.
