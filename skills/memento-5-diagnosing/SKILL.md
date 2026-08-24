---
name: memento-5-diagnosing
description: Step 5 of Memento. Use when human review approves a plan whose `type` is `fix` or `perf`, after the worktree exists and before tdd-red. Builds a red-capable feedback loop, reproduces and minimises the bug, ranks hypotheses, instruments, and records a machine-verified cause for step 6's test-writer.
---

# Memento — Diagnosing

Find the cause before anyone writes a test against the symptom. Output is a confirmed mechanism plus one command that goes red on it.

**Entry.** Every `fix` / `perf` plan enters this step. It exits immediately — at protocol 1 — only when the plan already carries a recorded command that the verifier re-runs and observes go red. The skip is machine-checked, never self-asserted: `swr-fetcher-key-pairing` self-reported "reproduced in a harness" when it had not been, and grew from 2 hooks to 57 files on that claim. Claim-source tags (`reproduced observation` vs `code read` / `inference`, `memento-1-brainstorming:39`) are a prompt for what to verify first, not the gate.

Run in the plan's `worktree:` — this step mutates files.

## Protocol

1. Plan names a command → dispatch the verifier (4) on it. Red for the stated reason → write `## Diagnosis` from what it observed and transition. Anything else → continue.

2. **Loop, reproduce, minimise.** Build a tight pass/fail signal that goes red on *this* bug, in roughly this order: failing test at whatever seam reaches the bug; curl/HTTP script against a dev server; CLI invocation diffed against a known-good snapshot; headless browser script asserting DOM/console/network; replay of a captured trace; throwaway harness over a minimal subset; property/fuzz loop for "sometimes wrong"; bisection harness across two known states; differential loop across two versions or configs. Then **tighten** it — faster, sharper assertion (the user's exact symptom, not "didn't crash"), more deterministic (pin time, seed RNG, isolate fs, freeze network). Non-deterministic bugs: the goal is a **higher reproduction rate**, not a clean repro — loop the trigger, parallelise, add stress, inject sleeps, until it is debuggable. Run it, watch it go red on the failure mode the *user* described, then minimise: cut inputs, callers, config and steps one at a time, re-running after each cut, until every remaining element is load-bearing.

   Done when you can name **one command**, already run at least once (invocation and output shown, redacted), that is red-capable, deterministic, fast, and agent-runnable. **No red-capable command, no hypotheses** — jumping to a theory is the exact failure this step prevents. If you genuinely cannot build one, stop and say so: what you tried, plus a request for environment access, a redacted captured artifact, or permission to instrument.

3. **Hypothesise, then instrument.** Generate **3–5 ranked hypotheses before testing any of them**, each falsifiable and stating its prediction ("if X is the cause, changing Y makes the bug disappear"). No prediction → it is a vibe; sharpen or discard. Show the ranked list to the user — **non-blocking**, proceed on your own ranking if they are AFK. Then instrument **one variable at a time**, every probe mapped to a specific prediction: debugger/REPL over targeted boundary logs, never "log everything and grep". Tag every debug log `[DEBUG-<hash>]` so cleanup is one grep. Perf regressions: baseline measurement first (timing harness, profiler, query plan), then bisect — logs are the wrong instrument there.

4. Dispatch an independent **verifier subagent** (`model: haiku`) to run the recorded command cold and confirm it goes red **for the stated reason** — not a syntax error, not a missing import. Mechanical role; Haiku is correct. This is the only control in the cycle a false "reproduced" claim cannot survive.

5. Cause confirmed → append to the plan, exactly two fields:

```markdown
## Diagnosis

Mechanism: <confirmed cause>, `path/to/file.ts:214`
Verification: `<one-shot command>` → <observed red output, redacted>
```

6. Cause refuted → append the refuted theory and the real finding to `## Diagnosis`, mark invalidated tasks **individually**, clean the worktree, set `status: planning`, loop to `memento-2-planning` (which re-runs 3 and 4).

## Rules

- **The loop is the skill.** Everything after it is mechanical. Spend disproportionate effort there. Be aggressive, be creative, refuse to give up.
- **One-shot, not watch loop.** The recorded command must exit and be rerunnable. `wpy` / `wts` / `wcs` (`~/.zshrc:146-149`, `watchexec … --clear -- <runner>`, blocking until Ctrl-C) are the human's companion while iterating and can never be the recorded command — they never exit. `wts` runs `yarn check-types`, not `tsc`.
- **The diagnosing agent writes no test.** `Verification` is a repro command, not a regression test. Step 6 reads `Mechanism` into the test-writer's brief and still produces 1 happy + 1 edge.
- **Refutation is usually partial.** `citations-sort-page-remount` refuted its fix theory while its coverage-gap test stayed valid and shipped. Invalidate the tasks the finding actually touches; leave the rest.
- **Clean before looping back.** Remove every `[DEBUG-…]` probe and throwaway harness. Step 4 reuses an existing `worktree:` rather than recreating it, so an uncleaned tree contaminates the retry.
- **Redact every secret** in any command or output shown — `<REDACTED>` in its place, loops built against env vars. If the redacted output is not enough to diagnose, say so and ask.
- **No fourth human gate.** The hypothesis checkpoint is non-blocking, so this step runs unattended end to end.

## Transition

Confirmed → `status: tdd-red`, invoke `memento-6-tdd-red`. Refuted → `status: planning`, invoke `memento-2-planning`.
