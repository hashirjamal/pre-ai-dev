#!/usr/bin/env bash
# Copies shared/*.md into skills/<skill>/references/ so each skill folder is self-contained.
# Safe to run many times: each run rewrites the copies from shared/.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHARED_DIR="$ROOT_DIR/shared"
SKILLS_DIR="$ROOT_DIR/skills"
HEADER="<!-- Generated from shared/ - edit the file in shared/, then run scripts/sync-shared.sh -->"

shopt -s nullglob
shared_files=("$SHARED_DIR"/*.md)
skill_dirs=("$SKILLS_DIR"/*/)

if [ ${#shared_files[@]} -eq 0 ]; then
  echo "Error: no .md files in $SHARED_DIR" >&2
  exit 1
fi
if [ ${#skill_dirs[@]} -eq 0 ]; then
  echo "Error: no skill folders in $SKILLS_DIR" >&2
  exit 1
fi

for skill_dir in "${skill_dirs[@]}"; do
  skill_name="$(basename "$skill_dir")"
  references_dir="${skill_dir}references"
  mkdir -p "$references_dir"

  # Remove a generated copy when its source no longer exists in shared/.
  # Files without the header belong to the skill and stay.
  for existing_file in "$references_dir"/*.md; do
    file_name="$(basename "$existing_file")"
    if [ ! -f "$SHARED_DIR/$file_name" ] && [ "$(head -n 1 "$existing_file")" = "$HEADER" ]; then
      rm "$existing_file"
      echo "removed  skills/$skill_name/references/$file_name (no source in shared/)"
    fi
  done

  for shared_file in "${shared_files[@]}"; do
    file_name="$(basename "$shared_file")"
    { printf '%s\n\n' "$HEADER"; cat "$shared_file"; } > "$references_dir/$file_name"
    echo "copied   shared/$file_name -> skills/$skill_name/references/$file_name"
  done
done

echo "Done: ${#shared_files[@]} files to ${#skill_dirs[@]} skills."
