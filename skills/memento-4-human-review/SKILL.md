---
name: memento-4-human-review
description: Step 4 of Memento. Use after auto-review. Submits the updated plan to the user for approval, rejection, or revision. Loops back to planning on rejection.
---

# Memento — Human Review

Submit the updated plan to the user. Wait for verdict.

**Unattended sessions stop here** (`memento-0-using` step 0d). Set `status: auto-review`, report the plan path plus the `## Decisions taken unilaterally` list, and end the run. Do not synthesize a verdict, do not safe-prune, do not create worktrees. The human runs this step later from their own session. Approving your own plan is the one step in this cycle with no downstream check on it.

## Protocol

1. Summarize the plan in ≤10 bullets (title, task list, top 3 decisions, top 3 risks). Link the plan file path.
2. Ask for verdict: **approve / revise / reject**.
3. Responses:
   - **approve** → run the **safe-prune sweep** (below), then create the worktrees — one per `repos:` entry. Set `status: tdd-red`, invoke `memento-6-tdd-red`.
   - **revise** → capture requested changes, set `status: planning`, invoke `memento-2-planning` to amend.
   - **reject** → set `status: planning`, loop back to `memento-1-brainstorming` (premise is wrong).

## Worktree creation (on approve)

Run **once per entry** in the plan's `repos:` list. A single-repo plan has one entry; a multi-repo plan (e.g. backend + frontend) has several. Worktree path convention: `<repo_parent>/<repo_name>-worktrees/<plan-slug>`. If an entry's `worktree:` is already filled and exists (a repo continuing an earlier branch), reuse it instead of creating.

For each entry, set `REPO`/`BASE`/`BRANCH` from its `path`/`base`/`branch` and run:

```sh
# REPO=<entry.path>  BASE=<entry.base>  BRANCH=<entry.branch>
ROOT=$(dirname "$REPO")/$(basename "$REPO")-worktrees
mkdir -p "$ROOT"
WT="$ROOT/<plan-slug>"
# Reuse if branch + worktree already exist; otherwise create the branch from BASE.
git -C "$REPO" worktree add "$WT" -b "$BRANCH" "$BASE" 2>/dev/null \
  || git -C "$REPO" worktree add "$WT" "$BRANCH"
# Local memory is gitignored, so it does NOT follow the worktree — relink it.
# No-op where the helper isn't installed.
[ -f ~/.claude/local/link.sh ] && sh ~/.claude/local/link.sh "$WT" || true
```

A worktree starts without the repo's `CLAUDE.local.md` — gitignored files don't come along. The relink above restores it so steps 6–9 see the same local context as the main checkout.

Record each worktree path back into its `repos:` entry as `worktree: <abs-path>`. Subsequent steps (6, 7, 7b, 8, 9) do **not** share one cwd — each task is tagged `[repo: <label>]`, and its agent runs in that repo's worktree.

## Safe-prune sweep

Run before creating worktrees — **once per distinct `path` in the plan's `repos:` list.** **Only prune worktrees that live under `<repo>-worktrees/` AND whose branch is merged into that repo's base AND whose working tree is clean.** No age cutoff. No exceptions for unmerged or dirty trees. The path filter is the safety guard — keeps memento away from worktrees it didn't create.

```sh
# REPO=<entry.path>  BASE=<entry.base>
ROOT=$(dirname "$REPO")/$(basename "$REPO")-worktrees
git -C "$REPO" fetch --prune origin "$BASE" 2>/dev/null || true
git -C "$REPO" worktree list --porcelain | awk '
  /^worktree /{wt=$2} /^branch /{br=$2; print wt "\t" br}
' | while IFS=$'\t' read -r wt br; do
  [ "$wt" = "$REPO" ] && continue
  # Path filter: only worktrees memento manages.
  case "$wt" in "$ROOT"/*) ;; *) continue ;; esac
  short=${br#refs/heads/}
  # Merged into this repo's base?
  if ! git -C "$REPO" merge-base --is-ancestor "$short" "$BASE" 2>/dev/null; then
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
