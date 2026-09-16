#!/bin/sh
set -u

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
root_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
cd "$root_dir" || exit 1

fail_count=0

pass() {
  printf 'PASS %s\n' "$1"
}

fail() {
  printf 'FAIL %s: %s\n' "$1" "$2"
  fail_count=$((fail_count + 1))
}

skill=skills/memento-5-diagnosing/SKILL.md

if [ -f "$skill" ]; then
  pass diagnosing-skill-file-exists
else
  fail diagnosing-skill-file-exists "$skill to exist"
fi

if [ -f "$skill" ] && grep -qE '^name: memento-5-diagnosing$' "$skill"; then
  pass diagnosing-skill-frontmatter-name
else
  fail diagnosing-skill-frontmatter-name "$skill frontmatter to contain 'name: memento-5-diagnosing'"
fi

if [ -f "$skill" ] \
  && grep -qE '^## Diagnosis' "$skill" \
  && grep -qE '^Mechanism:' "$skill" \
  && grep -qE '^Verification:' "$skill"; then
  pass diagnosing-skill-output-contract
else
  fail diagnosing-skill-output-contract "$skill to carry a '## Diagnosis' block with anchored Mechanism: and Verification: field lines"
fi

if [ -f "$skill" ] \
  && grep -q 'status: planning' "$skill" \
  && grep -q 'memento-2-planning' "$skill"; then
  pass diagnosing-defines-refutation-loopback
else
  fail diagnosing-defines-refutation-loopback "$skill to route a refuted cause back to memento-2-planning with status: planning"
fi

if [ -f "$skill" ] \
  && grep -q 'Repro blocked' "$skill" \
  && grep -q 'No reproducible symptom' "$skill"; then
  pass diagnosing-defines-non-binary-exits
else
  fail diagnosing-defines-non-binary-exits "$skill Transition to name an exit for a blocked repro and for a fix with no reproducible symptom"
fi

if [ -f "$skill" ] && grep -q 'both outcomes' "$skill"; then
  pass diagnosing-cleanup-is-unconditional
else
  fail diagnosing-cleanup-is-unconditional "$skill to require worktree cleanup on both outcomes, not only on the refutation path"
fi

if [ -f "$skill" ] && ! grep -q 'zshrc' "$skill"; then
  pass diagnosing-skill-carries-no-machine-local-paths
else
  fail diagnosing-skill-carries-no-machine-local-paths "$skill to carry no machine-local dotfile references"
fi

if [ -f skills/memento-0-using/SKILL.md ]; then
  using_route_section=$(sed -n '/^### Large route/,/^## /p' skills/memento-0-using/SKILL.md)
else
  using_route_section=""
fi
if printf '%s' "$using_route_section" | grep -q 'memento-5-diagnosing'; then
  pass using-large-route-lists-diagnosing
else
  fail using-large-route-lists-diagnosing "skills/memento-0-using/SKILL.md Large-route step list to mention memento-5-diagnosing"
fi

if printf '%s' "$using_route_section" | grep -qE 'memento-5-diagnosing.*\*\*optional\*\*'; then
  fail step-5-not-described-as-optional "step 5 to be described as mandatory for fix/perf, not optional like the flag-gated 7b and 8b"
else
  pass step-5-not-described-as-optional
fi

if [ -f skills/memento-4-human-review/SKILL.md ] \
  && grep -qE 'fix.*perf.*status: diagnosing.*memento-5-diagnosing' skills/memento-4-human-review/SKILL.md; then
  pass human-review-routes-fix-perf-to-diagnosing
else
  fail human-review-routes-fix-perf-to-diagnosing "skills/memento-4-human-review/SKILL.md approve branch to route fix/perf to status: diagnosing and memento-5-diagnosing on one line"
fi

if [ -f skills/memento-6-tdd-red/SKILL.md ] && grep -qE '## Diagnosis' skills/memento-6-tdd-red/SKILL.md; then
  pass tdd-red-consumes-diagnosis-section
else
  fail tdd-red-consumes-diagnosis-section "skills/memento-6-tdd-red/SKILL.md to reference the '## Diagnosis' section it consumes"
fi

if [ -f skills/memento-6-tdd-red/SKILL.md ] && grep -q 'DEBUG-' skills/memento-6-tdd-red/SKILL.md; then
  pass tdd-red-guards-against-debug-probes
else
  fail tdd-red-guards-against-debug-probes "skills/memento-6-tdd-red/SKILL.md to refuse a red commit while [DEBUG- probes remain in the worktree"
fi

if [ -f skills/memento-3-auto-review/SKILL.md ] \
  && grep -qE 'exactly one.*## Diagnosis|## Diagnosis.*exactly one' skills/memento-3-auto-review/SKILL.md; then
  pass auto-review-dedupes-diagnosis-section
else
  fail auto-review-dedupes-diagnosis-section "skills/memento-3-auto-review/SKILL.md exactly-one invariant to cover '## Diagnosis'"
fi

if [ -f skills/memento-1-brainstorming/SKILL.md ] && grep -q 'reproduced observation' skills/memento-1-brainstorming/SKILL.md; then
  pass brainstorming-lists-reproduced-observation
else
  fail brainstorming-lists-reproduced-observation "skills/memento-1-brainstorming/SKILL.md claim-source taxonomy to list 'reproduced observation'"
fi

if [ -f skills/memento-2-planning/SKILL.md ] && grep -qE '^## Diagnosis' skills/memento-2-planning/SKILL.md; then
  pass planning-template-has-diagnosis-section
else
  fail planning-template-has-diagnosis-section "skills/memento-2-planning/SKILL.md plan template to have a '## Diagnosis' entry"
