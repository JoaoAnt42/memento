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

if [ "$fail_count" -eq 0 ]; then
  exit 0
else
  exit 1
fi
