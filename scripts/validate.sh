#!/usr/bin/env bash
# Checks the plugin before a release. Exit code 0 means that all checks passed.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
HEADER="<!-- Generated from shared/ - edit the file in shared/, then run scripts/sync-shared.sh -->"
# Limit from the skill authoring rules of Anthropic.
MAX_DESCRIPTION_CHARS=1024
failures=0

fail() { echo "FAIL  $1"; failures=$((failures + 1)); }
pass() { echo "ok    $1"; }

for json_file in .claude-plugin/plugin.json .claude-plugin/marketplace.json hooks/hooks.json; do
  if node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' "$json_file" 2>/dev/null; then
    pass "$json_file is valid JSON"
  else
    fail "$json_file is not valid JSON"
  fi
done

for hook_script in hooks/*.mjs; do
  if node --check "$hook_script" 2>/dev/null; then pass "$hook_script has no syntax error"; else fail "$hook_script has a syntax error"; fi
done

shopt -s nullglob
for skill_dir in skills/*/; do
  skill_name="$(basename "$skill_dir")"
  skill_file="${skill_dir}SKILL.md"
  if [ ! -f "$skill_file" ]; then fail "$skill_name has no SKILL.md"; continue; fi

  if [ "$(head -n 1 "$skill_file")" != "---" ]; then fail "$skill_name: frontmatter must start on line 1"; fi
  frontmatter_name="$(sed -n 's/^name: *//p' "$skill_file" | head -n 1)"
  if [ "$frontmatter_name" = "$skill_name" ]; then pass "$skill_name: name matches the folder"; else fail "$skill_name: name '$frontmatter_name' does not match the folder"; fi

  description_chars="$(sed -n 's/^description: *//p' "$skill_file" | head -n 1 | wc -c)"
  if [ "$description_chars" -gt 1 ] && [ "$description_chars" -le "$MAX_DESCRIPTION_CHARS" ]; then
    pass "$skill_name: description has $description_chars characters"
  else
    fail "$skill_name: description has $description_chars characters (must be 1 to $MAX_DESCRIPTION_CHARS)"
  fi

  if grep -rn '\.\./' "$skill_dir" >/dev/null; then fail "$skill_name: a file uses a ../ path"; else pass "$skill_name: no ../ paths"; fi

  while IFS= read -r reference; do
    if [ ! -f "${skill_dir}${reference}" ]; then fail "$skill_name: SKILL.md links to a missing file: $reference"; fi
  done < <(grep -o '(references/[^)]*)' "$skill_file" | tr -d '()' | sort -u)

  for shared_file in shared/*.md; do
    copy="${skill_dir}references/$(basename "$shared_file")"
    if [ -f "$copy" ] && diff -q <(printf '%s\n\n' "$HEADER"; cat "$shared_file") "$copy" >/dev/null; then
      :
    else
      fail "$skill_name: $(basename "$shared_file") is not in sync. Run scripts/sync-shared.sh"
    fi
  done
done
pass "shared files checked against each skill"

if command -v claude >/dev/null 2>&1; then
  if claude plugin validate . >/dev/null 2>&1; then pass "claude plugin validate"; else fail "claude plugin validate (run it to see the messages)"; fi
else
  echo "skip  claude plugin validate (the claude command is not on PATH)"
fi

if [ "$failures" -gt 0 ]; then
  echo "$failures check(s) failed."
  exit 1
fi
echo "All checks passed."