fi

if [ -f skills/memento-2-planning/SKILL.md ] && ! grep -qE '^Mechanism:' skills/memento-2-planning/SKILL.md; then
  pass planning-template-never-seeds-a-mechanism
else
  fail planning-template-never-seeds-a-mechanism "skills/memento-2-planning/SKILL.md template to offer no Mechanism: line — a cause is written only by step 5 after verification"
fi

if [ -f README.md ] && grep -qE '^\| *5 *\|.*memento-5-diagnosing' README.md; then
  pass readme-step-table-has-diagnosing-row
else
  fail readme-step-table-has-diagnosing-row "README.md step table to have a row for step 5 naming memento-5-diagnosing"
fi

if grep -q 'workbench' commands/use_memento.md .claude-plugin/plugin.json .claude-plugin/marketplace.json 2>/dev/null; then
  fail workbench-reference-removed "no 'workbench' string in commands/use_memento.md, .claude-plugin/plugin.json, or .claude-plugin/marketplace.json"
else
  pass workbench-reference-removed
fi

summary_skill=skills/memento-8c-work-summary/SKILL.md

if [ -f "$summary_skill" ] && grep -qE '^name: memento-8c-work-summary$' "$summary_skill"; then
  pass work-summary-skill-exists
else
  fail work-summary-skill-exists "$summary_skill to exist with frontmatter 'name: memento-8c-work-summary'"
fi

if [ -f "$summary_skill" ] \
  && grep -q 'full issue URL' "$summary_skill" \
  && grep -q 'full PR URL' "$summary_skill" \
  && grep -qF '<full issue URL> - <full PR URL> - <what it was done for' "$summary_skill" \
  && ! grep -q 'Please review when possible' "$summary_skill" \
  && grep -qF 'never `#1234`' "$summary_skill"; then
  pass work-summary-carries-output-contract
else
  fail work-summary-carries-output-contract "$summary_skill to spell out the one-line summary block — full issue URL, full PR URL, what it was for, and no review-request line — plus the full-URLs-never-#1234 rule behind it"
fi

if [ -f "$summary_skill" ] && grep -q 'unprompted' "$summary_skill" \
  && grep -q 'never close out by asking the user whether they want one' skills/memento-8-final-review/SKILL.md; then
  pass work-summary-is-emitted-unprompted
else
  fail work-summary-is-emitted-unprompted "the summary to be documented as emitted unprompted in $summary_skill and in skills/memento-8-final-review/SKILL.md"
fi

if [ -f "$summary_skill" ] && grep -q 'Once per PR' "$summary_skill" \
  && grep -q 'not re-emitted' skills/memento-8-final-review/SKILL.md; then
  pass work-summary-not-re-emitted-on-step-9-loopback
else
  fail work-summary-not-re-emitted-on-step-9-loopback "$summary_skill and skills/memento-8-final-review/SKILL.md to state the summary is emitted once per PR, not on each step-9 re-review round"
fi

if [ -f "$summary_skill" ] && grep -q 'not a blocker' "$summary_skill"; then
  pass work-summary-never-blocks-on-a-missing-issue
else
  fail work-summary-never-blocks-on-a-missing-issue "$summary_skill to treat a PR with no linked issue as non-blocking — an unattended session has nobody to answer"
fi

if [ -f "$summary_skill" ] \
  && grep -q 'statusCheckRollup' "$summary_skill" \
  && grep -q 'do not emit the block' "$summary_skill"; then
  pass work-summary-withholds-on-red-ci
else
  fail work-summary-withholds-on-red-ci "$summary_skill to check PR state before emitting and withhold the block on failing checks or a draft PR"
fi

if [ -f skills/memento-8-final-review/SKILL.md ]; then
  final_review_transition=$(sed -n '/^## Transition/,/^## /p' skills/memento-8-final-review/SKILL.md)
else
  final_review_transition=""
fi
if printf '%s' "$final_review_transition" | grep -q 'memento-8c-work-summary'; then
  pass final-review-transition-hands-off-to-work-summary
else
  fail final-review-transition-hands-off-to-work-summary "skills/memento-8-final-review/SKILL.md '## Transition' section to route a single-repo plan to memento-8c-work-summary"
fi

if [ -f skills/memento-8b-cross-pr-review/SKILL.md ]; then
  cross_pr_transition=$(sed -n '/^## Transition/,/^## /p' skills/memento-8b-cross-pr-review/SKILL.md)
  cross_pr_gate=$(sed -n '/^## Gate/,/^## /p' skills/memento-8b-cross-pr-review/SKILL.md)
else
  cross_pr_transition=""
  cross_pr_gate=""
fi
if printf '%s' "$cross_pr_transition" | grep -q 'memento-8c-work-summary'; then
  pass cross-pr-review-transition-hands-off-to-work-summary
else
  fail cross-pr-review-transition-hands-off-to-work-summary "skills/memento-8b-cross-pr-review/SKILL.md '## Transition' section to route on to memento-8c-work-summary"
fi

if printf '%s' "$cross_pr_gate" | grep -q 'memento-9-receiving-review'; then
  fail cross-pr-gate-does-not-bypass-work-summary "skills/memento-8b-cross-pr-review/SKILL.md '## Gate' to send a single-repo plan to memento-8c-work-summary, not past it to step 9"
else
  pass cross-pr-gate-does-not-bypass-work-summary
fi

if [ -f "$summary_skill" ]; then
  summary_transition=$(sed -n '/^## Transition/,/^## /p' "$summary_skill")
else
  summary_transition=""
