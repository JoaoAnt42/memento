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
   - **approve** → set `status: workbench`, invoke `memento-5-workbench`.
   - **revise** → capture requested changes, set `status: planning`, invoke `memento-2-planning` to amend.
   - **reject** → set `status: planning`, loop back to `memento-1-brainstorming` (premise is wrong).

## Rule

Never proceed to workbench without explicit approval. "Looks fine" counts; silence does not.
