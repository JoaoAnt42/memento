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

if [ "$fail_count" -eq 0 ]; then
  exit 0
else
  exit 1
fi
