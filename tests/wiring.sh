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
  && grep -qE '^Posted: <YYYY-MM-DD> body \(AC…\), comment \(AC…\).*never rewrites' skills/memento-2-planning/SKILL.md \
  && grep -qE 'marked `\[re-scoped: <why>, <YYYY-MM-DD>\]`, re-dated on each re-scope' skills/memento-2-planning/SKILL.md \
  && grep -qE 'any `smoke` verifier forces `needs_human_smoke: true`' skills/memento-2-planning/SKILL.md \
  && grep -qiE 'test belongs to the task' skills/memento-2-planning/SKILL.md \
  && grep -qE 'when several tasks touch a criterion, that is the task whose change makes it pass \(the later one in task order\)' skills/memento-2-planning/SKILL.md \
  && ! grep -q 'last in its chain' skills/memento-2-planning/SKILL.md \
  && grep -qE 'a task with neither is merged into a neighbour whenever step 2 runs, a re-scope included' skills/memento-2-planning/SKILL.md \
  && grep -qiE 'seam test' skills/memento-2-planning/SKILL.md; then
  pass planning-lists-criteria
else
  fail planning-lists-criteria "AC2/AC3: skills/memento-2-planning/SKILL.md plan template to add a '## Acceptance criteria' heading with [ticket]/[drafted]/[re-scoped: <why>, <date>] tags (re-dated on each re-scope) and an append-only 'Posted: <date> body (AC…), comment (AC…)' line, drafting to reference the write-ticket skill's unhappy-path rule, any smoke verifier to force needs_human_smoke: true, and the ownership rule (a test belongs to the task whose change makes it pass, the later one in task order; a task with neither a criterion test nor a seam test is merged into a neighbour whenever step 2 runs)"
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
  && grep -qE 'not yet posted while `Posted:` doesn.t list its id' skills/memento-4-human-review/SKILL.md \
  && grep -qE 'a `\[re-scoped\]` line, while no `comment` entry for its id is dated on or after its re-scope date' skills/memento-4-human-review/SKILL.md \
  && grep -qE 'Append one entry per post to the plan.s `Posted:` line; never rewrite an earlier one' skills/memento-4-human-review/SKILL.md \
  && grep -qE 'A post fails\*\*.{1,6}leave `Posted:` unchanged[^.]*reply[^.]*continue to the worktrees' skills/memento-4-human-review/SKILL.md \
  && grep -qE 'the prompt says which criteri[^.]*ticket' skills/memento-4-human-review/SKILL.md; then
  pass human-review-posts-criteria-on-approve
else
  fail human-review-posts-criteria-on-approve "AC5/AC6/AC14/AC15/AC16: skills/memento-4-human-review/SKILL.md to create the '## Acceptance criteria (added during planning)' block once and append only new drafted lines to it byte-for-byte (never a second block, full body written back, no write when nothing is new), post changes to existing criteria as a comment without ever editing their text, post nothing when Source: is none or an epic, post each line to the ticket it names, skip lines Posted: already lists and append one Posted: entry per post, keep Posted: unchanged on a failed post with the text in the reply, and have the verdict prompt say which criteria approval will post and to which ticket"
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
  && grep -qE 'A task with neither .{1,6}stop and loop back to `memento-2-planning` to merge it' "$tdd_red_skill" \
  && grep -qiE '(test ids.*criteri|criteri.*test ids)' "$tdd_red_skill" \
  && [ -f "$human_smoke_skill" ] \
  && grep -iE 'checklist' "$human_smoke_skill" | grep -iE 'criteri' | grep -qiE 'smoke' \
  && ! grep -rqiE '1 happy|2 tests per task|Exactly 2 tests|2-test budget' skills/; then
  pass tdd-red-one-verifier-per-criterion
else
  fail tdd-red-one-verifier-per-criterion "AC9/AC10/AC11: $tdd_red_skill to state every acceptance criterion has exactly one verifier, the fewest tests that cover all criteria, a test covers several criteria only when they share the same setup and action, tests grouped by owning task, a task with no criterion test gets its seam test (and one with neither loops back to memento-2-planning to be merged), and test ids written back into the plan's '## Acceptance criteria'; $human_smoke_skill to build its checklist from the criteria marked 'smoke' (checklist/criteria/smoke co-occurring on one line); and no skill file under skills/ to still state the fixed test budget ('1 happy', '2 tests per task', 'Exactly 2 tests', '2-test budget')"