fi
if printf '%s' "$summary_transition" | grep -q 'memento-9-receiving-review'; then
  pass work-summary-transition-hands-off-to-step-9
else
  fail work-summary-transition-hands-off-to-step-9 "$summary_skill '## Transition' section to hand on to memento-9-receiving-review"
fi

if [ -f skills/memento-0-using/SKILL.md ]; then
  using_small_route_section=$(sed -n '/^### Small route/,/^### /p' skills/memento-0-using/SKILL.md)
else
  using_small_route_section=""
fi
if printf '%s' "$using_route_section" | grep -q 'memento-8c-work-summary' \
  && printf '%s' "$using_small_route_section" | grep -q 'memento-8c-work-summary'; then
  pass using-both-routes-list-work-summary
else
  fail using-both-routes-list-work-summary "skills/memento-0-using/SKILL.md Small-route and Large-route step lists to both name memento-8c-work-summary"
fi

if [ -f README.md ] && grep -qE '^\| *8\.6 *\|.*memento-8c-work-summary' README.md; then
  pass readme-step-table-has-work-summary-row
else
  fail readme-step-table-has-work-summary-row "README.md step table to have a row for step 8.6 naming memento-8c-work-summary"
fi

if [ -f skills/memento-1-brainstorming/SKILL.md ] \
  && grep -qE '^description:.*ticket' skills/memento-1-brainstorming/SKILL.md \
  && grep -qE 'ticket, read its body and existing acceptance criteri[^.]*images embedded[^.]*before briefing the Premise Auditor' skills/memento-1-brainstorming/SKILL.md \
  && printf '%s' "$using_small_route_section" | grep -qE 'from the task, and read the ticket.s body and existing acceptance criteria when the task names one'; then
  pass brainstorming-reads-ticket
else
  fail brainstorming-reads-ticket "AC1: skills/memento-1-brainstorming/SKILL.md frontmatter description to mention 'ticket', and step 1 to read the ticket's body and existing acceptance criteria (images included) before briefing the Premise Auditor; skills/memento-0-using/SKILL.md Small-route Derive step to read them too"
fi

if [ -f skills/memento-2-planning/SKILL.md ] \
  && grep -qE '^## Acceptance criteria' skills/memento-2-planning/SKILL.md \
  && grep -qF '[ticket]' skills/memento-2-planning/SKILL.md \
  && grep -qF '[drafted]' skills/memento-2-planning/SKILL.md \
  && grep -qF '[re-scoped:' skills/memento-2-planning/SKILL.md \
  && grep -qiE '(write-ticket.*unhappy path|unhappy path.*write-ticket)' skills/memento-2-planning/SKILL.md \
  && grep -qE '^Posted: <YYYY-MM-DD> <ticket> body \(AC4, AC5\); <YYYY-MM-DD> <ticket> comment \(AC3 r2\)' skills/memento-2-planning/SKILL.md \
  && grep -qE 'marked `\[re-scoped: <why>, r<n>\]` \(`r1`, then \+1 on each re-scope of it\)' skills/memento-2-planning/SKILL.md \
  && grep -qF -e '- AC<n> [re-scoped: <why>, r<n>]' skills/memento-2-planning/SKILL.md \
  && ! grep -qF '<YYYY-MM-DD>]' skills/memento-2-planning/SKILL.md \
  && grep -qE 'any `smoke` verifier forces `needs_human_smoke: true`' skills/memento-2-planning/SKILL.md \
  && grep -qiE 'test belongs to the task' skills/memento-2-planning/SKILL.md \
  && grep -qE 'when several tasks touch a criterion, that is the task whose change makes it pass \(the later one in task order\)' skills/memento-2-planning/SKILL.md \
  && ! grep -q 'last in its chain' skills/memento-2-planning/SKILL.md \
  && grep -qE 'a task with neither is merged into a neighbour at planning\.' skills/memento-2-planning/SKILL.md \
  && grep -qiE 'seam test' skills/memento-2-planning/SKILL.md; then
  pass planning-lists-criteria
else
  fail planning-lists-criteria "AC2/AC3: skills/memento-2-planning/SKILL.md plan template to add a '## Acceptance criteria' heading with [ticket]/[drafted]/[re-scoped: <why>, r<n>] tags (r1, then +1 on each re-scope, no date) and a 'Posted: <date> <ticket> body (AC4, AC5); <date> <ticket> comment (AC3 r2)' line, drafting to reference the write-ticket skill's unhappy-path rule, any smoke verifier to force needs_human_smoke: true, and the ownership rule (a test belongs to the task whose change makes it pass, the later one in task order; a task with neither a criterion test nor a seam test is merged into a neighbour at planning)"
fi

if [ -f skills/memento-2-planning/SKILL.md ] \
  && grep -qE '^## Checks' skills/memento-2-planning/SKILL.md \
  && grep -qF -e '- <id> [repo: <label>] — `<command>` → expect <expectation>' skills/memento-2-planning/SKILL.md \
  && grep -qiE '(C1, C2.{0,20}unique per plan|unique per plan.{0,20}C1, C2)' skills/memento-2-planning/SKILL.md \
  && grep -qiE '(\[repo: <label>\].{0,40}multi-repo|multi-repo.{0,40}\[repo: <label>\])' skills/memento-2-planning/SKILL.md; then
  pass planning-checks-block
else
  fail planning-checks-block "AC1: skills/memento-2-planning/SKILL.md plan template to add a '## Checks' heading whose entries follow '- <id> [repo: <label>] -- <command> -> expect <expectation>' (id, optional repo tag, command, expected output), ids C1, C2, ... unique per plan, and the repo tag required only on multi-repo plans"
