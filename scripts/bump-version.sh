#!/usr/bin/env bash
# Releases a new version: syncs, validates, updates the version and adds a changelog entry.
# It does not run git. It prints the git commands for you.
#
# Usage: scripts/bump-version.sh <patch|minor|major|X.Y.Z> ["change note"]...
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
MANIFEST=".claude-plugin/plugin.json"
CHANGELOG="CHANGELOG.md"

if [ $# -lt 1 ]; then
  echo "Usage: scripts/bump-version.sh <patch|minor|major|X.Y.Z> [\"change note\"]..." >&2
  exit 1
fi
bump="$1"
shift

current="$(node -p 'require("./.claude-plugin/plugin.json").version')"
next="$(node -e '
  const [current, bump] = process.argv.slice(1);
  const semver = /^(\d+)\.(\d+)\.(\d+)$/;
  if (semver.test(bump)) { console.log(bump); process.exit(0); }
  const match = semver.exec(current);
  if (!match) { console.error("Current version is not X.Y.Z: " + current); process.exit(1); }
  const [major, minor, patch] = match.slice(1).map(Number);
  const next = { major: [major + 1, 0, 0], minor: [major, minor + 1, 0], patch: [major, minor, patch + 1] }[bump];
  if (!next) { console.error("Unknown bump: " + bump + ". Use patch, minor, major or X.Y.Z."); process.exit(1); }
  console.log(next.join("."));
' "$current" "$bump")"

if [ "$next" = "$current" ]; then
  echo "Error: the new version is the same as the current version ($current)." >&2
  exit 1
fi

./scripts/sync-shared.sh >/dev/null
echo "Synced shared files."
./scripts/validate.sh

node -e '
  const fs = require("fs");
  const [file, version] = process.argv.slice(1);
  const manifest = JSON.parse(fs.readFileSync(file, "utf8"));
  manifest.version = version;
  fs.writeFileSync(file, JSON.stringify(manifest, null, 2) + "\n");
' "$MANIFEST" "$next"

notes=""
if [ $# -eq 0 ]; then
  notes="- TODO: describe the change"$'\n'
else
  for note in "$@"; do notes+="- ${note}"$'\n'; done
fi
entry="## ${next} - $(date +%Y-%m-%d)"$'\n\n'"${notes}"
if [ -f "$CHANGELOG" ]; then
  rest="$(tail -n +2 "$CHANGELOG")"
  printf '# Changelog\n\n%s%s\n' "$entry" "$rest" > "$CHANGELOG"
else
  printf '# Changelog\n\n%s' "$entry" > "$CHANGELOG"
fi

echo
echo "Version: $current -> $next"
echo "Updated: $MANIFEST, $CHANGELOG"
if [ $# -eq 0 ]; then echo "Edit $CHANGELOG and replace the TODO line."; fi
echo
echo "Next steps:"
echo "  1. Read the diff:  git diff"
echo "  2. Commit:         git add -A && git commit -m \"chore(release): v$next\""
echo "  3. Tag:            git tag v$next"
echo "  4. Push:           git push --follow-tags"
