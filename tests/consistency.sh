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
  pass step-references-resolve-to-real-directories
else
  fail step-references-resolve-to-real-directories "every memento-N-* name referenced in a SKILL.md to have a matching skills/ directory, missing:$missing"
fi

versions=$(grep -ho '"version": "[^"]*"' .claude-plugin/plugin.json .claude-plugin/marketplace.json | sort -u | wc -l)
if [ "$versions" -eq 1 ]; then
  pass manifest-versions-agree
else
  fail manifest-versions-agree "every \"version\" field across both .claude-plugin manifests to carry the same value, found $versions distinct"
fi

undeclared=""
for d in skills/*/; do
  name=$(basename "$d")
  [ -f "$d/SKILL.md" ] || undeclared="$undeclared $name(no SKILL.md)"
done
if [ -z "$undeclared" ]; then
  pass every-skill-dir-has-a-skill-file
else
  fail every-skill-dir-has-a-skill-file "every skills/* directory to contain a SKILL.md, missing:$undeclared"
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