fi

if [ -f skills/memento-2-planning/SKILL.md ] \
  && grep -qF '→ check C1 (T2)' skills/memento-2-planning/SKILL.md \
  && grep -qF '→ observe C3 (T4)' skills/memento-2-planning/SKILL.md \
  && grep -qE '`<verifier>` is `test`.*`check <id>`.*`observe <id>`.*`smoke`' skills/memento-2-planning/SKILL.md; then
  pass planning-criterion-references-check-id
else
  fail planning-criterion-references-check-id "AC2: skills/memento-2-planning/SKILL.md to show a criterion line referencing a Checks entry by id (examples '-> check C1 (T2)' and '-> observe C3 (T4)') and the verifier rule to name all four kinds in order -- test, check <id>, observe <id>, smoke"
fi

if [ -f skills/memento-2-planning/SKILL.md ] \
  && grep -qiE '(exact string or regex match against the command.s output|command.s output.*exact string or regex match)' skills/memento-2-planning/SKILL.md \
  && grep -qiE '(never from a figure quoted in a ticket or plan|figure quoted in a ticket or plan.*never)' skills/memento-2-planning/SKILL.md; then
  pass planning-expectation-is-matched
else
  fail planning-expectation-is-matched "AC3: skills/memento-2-planning/SKILL.md to define a Checks expectation as an exact string or regex match against the command's output, sourced from actually running the command and never from a figure quoted in a ticket or plan"
fi

if [ -f skills/memento-2-planning/SKILL.md ] \
  && grep -qiE 'runs in the worktree before implementation' skills/memento-2-planning/SKILL.md \
  && grep -qiE 'determinist' skills/memento-2-planning/SKILL.md \
  && grep -qiE 'without credentials the agent lacks' skills/memento-2-planning/SKILL.md \
  && grep -qiE 'without side effects on shared infrastructure' skills/memento-2-planning/SKILL.md \
  && grep -qiE '(everything else is .observe.|otherwise.*.observe.)' skills/memento-2-planning/SKILL.md \
  && grep -qF 'Neither sets `needs_human_smoke`' skills/memento-2-planning/SKILL.md \
  && grep -qiE 'never waits on input' skills/memento-2-planning/SKILL.md; then
  pass planning-check-versus-observe
else
  fail planning-check-versus-observe "AC4: skills/memento-2-planning/SKILL.md to gate 'check' on the command running in the worktree before implementation, deterministically, without credentials the agent lacks and without side effects on shared infrastructure, with everything else defaulting to 'observe'"
fi

if [ -f skills/memento-3-auto-review/SKILL.md ] \
  && grep -qE 'Devil.s Advocate.*\. Flags `## Acceptance criteria` missing a real unhappy path' skills/memento-3-auto-review/SKILL.md; then
  pass auto-review-flags-missing-unhappy-path
else
  fail auto-review-flags-missing-unhappy-path "AC4: skills/memento-3-auto-review/SKILL.md Devil's Advocate role to flag an acceptance-criteria set missing a real unhappy path (co-occurring 'unhappy path' and 'acceptance criteria' wording)"
fi

if [ -f skills/memento-4-human-review/SKILL.md ] \
  && grep -qE 'The first post creates its `## Acceptance criteria \(added during planning\)` block' skills/memento-4-human-review/SKILL.md \
  && grep -qE 'later posts append only the new lines, leaving every existing line and its tick state byte-for-byte' skills/memento-4-human-review/SKILL.md \
  && grep -qE 'Never a second block' skills/memento-4-human-review/SKILL.md \
  && grep -qE 'Write the full body back with the tracker.s replace-style edit; nothing new' skills/memento-4-human-review/SKILL.md \
  && ! grep -q 'appends or replaces' skills/memento-4-human-review/SKILL.md \
  && grep -qE 'one comment listing the changes[^.]*\. Never edit the ticket.s existing criteria text' skills/memento-4-human-review/SKILL.md \
  && grep -qE 'Never post when `Source:` is `none`' skills/memento-4-human-review/SKILL.md \
  && grep -qE 'Never post when [^.]*or an epic' skills/memento-4-human-review/SKILL.md \
  && grep -qE 'each line posts to the ticket it names' skills/memento-4-human-review/SKILL.md \
  && grep -qE 'not yet posted while no `body` entry for its ticket lists its id' skills/memento-4-human-review/SKILL.md \
  && grep -qE 'a `\[re-scoped\]` line, while no `comment` entry lists its id with its current `r<n>`' skills/memento-4-human-review/SKILL.md \
  && grep -qE 'Each successful write appends its own entry to the plan.s `Posted:` line, naming the ticket and listing each id individually, never as a range; never rewrite an earlier one' skills/memento-4-human-review/SKILL.md \
  && grep -qE 'A write fails\*\*.{1,6}append no entry for it, put its block or comment text in the reply[^.]*continue the cycle' skills/memento-4-human-review/SKILL.md \
  && ! grep -q 'leave `Posted:` unchanged' skills/memento-4-human-review/SKILL.md \
  && grep -qE 'the prompt says which criteri[^.]*ticket' skills/memento-4-human-review/SKILL.md; then
  pass human-review-posts-criteria-on-approve
