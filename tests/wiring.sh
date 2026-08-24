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

if [ -f skills/memento-5-diagnosing/SKILL.md ]; then
  pass diagnosing-skill-file-exists
else
  fail diagnosing-skill-file-exists "skills/memento-5-diagnosing/SKILL.md to exist"
fi

if [ -f skills/memento-5-diagnosing/SKILL.md ] \
  && grep -qE '^name: memento-5-diagnosing$' skills/memento-5-diagnosing/SKILL.md; then
  pass diagnosing-skill-frontmatter-name
else
  fail diagnosing-skill-frontmatter-name "skills/memento-5-diagnosing/SKILL.md frontmatter to contain 'name: memento-5-diagnosing'"
fi

if [ -f skills/memento-5-diagnosing/SKILL.md ] \
  && grep -qE '^## Diagnosis' skills/memento-5-diagnosing/SKILL.md \
  && grep -q 'Mechanism' skills/memento-5-diagnosing/SKILL.md \
  && grep -q 'Verification' skills/memento-5-diagnosing/SKILL.md; then
  pass diagnosing-skill-output-contract
else
  fail diagnosing-skill-output-contract "skills/memento-5-diagnosing/SKILL.md to have a '## Diagnosis' section mentioning Mechanism and Verification"
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

if [ -f skills/memento-4-human-review/SKILL.md ] \
  && grep -q 'memento-5-diagnosing' skills/memento-4-human-review/SKILL.md \
  && grep -q 'status: diagnosing' skills/memento-4-human-review/SKILL.md; then
  pass human-review-routes-to-diagnosing
else
  fail human-review-routes-to-diagnosing "skills/memento-4-human-review/SKILL.md to reference memento-5-diagnosing and set status: diagnosing"
fi

if [ -f skills/memento-6-tdd-red/SKILL.md ] && grep -qE '## Diagnosis' skills/memento-6-tdd-red/SKILL.md; then
  pass tdd-red-consumes-diagnosis-section
else
  fail tdd-red-consumes-diagnosis-section "skills/memento-6-tdd-red/SKILL.md to reference the '## Diagnosis' section it consumes"
fi

if [ -f skills/memento-1-brainstorming/SKILL.md ] && grep -q 'reproduced observation' skills/memento-1-brainstorming/SKILL.md; then
  pass brainstorming-lists-reproduced-observation
else
  fail brainstorming-lists-reproduced-observation "skills/memento-1-brainstorming/SKILL.md claim-source taxonomy to list 'reproduced observation'"
fi

if [ -f skills/memento-2-planning/SKILL.md ] && grep -qE '## Diagnosis' skills/memento-2-planning/SKILL.md; then
  pass planning-template-has-diagnosis-section
else
  fail planning-template-has-diagnosis-section "skills/memento-2-planning/SKILL.md plan template to have a '## Diagnosis' entry"
fi

if [ -f README.md ] && grep -qE '^\| *5 *\|.*memento-5-diagnosing' README.md; then
  pass readme-step-table-has-diagnosing-row
else
  fail readme-step-table-has-diagnosing-row "README.md step table to have a row for step 5 naming memento-5-diagnosing"
fi

if [ -f .claude-plugin/plugin.json ] && [ -f .claude-plugin/marketplace.json ] \
  && grep -q '"version": "0.1.17"' .claude-plugin/plugin.json \
  && grep -q '"version": "0.1.17"' .claude-plugin/marketplace.json; then
  pass plugin-manifests-at-0-1-17
else
  fail plugin-manifests-at-0-1-17 ".claude-plugin/plugin.json and .claude-plugin/marketplace.json to both be at version 0.1.17"
fi

if grep -q 'workbench' commands/use_memento.md .claude-plugin/plugin.json .claude-plugin/marketplace.json 2>/dev/null; then
  fail workbench-reference-removed "no 'workbench' string in commands/use_memento.md, .claude-plugin/plugin.json, or .claude-plugin/marketplace.json"
else
  pass workbench-reference-removed
fi

missing=""
for f in skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  for tok in $(grep -oE 'memento-[0-9]+b?-[a-z]+(-[a-z]+)*' "$f" | sort -u); do
    if [ ! -d "skills/$tok" ]; then
      missing="$missing $tok(from $f)"
    fi
  done
done
if [ -z "$missing" ]; then
  pass memento-step-references-resolve-to-real-directories
else
  fail memento-step-references-resolve-to-real-directories "every memento-N-* name referenced in a SKILL.md to have a matching skills/ directory, missing:$missing"
fi

if claude plugin validate . --strict >/dev/null 2>&1; then
  pass plugin-validate-strict-passes
else
  fail plugin-validate-strict-passes "'claude plugin validate . --strict' to exit 0"
fi

if [ "$fail_count" -eq 0 ]; then
  exit 0
else
  exit 1
fi