fi

final_review_skill=skills/memento-8-final-review/SKILL.md

if [ -f "$final_review_skill" ] \
  && grep -qi 'tests reviewer' "$final_review_skill" \
  && grep -qE '\*\*Tests\*\*.*[;,] flags a criterion in the plan.s `## Acceptance criteria` with no verifier' "$final_review_skill" \
  && grep -qE '\*\*Tests\*\*.*with no verifier, two tests verifying the same criterion' "$final_review_skill" \
  && grep -qE '\*\*Tests\*\*.*two tests verifying the same criterion, and a `smoke` criterion when the plan has no `## Human smoke: pass`' "$final_review_skill" \
  && grep -qF '## Acceptance criteria' "$final_review_skill" \
  && grep -qiE 'source:? *none' "$final_review_skill" \
  && grep -qiE '(source.*epic|epic.*source)' "$final_review_skill" \
  && grep -qE '`Refs #N` when `Source:` is an epic, never `Closes #N`' "$final_review_skill" \
  && grep -qF -e '- [x]' "$final_review_skill" \
  && grep -qiE '(name.*verifier|verifier.*name)' "$final_review_skill" \
  && grep -qiE '(exempt.*cap|cap.*exempt)' "$final_review_skill" \
  && grep -qiE '(no ticket.*issue|issue.*no ticket)' "$final_review_skill"; then
  pass final-review-checks-criteria
else
  fail final-review-checks-criteria "AC8/AC12: $final_review_skill's Tests reviewer to check the acceptance-criteria map (flag a criterion with no verifier, two tests verifying the same criterion, and a smoke criterion when the plan has no '## Human smoke: pass'), an epic Source: to be linked with 'Refs #N', never 'Closes #N', and the PR body to gain a '## Acceptance criteria' section only when Source: is none or an epic, with '- [x]' lines each naming their verifier, exempt from the 4-bullet cap, plus no new issue opened for a task with no ticket"
fi

implementing_skill=skills/memento-7-implementing/SKILL.md
receiving_review_skill=skills/memento-9-receiving-review/SKILL.md

if [ -f "$human_smoke_skill" ] && [ -f "$implementing_skill" ] && [ -f "$receiving_review_skill" ] && [ -f "$skill" ] && [ -f "$tdd_red_skill" ] \
  && grep -qE 'loops back here to re-scope[^.]*goes through step 4' skills/memento-2-planning/SKILL.md \
  && grep -qE 'tests missed the case.*`memento-2-planning`.*`memento-3-auto-review`.*`memento-4-human-review`.*`memento-6-tdd-red`' "$human_smoke_skill" \
  && grep -qE 'if the criterion is wrong, not the test, loop back to `memento-2-planning`' "$implementing_skill" \
  && grep -qE '`memento-2-planning` if the criterion is wrong' "$receiving_review_skill" \
  && grep -qE 'changes what a criterion means is re-scoped via `memento-2-planning`, which goes back through step 4, before the reply batch is posted' "$receiving_review_skill" \
  && grep -qE 'invoke `memento-2-planning`\. A confirmed cause that contradicts the criterion[^.]*takes the same route' "$skill" \
  && grep -qE 'approves a re-scope on a plan whose tasks already have green SHAs, run this step only for tasks owning a changed criterion' "$tdd_red_skill" \
  && grep -qE 'byte-identical to the repo.s last red SHA, not the task.s own' "$implementing_skill" \
  && grep -qF 'git diff --quiet <last-red-SHA> HEAD' "$implementing_skill" \
  && ! grep -qF 'git diff --quiet <red-SHA>' "$implementing_skill"; then
  pass rescope-routes-through-planning
else
  fail rescope-routes-through-planning "AC17: a criterion found wrong at step 5, 7, 7b or 9 to loop back to memento-2-planning, which goes through step 4 (7b through memento-3-auto-review and memento-4-human-review before memento-6-tdd-red; 9 before the reply batch is posted), $tdd_red_skill to re-run only tasks owning a changed criterion after green, and $implementing_skill to freeze tests against the repo's last red SHA, not the task's own"
fi

if [ "$fail_count" -eq 0 ]; then
  exit 0
else
  exit 1
fi