else
  fail human-review-posts-criteria-on-approve "AC5/AC6/AC14/AC15/AC16: skills/memento-4-human-review/SKILL.md to create the '## Acceptance criteria (added during planning)' block once and append only new drafted lines to it byte-for-byte (never a second block, full body written back, no write when nothing is new), post changes to existing criteria as a comment without ever editing their text, post nothing when Source: is none or an epic, post each line to the ticket it names, treat a [drafted] line as posted once a body entry for its ticket lists its id and a [re-scoped] line once a comment entry lists its id with its current r<n>, append one Posted: entry per successful write naming the ticket with ids listed individually, append none on a failed write and put its text in the reply, and have the verdict prompt say which criteria approval will post and to which ticket"
fi

if [ -f skills/memento-0-using/SKILL.md ] \
  && printf '%s' "$using_small_route_section" | grep -qF '## Acceptance criteria' \
  && printf '%s' "$using_small_route_section" | grep -qE 'Criteria are never posted to the ticket on this route; the drafted ones go in the reply' \
  && printf '%s' "$using_small_route_section" | grep -qE 'a criterion only a human smoke test can verify makes the task Large' \
  && grep -qE 'Verdict \(step 4\).*never post acceptance criteria' skills/memento-0-using/SKILL.md; then
  pass criteria-never-posted-without-approval
else
  fail criteria-never-posted-without-approval "AC7: skills/memento-0-using/SKILL.md Small route's minimal plan to gain a '## Acceptance criteria' section, the ticket draft to go in the reply instead of being posted, and the unattended contract to say acceptance criteria are never posted"
fi

if [ -f skills/memento-1-brainstorming/SKILL.md ] && [ -f skills/memento-2-planning/SKILL.md ] \
  && grep -qE 'A/B/C.*⭐' skills/memento-1-brainstorming/SKILL.md \
  && grep -qE 'A/B/C.*⭐' skills/memento-2-planning/SKILL.md \
  && ! grep -q 'replies with a number' skills/memento-1-brainstorming/SKILL.md \
  && ! grep -q 'plain numbered markdown' skills/memento-1-brainstorming/SKILL.md \
  && ! grep -q 'replies with a number' skills/memento-2-planning/SKILL.md \
  && ! grep -q 'plain numbered markdown' skills/memento-2-planning/SKILL.md; then
  pass options-lettered-with-star
else
  fail options-lettered-with-star "AC13: skills/memento-1-brainstorming/SKILL.md and skills/memento-2-planning/SKILL.md to letter options A/B/C with a trailing ⭐ marking the recommendation, and neither to still say 'replies with a number' or 'plain numbered markdown'"
fi

tdd_red_skill=skills/memento-6-tdd-red/SKILL.md
human_smoke_skill=skills/memento-7b-human-smoke/SKILL.md

if [ -f "$tdd_red_skill" ] \
  && grep -qiE '(criteri.*exactly one verifier|exactly one verifier.*criteri)' "$tdd_red_skill" \
  && grep -qiE '(fewest tests.*criteri|criteri.*fewest tests)' "$tdd_red_skill" \
  && grep -qiE '(criteri.*same setup and action|same setup and action.*criteri)' "$tdd_red_skill" \
  && grep -qiE '(grouped by.*owning task|owning task.*grouped)' "$tdd_red_skill" \
  && grep -qiE '(criteri.*seam test|seam test.*criteri)' "$tdd_red_skill" \
  && grep -qE 'A task with no criterion test, no `check`, and no seam test .{1,6}stop and loop back to `memento-2-planning` to merge it' "$tdd_red_skill" \
  && grep -qiE '(test ids.*criteri|criteri.*test ids)' "$tdd_red_skill" \
  && [ -f "$human_smoke_skill" ] \
  && grep -iE 'checklist' "$human_smoke_skill" | grep -iE 'criteri' | grep -qiE 'smoke' \
  && ! grep -rqiE '1 happy|2 tests per task|Exactly 2 tests|2-test budget' skills/; then
  pass tdd-red-one-verifier-per-criterion
else
  fail tdd-red-one-verifier-per-criterion "AC9/AC10/AC11: $tdd_red_skill to state every acceptance criterion has exactly one verifier, the fewest tests that cover all criteria, a test covers several criteria only when they share the same setup and action, tests grouped by owning task, a task with no criterion test gets its seam test (and one with neither loops back to memento-2-planning to be merged), and test ids written back into the plan's '## Acceptance criteria'; $human_smoke_skill to build its checklist from the criteria marked 'smoke' (checklist/criteria/smoke co-occurring on one line); and no skill file under skills/ to still state the fixed test budget ('1 happy', '2 tests per task', 'Exactly 2 tests', '2-test budget')"
fi

final_review_skill=skills/memento-8-final-review/SKILL.md
criteria_rule=$(grep -F '**`## Acceptance criteria`**' "$final_review_skill" 2>/dev/null)

if [ -f "$final_review_skill" ] \
  && grep -qi 'tests reviewer' "$final_review_skill" \
  && grep -qE '\*\*Tests\*\*.*[;,] flags a criterion in the plan.s `## Acceptance criteria` with no verifier' "$final_review_skill" \
  && grep -qE '\*\*Tests\*\*.*with no verifier, two tests verifying the same criterion' "$final_review_skill" \
  && grep -qE '\*\*Tests\*\*.*two tests verifying the same criterion, a `smoke` criterion when the plan has no `## Human smoke: pass`' "$final_review_skill" \
  && grep -qF '## Acceptance criteria' "$final_review_skill" \
  && grep -qiE 'source:? *none' "$final_review_skill" \
  && grep -qiE '(source.*epic|epic.*source)' "$final_review_skill" \
  && grep -qE '`Refs #N` when `Source:` is an epic, never `Closes #N`' "$final_review_skill" \
  && grep -qF -e '- [x]' "$final_review_skill" \
  && printf '%s\n' "$criteria_rule" | grep -qF 'goes in only when no ticket holds the criteria' \
  && printf '%s\n' "$criteria_rule" | grep -qiE '(name.*verifier|verifier.*name)' \
  && printf '%s\n' "$criteria_rule" | grep -qiE '(exempt.*cap|cap.*exempt)' \
  && grep -qiE '(no ticket.*issue|issue.*no ticket)' "$final_review_skill"; then
  pass final-review-checks-criteria
