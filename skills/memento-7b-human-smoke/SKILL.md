---
name: memento-7b-human-smoke
description: Step 7.5 of Memento — optional human smoke test. Use after implementation is green and before final-review, when the plan frontmatter has `needs_human_smoke: true`. Starts dev server + deps, hands the user a checklist, and waits for verdict.
---

# Memento — Human Smoke Test

Catch "tests pass but feature feels wrong" before reviewers rubber-stamp it.

## Gate

Run this step only if the plan frontmatter has `needs_human_smoke: true`. The flag is **required** (no default) — set consciously during planning:

- User-visible behavior (UI, CLI output, API surface) → `true`
- Pure internal refactors, backend-only CRUD with full integration test coverage → `false`

If the flag is missing, halt and ask the user to set it in the plan.

## Protocol

1. Read the plan. Extract `needs_human_smoke`. If `false`, skip to `memento-8-final-review`.
2. Start services. In a multi-repo plan, start each repo's services from that repo's worktree (the matching `repos:` entry). Typical:
   - Dev server (e.g. `npm run dev`, `pnpm dev`, `uvicorn`, `dotnet run`)
   - Dependencies (docker compose up, db migrations, seed data)
   - Use `run_in_background: true` so you stay responsive.
3. Generate a **checklist of things to click/verify**, derived from the tasks + known edge cases. Include:
   - URL (e.g. `http://localhost:3000/foo`)
   - Steps to reproduce the happy path
   - Steps for each edge case the tests cover
   - Anything that is hard to assert automatically (animations, visual polish, copy)
4. Present to user. Wait for verdict: **ok / found-issue: <description>**.
5. On ok → append `## Human smoke: pass` to plan, set `status: final-review`, invoke `memento-8-final-review`.
6. On found-issue → analyze the issue:
   - If tests missed the case → loop back to `memento-6-tdd-red` to add a failing test, then `memento-7-implementing`.
   - If impl is wrong but tests are fine → loop back to `memento-7-implementing`.
   - If the plan itself was wrong → loop back to `memento-2-planning`.
7. **Shut down started services on exit** (success or failure). No orphan processes.

## Rules

- Flag is required in the plan frontmatter. No silent skip.
- Services started here are owned here — this step shuts them down.
- If a service fails to start, that's the smoke test failing. Fix before proceeding.
- Checklist must be concrete: URLs, clicks, expected outcomes. No "verify it works".

## Transition

ok → `memento-8-final-review`. found-issue → loop back per diagnosis.
