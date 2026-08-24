---
name: memento-5-diagnosing
description: Step 5 of Memento. Use when human review approves a plan whose `type` is `fix` or `perf`, after the worktree exists and before tdd-red. Builds a red-capable feedback loop, reproduces and minimises the bug, ranks hypotheses, instruments, and records a machine-verified cause for step 6's test-writer.
---

# Memento — Diagnosing

Find the cause before anyone writes a test against the symptom. Output is a confirmed mechanism plus one command that goes red on it.

**Entry.** Every `fix` / `perf` plan enters this step — it is not skippable by judgement. It exits at protocol 1 only when the plan already carries a `Verification:` command **and** a falsifiable prediction, and the verifier confirms both. The skip is machine-checked, never self-asserted.

Step 2 may pre-seed `Verification:` when the author actually ran a repro (the `reproduced observation` tier, `memento-1-brainstorming:39`). Step 2 never writes `Mechanism:` — a cause is only ever written here, after verification.

Run in the plan's `worktree:` — this step mutates files. It assumes **one repo, one cause**; a multi-repo plan whose symptom may have several causes needs human confirmation before proceeding.

## Protocol

1. Plan carries `Verification:` + a prediction → dispatch the verifier (4). Confirmed → write `Mechanism:` from what it observed and transition. Anything else → continue.

2. **Loop, reproduce, minimise.** Build a tight pass/fail signal that goes red on *this* bug — test, HTTP script, CLI diff against a known-good snapshot, headless browser assertion, replayed trace, throwaway harness, fuzz loop, bisection, whatever reaches it fastest. Then **tighten**: faster, sharper assertion (the user's exact symptom, not "didn't crash"), more deterministic (pin time, seed RNG, isolate fs, freeze network). Non-deterministic bugs: the goal is a **higher reproduction rate**, not a clean repro — loop the trigger, parallelise, add stress, inject sleeps, until it is debuggable. For `perf`, red means **a measured budget breached** — establish the baseline first, then assert against it; a timing number with no threshold is not a signal. Run it, watch it go red on the failure mode the *user* described, then minimise: cut inputs, callers, config and steps one at a time, re-running after each cut, until every remaining element is load-bearing.

   Done when you can name **one command**, already run at least once (invocation and output shown, redacted), that is red-capable, deterministic, fast, and agent-runnable. **No red-capable command, no hypotheses** — jumping to a theory is the exact failure this step prevents.

3. **Hypothesise, then instrument.** Generate **3–5 ranked hypotheses before testing any of them**, each falsifiable and stating its prediction ("if X is the cause, changing Y makes the bug disappear"). No prediction → it is a vibe; sharpen or discard. Show the ranked list to the user — **non-blocking**, proceed on your own ranking if they are AFK. Then instrument **one variable at a time**, every probe mapped to a specific prediction: debugger/REPL over targeted boundary logs, never "log everything and grep". Tag every debug log `[DEBUG-<hash>]` so cleanup is one grep. Perf regressions: baseline measurement first (timing harness, profiler, query plan), then bisect — logs are the wrong instrument there.

4. Dispatch an independent **verifier subagent** (`model: haiku`) to run the recorded command cold. It confirms the command goes red for real — not a syntax error, not a missing import — **and** that the claimed mechanism's prediction holds: patching or reverting the named `file:line` turns it green, or the red output names the claimed frame, query or value. A red command with an unchecked mechanism is not a diagnosis. Mechanical role; Haiku is correct.

5. **Clean the worktree — both outcomes, before any transition.** Remove every `[DEBUG-…]` probe and throwaway harness. Step 4 reuses an existing `worktree:` rather than recreating it, and step 6 commits whatever is in the tree, so an uncleaned tree either ships debug code or makes local green disagree with CI.

6. Write the plan's `## Diagnosis` — **replace or create, never append.** The plan must contain exactly one:

```markdown
## Diagnosis

Mechanism: <confirmed cause>, `path/to/file.ts:214`
Verification: `<one-shot command>` → <observed red output, redacted>
Refuted: <theory> — <what falsified it>
```

## Rules

- **The loop is the skill.** Everything after it is mechanical. Spend disproportionate effort there. Be aggressive, be creative, refuse to give up.
- **One-shot, not watch loop.** The recorded command must exit and be rerunnable. A watch-mode wrapper that blocks until interrupted can never be the recorded command.
- **The diagnosing agent writes no test.** `Verification` is a repro command, not a regression test. Step 6 reads `Mechanism` into the test-writer's brief and still produces 1 happy + 1 edge.
- **Refutation is usually partial.** Invalidate the tasks the finding actually touches; leave the rest.
- **Second refutation on the same plan → stop and escalate.** A theory refuted twice means the premise is wrong, not the theory. Hand back and recommend `reject` to `memento-1-brainstorming` rather than another lap.
- **Redact every secret** in any command or output shown — `<REDACTED>` in its place, loops built against env vars. If the redacted output is not enough to diagnose, say so and ask.
- **No fourth human gate.** The hypothesis checkpoint is non-blocking. An unattended run never reaches this step — it hard-stops at the step-4 verdict.

## Transition

Clean the worktree first (protocol 5), then:

- **Cause confirmed** → `status: tdd-red`, invoke `memento-6-tdd-red`.
- **Cause refuted** → record the real finding under `Refuted:`, mark invalidated tasks individually, `status: planning`, invoke `memento-2-planning`.
- **No reproducible symptom** — a corrective `fix` with a known cause and nothing to reproduce (a guard spotted in review, a typo) → `Verification: none — <one-line why>`, `status: tdd-red`, invoke `memento-6-tdd-red`.
- **Repro blocked** — needs environment access, a captured artifact, or permission to instrument → `status: human-review`, hand back what you tried and what you need. Stop.