else
  fail final-review-checks-criteria "AC8/AC12: $final_review_skill's Tests reviewer to check the acceptance-criteria map (flag a criterion with no verifier, two tests verifying the same criterion, and a smoke criterion when the plan has no '## Human smoke: pass'), an epic Source: to be linked with 'Refs #N', never 'Closes #N', and the PR body to gain a '## Acceptance criteria' section only when Source: is none or an epic, with '- [x]' lines each naming their verifier, exempt from the 4-bullet cap, plus no new issue opened for a task with no ticket"
fi

if [ -f "$final_review_skill" ] \
  && grep -qE '\*\*Tests\*\*.*`## Human smoke: pass`, a criterion whose check id is missing from `## Checks`' "$final_review_skill" \
  && grep -qE '\*\*Tests\*\*.*check id is missing from `## Checks`, a duplicated `## Checks` id' "$final_review_skill" \
  && grep -qE '\*\*Tests\*\*.*a duplicated `## Checks` id, and a `## Checks` entry no criterion references' "$final_review_skill"; then
  pass final-review-flags-check-id-mismatch
else
  fail final-review-flags-check-id-mismatch "AC11: $final_review_skill's Tests reviewer bullet to also flag a criterion whose check id is missing from '## Checks', a duplicated '## Checks' id, and a '## Checks' entry no criterion references"
fi

if [ -f "$final_review_skill" ] \
  && grep -qiE '(observe.{1,120}not verified at merge|not verified at merge.{1,120}observe)' "$final_review_skill" \
  && grep -qiE '(observe.{1,150}(its )?command and (its )?expectation|(its )?command and (its )?expectation.{1,150}observe)' "$final_review_skill" \
  && grep -qiE '(observe.{1,200}(`## Acceptance criteria`|`## Verification`)|(`## Acceptance criteria`|`## Verification`).{1,200}observe)' "$final_review_skill" \
  && ! grep -qE '^ *## (Post-deploy|Observations)' "$final_review_skill"; then
  pass final-review-observe-in-pr-body
else
  fail final-review-observe-in-pr-body "AC10: $final_review_skill to write each 'observe' criterion into the PR body's existing criteria section ('## Acceptance criteria' or '## Verification'), marked not verified at merge, carrying its command and expectation, with no new section (e.g. a '## Post-deploy' / '## Observations' heading) introduced for it"
fi

verification_rule=$(grep -F '**`## Verification`**' "$final_review_skill" 2>/dev/null)

if [ -n "$verification_rule" ] \
  && grep -qE '^   ## Verification$' "$final_review_skill" \
  && grep -qF -e '- <criterion handle> — <verifier>' "$final_review_skill" \
  && grep -qF 'one criteria section picked by `Source:`' "$final_review_skill" \
  && printf '%s\n' "$verification_rule" | grep -qF 'replaces it when a ticket holds the criteria' \
  && printf '%s\n' "$verification_rule" | grep -qF '3–5 word handle and its verifier' \
  && printf '%s\n' "$verification_rule" | grep -qF 'criterion text stays in the ticket' \
  && printf '%s\n' "$verification_rule" | grep -qF 'read the current body of each ticket in `Source:`' \
  && printf '%s\n' "$verification_rule" | grep -qF "gets a handle only when its own ticket's body has a checkbox or list item with the same wording, ignoring tick state, whitespace and markdown formatting" \
  && printf '%s\n' "$verification_rule" | grep -qF 'any other criterion is written in full, whatever `Posted:` says' \
  && printf '%s\n' "$verification_rule" | grep -qF 'A `[re-scoped]` line is always written in full' \
  && printf '%s\n' "$verification_rule" | grep -qF "A criterion moved to another ticket isn't listed" \
  && printf '%s\n' "$verification_rule" | grep -qF "Every line for a ticket body you can't read is written in full; name that ticket in your reply" \
  && ! grep -qi 'not yet posted' "$final_review_skill" \
  && printf '%s\n' "$verification_rule" | grep -qF 'each line names its ticket' \
  && printf '%s\n' "$verification_rule" | grep -qiE 'exempt.*cap' \
  && ! grep -qF 'With a ticket, `Closes #N` carries them' "$final_review_skill"; then
  pass final-review-verification-with-ticket
else
  fail final-review-verification-with-ticket "AC1-AC4: $final_review_skill's PR body to carry a '## Verification' template section that replaces '## Acceptance criteria' when a ticket holds the criteria (one criteria section picked by Source:; '- <criterion handle> — <verifier>' lines, a 3–5 word handle and its verifier, criterion text stays in the ticket), reading the current body of each ticket in Source: and giving a handle only when the criterion's own ticket has a checkbox or list item with the same wording; everything else in full whatever Posted: says, every [re-scoped] line in full, moved criteria left out, and every line in full for a ticket body that can't be read (named in the reply); no 'not yet posted' wording left, naming its ticket on each line when there are several, exempt from the 4-bullet cap; and the old 'With a ticket, Closes #N carries them' wording gone"
fi

implementing_skill=skills/memento-7-implementing/SKILL.md
receiving_review_skill=skills/memento-9-receiving-review/SKILL.md

