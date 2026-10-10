# dev-skills

3 personal Claude Code skills for React, Next.js, Node.js and TypeScript work.

| Skill | Job |
| --- | --- |
| `dev-build` | Add a new feature or new functionality. |
| `dev-refactor` | Change the structure of code with no behavior change. |
| `dev-debug` | Find the root cause of a problem, fix it, and explain what happened. |

All 3 skills share 4 rule files: writing style, clean code standard, report templates, review and commit protocol.

## Structure

```text
dev-skills/
  shared/                  single source of truth for the shared rules
  scripts/sync-shared.sh   copies shared/*.md into each skill
  skills/
    dev-build/
    dev-refactor/
    dev-debug/
      SKILL.md
      references/          generated copies of shared/ + files of the skill
  .claude-plugin/plugin.json
  TESTING.md
```

## Sync

Each skill folder must be self-contained, so each skill has its own copy of the shared files.

1. Edit the file in `shared/`. Do not edit a generated copy in `references/`.
2. Run the script:

   ```bash
   ./scripts/sync-shared.sh
   ```

The script is safe to run many times. It also removes a generated copy when you delete its source from `shared/`.

## Install

Personal install, for all projects:

```bash
./scripts/sync-shared.sh
mkdir -p ~/.claude/skills
cp -r skills/dev-build skills/dev-refactor skills/dev-debug ~/.claude/skills/
```

Run the 3 commands again after each change.