human_review_skill=skills/memento-4-human-review/SKILL.md
rescope_pointer='\*\*Re-scope after approval\*\* in `memento-4-human-review`'

if [ -f "$human_review_skill" ] && [ -f "$human_smoke_skill" ] && [ -f "$implementing_skill" ] && [ -f "$receiving_review_skill" ] && [ -f "$skill" ] && [ -f "$tdd_red_skill" ] \
  && grep -qE '^## Re-scope after approval$' "$human_review_skill" \
  && grep -qE 'Every session past this step is attended, so a criterion found wrong at step 5, 6, 7, 7b or 9, or one a later step needs to add, stops the cycle\.' "$human_review_skill" \
  && grep -qE 'Show the change, what it would post, and to which ticket; the user.s go-ahead is the approval for that post\.' "$human_review_skill" \
  && grep -qE 'mark it in the plan \(`\[re-scoped: <why>, r<n>\]`, or a new `\[drafted\]` line\) and post it per the section above' "$human_review_skill" \
  && grep -qE 'run `memento-6-tdd-red` and `memento-7-implementing` for that task only\. Then resume at the step that found it\. Never re-enter step 5 or auto-review for it\.' "$human_review_skill" \
  && grep -qE "wrong or missing criterion follows $rescope_pointer" skills/memento-2-planning/SKILL.md \
  && ! grep -q 'loops back here to re-scope' skills/memento-2-planning/SKILL.md \
  && grep -qE "still written as \`Mechanism:\`, not \`Refuted:\`, and doesn.t count toward the second-refutation stop; re-scope that criterion first per $rescope_pointer" "$skill" \
  && ! grep -q 'takes the same route' "$skill" \
  && grep -qE "If tests are wrong, loop back to step 6; a wrong criterion follows $rescope_pointer" "$implementing_skill" \
  && grep -qE "tests missed the case.{1,6}add or re-scope the criterion it breaks per $rescope_pointer" "$human_smoke_skill" \
  && grep -qE 'impl is wrong but tests are fine.{1,6}loop back to `memento-7-implementing`' "$human_smoke_skill" \
  && grep -qE 'plan itself was wrong.{1,6}loop back to `memento-2-planning`' "$human_smoke_skill" \
  && ! grep -q 'memento-3-auto-review' "$human_smoke_skill" \
  && grep -qE "changes what a criterion means is re-scoped per $rescope_pointer before the reply batch is posted" "$receiving_review_skill" \
  && grep -qE "step 6 if tests are wrong\); a wrong criterion follows $rescope_pointer" "$receiving_review_skill" \
  && grep -qE 'run this for the owning task only; a test already green on arrival is committed as `test: <task-slug> \(already green\)` instead of looping' "$tdd_red_skill" \
  && grep -qE 'a dropped criterion.s test is deleted in the same commit' "$tdd_red_skill" \
  && grep -qE 'record `Red HEAD: <sha>` per repo in the plan \(a re-run re-records it\)' "$tdd_red_skill" \
  && grep -qE 'A task whose latest test commit is `\(already green\)` is skipped' "$implementing_skill" \
  && grep -qF 'git diff --quiet <Red HEAD> HEAD -- <task test paths>' "$implementing_skill" \
  && grep -qF 'git diff --quiet <Red HEAD> HEAD -- <test paths>' "$implementing_skill" \
  && ! grep -qE 'git diff --quiet <(last-)?red-SHA>' "$implementing_skill" \
  && ! grep -rqi 'last red SHA' skills/; then
  pass rescope-after-approval
else
  fail rescope-after-approval "AC17: $human_review_skill to own a '## Re-scope after approval' rule (sessions past step 4 are attended; a criterion found wrong or needed at step 5, 6, 7, 7b or 9 stops the cycle and shows the change, what it would post and to which ticket; the go-ahead is the approval for that post; mark it [re-scoped: <why>, r<n>] or [drafted], post it, run memento-6-tdd-red and memento-7-implementing for the owning task only, resume at the step that found it, never re-enter step 5 or auto-review), with steps 2, 5, 7, 7b and 9 pointing to it instead of routing through memento-2/3/4 (5 writes Mechanism:, not Refuted:, outside the second-refutation stop; 7b keeps its impl-wrong and plan-wrong routes); $tdd_red_skill to commit an already-green test as '(already green)', delete a dropped criterion's test in the same commit, and record Red HEAD per repo; $implementing_skill to skip an '(already green)' task and freeze tests against <Red HEAD>; no skill to still say 'last red SHA'"
fi

if [ -f "$tdd_red_skill" ] \
  && grep -qiE "run(s)? each \`check\`.{1,140}before implementation.{1,240}record(s)? (its|the) failing output" "$tdd_red_skill" \
  && grep -qiE 'already green before implementation is a false red' "$tdd_red_skill" \
  && grep -qiE "\`observe\` entries (do not|don.t) run here" "$tdd_red_skill"; then
  pass tdd-red-runs-checks-red
else
  fail tdd-red-runs-checks-red "AC5: $tdd_red_skill Protocol to run each 'check' before implementation and record its failing output in one instruction, to call an already-green check a false red, and to keep 'observe' entries out of this step"
fi

if [ -f "$tdd_red_skill" ] \
  && grep -qiE "stop.{1,80}check id.{1,20}missing from \`## Checks\`" "$tdd_red_skill" \
  && grep -qiE 'stop.{1,80}(two entries share an id|share an id)' "$tdd_red_skill"; then
  pass tdd-red-stops-on-bad-check-id
else
  fail tdd-red-stops-on-bad-check-id "AC6: $tdd_red_skill step 6 to stop when a criterion's check id is missing from '## Checks', and to stop when two '## Checks' entries share an id"
fi

if [ -f "$tdd_red_skill" ] \
  && grep -qiE "reclassif(y|ying|ies|ied) a \`check\` (as|to) \`observe\`.{1,150}$rescope_pointer" "$tdd_red_skill"; then
  pass rescope-covers-check-reclassification
else
  fail rescope-covers-check-reclassification "AC7: $tdd_red_skill to say reclassifying a 'check' as 'observe' stops the cycle by following Re-scope after approval in memento-4-human-review"
fi

if [ -f "$implementing_skill" ] \
  && grep -qiE "check command.{1,40}frozen" "$implementing_skill" \
  && grep -qiE 'byte-identical to the one step 6 recorded red' "$implementing_skill" \
  && grep -qiE 'no .git diff. covers them' "$implementing_skill" \
  && grep -qiE 'verifier.{1,80}confirms? each check.{1,20}green' "$implementing_skill"; then
  pass implementing-freezes-check-commands
else
  fail implementing-freezes-check-commands "AC8: $implementing_skill to freeze '## Checks' commands against what step 6 recorded red, saying plainly that no git diff covers a command living in the plan file, and its separate green-verifier to confirm each check now green"
fi

if [ -f "$implementing_skill" ] \
  && grep -qiE '(memento-8c-work-summary.{1,80}verdict|verdict.{1,80}memento-8c-work-summary)' "$implementing_skill" \
  && grep -qiE 'local green is what this step confirms' "$implementing_skill" \
  && ! grep -qF 'push the feature branch so CI runs' "$implementing_skill" \
  && ! grep -qiE 'at the recorded SHA' "$implementing_skill" \
  && ! grep -qiE 'authoritative' "$implementing_skill"; then
  pass implementing-defers-ci-to-8c
else
  fail implementing-defers-ci-to-8c "AC9: $implementing_skill to point at step 8c (memento-8c-work-summary) for the CI verdict, and to drop the claim that pushing the feature branch makes CI run at the recorded SHA"
fi

if [ -f "$summary_skill" ] \
  && grep -qF 'up to 10 minutes' "$summary_skill" \
  && grep -qF 'pending checks' "$summary_skill" \
  && grep -qF 'absent run' "$summary_skill" \
  && grep -qF 'unverified rather than green' "$summary_skill" \
  && grep -qF 'still pending' "$summary_skill" \
  && grep -qF 're-invoke `memento-8c-work-summary`' "$summary_skill" \
  && grep -qF 'go back to `memento-7-implementing`' "$summary_skill" \
  && grep -qF 'Once per PR' "$summary_skill"; then
  pass work-summary-waits-for-ci
else
  fail work-summary-waits-for-ci "AC12: $summary_skill to wait up to 10 minutes for pending checks, treat an absent run as unverified rather than green, on timeout report checks as still pending and hand back a re-invocation of itself rather than a bare command, route red checks to memento-7-implementing, and say the once-per-PR rule spares a run that emitted nothing"
fi

if [ -f "$summary_skill" ] \
  && grep -qF '`gh`' "$summary_skill" \
  && grep -qF '`az`' "$summary_skill" \
  && grep -qF 'this repo has no CI' "$summary_skill" \
  && grep -qF 'record which source was read' "$summary_skill" \
  && ! grep -qiE 'km-searcher|XPenses' "$summary_skill"; then
  pass work-summary-names-ci-source
else
  fail work-summary-names-ci-source "AC13: $summary_skill to name its CI source per repo as 'gh', 'az', or 'this repo has no CI', to record which source was read, and to name no private repo by name"
fi

if [ -f "$summary_skill" ] \
  && grep -qiE 'every verdict except pending and red is resolved' "$summary_skill" \
  && grep -qF 'status: in-review' "$summary_skill" \
  && [ -f "$final_review_skill" ] \
  && grep -qF 'moves to `status: in-review` at step 8.6, after the CI verdict, not here' "$final_review_skill" \
  && printf '%s' "$using_small_route_section" | grep -qF 'moves the plan to `status: in-review` once CI has a verdict' \
  && grep -qE '\| *8\.6 *\|.*status: in-review' README.md; then
  pass status-in-review-after-ci-verdict
else
  fail status-in-review-after-ci-verdict "AC14: $summary_skill to resolve every verdict except pending and red and set status: in-review there, $final_review_skill and the Small route in skills/memento-0-using/SKILL.md to point at step 8.6 instead of setting it at PR-open, and README's 8.6 row to say so"
fi

if [ -f skills/memento-0-using/SKILL.md ] \
  && printf '%s' "$using_small_route_section" | grep -qiE '(check.{1,40}observe|observe.{1,40}check).{1,80}(keeps?|stays?).{1,15}(the task )?Small' \
  && printf '%s' "$using_small_route_section" | grep -qiE 'neither.{1,60}sets?.{1,20}needs_human_smoke: true' \
  && printf '%s' "$using_small_route_section" | grep -qiE 'check.{1,80}records? (its |the )?red.{1,20}(and|then) green.{1,20}output.{1,30}(in|to) the plan'; then
  pass small-route-check-and-observe
else
  fail small-route-check-and-observe "AC15: skills/memento-0-using/SKILL.md Small route to state that check and observe criteria keep the task Small and that neither sets needs_human_smoke: true (only a smoke-only criterion still forces Large), and that a Small-route check records its red and green output in the plan"
fi

if [ "$fail_count" -eq 0 ]; then
  exit 0
else
  exit 1
fi
