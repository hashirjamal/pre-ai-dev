# pre-ai-dev

A Claude Code plugin with 3 skills for daily development work, plus 2 hooks.

| Skill | Job |
| --- | --- |
| `pre-ai-dev:build` | Add a new feature or new functionality. |
| `pre-ai-dev:refactor` | Change the structure of code with no behavior change. |
| `pre-ai-dev:debug` | Find the root cause of a problem, fix it, and explain what happened. |

All 3 skills share 4 rule files: writing style, clean code standard, report templates, review and commit protocol. The skills work for a project of any stack. The reference files have extra rules for React, Next.js and Node.js.

As a plugin, the skills have the plugin name as a prefix: `/pre-ai-dev:build`, `/pre-ai-dev:refactor`, `/pre-ai-dev:debug`. Claude also selects them from a plain request.

## Contents

- Requirements
- Install from the marketplace
- Update
- Uninstall
- Hooks
- Structure
- Change a skill
- Versioning
- Release a new version
- Test a change before a release
- Personal install without the plugin

## Requirements

- A current version of Claude Code (tested with 2.1.296)
- Node.js on `PATH` (the hooks are Node.js scripts)
- `git` for an install from GitHub

## Install from the marketplace

This repository is a plugin and also its own marketplace. The marketplace name is `pre-ai-dev-marketplace`.


```text
/plugin marketplace add hashirjamal/pre-ai-dev
/plugin install pre-ai-dev@pre-ai-dev-marketplace
```

The same in a shell:

```bash
claude plugin marketplace add hashirjamal/pre-ai-dev
claude plugin install pre-ai-dev@pre-ai-dev-marketplace
```

**From a local folder** (for the author, on the machine that has this folder):

```bash
claude plugin marketplace add /home/hashirjamal/pre-ai-dev/dev-skills
claude plugin install pre-ai-dev@pre-ai-dev-marketplace
```

After the install:

1. Claude Code asks for the "Commit gate" option. Keep it on (see "Hooks").
2. Open a new session, or run `/reload-plugins`.
3. Type `/pre-ai-dev:` to confirm that the 3 skills appear.

If you have the old personal copies in `~/.claude/skills/` (the folders `dev-build`, `dev-refactor`, `dev-debug`), delete them after you install the plugin. They have the old names and the old text.

## Update

**Installed from GitHub.** You get an update only when the `version` in `.claude-plugin/plugin.json` changes.

```text
/plugin marketplace update pre-ai-dev-marketplace
```

or in a shell:

```bash
claude plugin marketplace update pre-ai-dev-marketplace
claude plugin update pre-ai-dev@pre-ai-dev-marketplace
```

Then open a new session, or run `/reload-plugins`.

Auto-update is off by default. To turn it on: run `/plugin`, open "Marketplaces", select `pre-ai-dev-marketplace`, and select "Enable auto-update".

**Installed from a local folder.** Claude Code reads the files directly from the folder. A change applies at the next session start or after `/reload-plugins`. No version change is necessary.

## Uninstall

```bash
claude plugin uninstall pre-ai-dev@pre-ai-dev-marketplace
claude plugin marketplace remove pre-ai-dev-marketplace
```

## Hooks

The plugin has 2 hooks in `hooks/hooks.json`. They are active in each session while the plugin is enabled, also when no skill is in use.

| Hook | Event | What it does |
| --- | --- | --- |
| Session reminder | `SessionStart` | Adds 4 lines to the context: the plugin version, the 3 skills, the review-before-commit rule, and the rule about reports in the chat. |
| Commit gate | `PreToolUse` on `Bash` | When Claude runs `git commit`, `git push` or `git merge`, Claude Code shows a permission prompt. You approve or reject. |

Notes for the commit gate:

- It does not block a command. It asks you. It also asks in auto mode.
- It does not check that you read the files. The prompt is the reminder.
- It reads only commands that Claude runs. A `git commit` that you type in your own terminal is not affected.
- In a non-interactive run (`claude -p`), nobody can answer the prompt, so Claude Code denies the command.
- To turn it off: run `/config`, find the "Commit gate" option of the plugin, and set it to off.

## Structure

```text
dev-skills/                (the repository folder)
  .claude-plugin/
    plugin.json            plugin manifest: name, version, options
    marketplace.json       marketplace catalog with 1 entry (this plugin)
  hooks/
    hooks.json             hook configuration
    session-start.mjs      session reminder
    commit-gate.mjs        commit gate
  shared/                  single source of truth for the shared rules
  skills/
    pre-ai-dev:build/
    pre-ai-dev:refactor/
    pre-ai-dev:debug/
      SKILL.md
      references/          generated copies of shared/ + files of the skill
  scripts/
    sync-shared.sh         copies shared/*.md into each skill
    validate.sh            checks the plugin
    bump-version.sh        releases a new version
  CHANGELOG.md
  TESTING.md
```

## Change a skill

1. Edit the file.
   - A shared rule: edit it in `shared/`. Do not edit a generated copy in `references/`.
   - A rule of 1 skill: edit it in `skills/<skill>/`.
   - A hook: edit it in `hooks/`.
2. Sync and check:

   ```bash
   ./scripts/sync-shared.sh
   ./scripts/validate.sh
   ```

3. Test the change (see "Test a change before a release").
4. Release a new version (see below).

Each skill folder must be self-contained, so each skill has its own copy of the shared files. The sync script makes the copies. It is safe to run many times. It also removes a generated copy when you delete its source from `shared/`.

## Versioning

The version is in 1 place only: `version` in `.claude-plugin/plugin.json`. Do not add a `version` to `marketplace.json`.

A user who installed from GitHub gets a change only when the version changes. If you push a change and keep the version, the users stay on the old copy.

The version has 3 numbers: `MAJOR.MINOR.PATCH`.

| Change | Number | Examples |
| --- | --- | --- |
| The same behavior, better text | PATCH | A spelling fix. A clearer sentence. A new example. A fix in a script. |
| New behavior that does not break the workflow | MINOR | A new rule or checklist item. A new section in a report. A new reference file. A new skill. A new hook that only adds context. |
| A change that the user must know before the update | MAJOR | A skill is removed or gets a new name. A phase or a gate is removed or works differently. A new hook that asks or blocks. A removed report section. |

Rules:

- 1 release has 1 version change. Do not change the version 2 times for 1 release.
- Never use a version number again. Never move a tag.
- Each release has an entry in `CHANGELOG.md`.
- Each release has a git tag: `v<version>`.

## Release a new version

Use the script. Do not edit the version by hand.

```bash
./scripts/bump-version.sh <patch|minor|major|X.Y.Z> "change note" "second change note"
```

Example:

```bash
./scripts/bump-version.sh minor "pre-ai-dev:debug: stop before a fix that changes the UI"
```

The script does these steps:

1. Runs `sync-shared.sh`.
2. Runs `validate.sh`. It stops if a check fails, and changes nothing.
3. Writes the new version to `.claude-plugin/plugin.json`.
4. Adds an entry with the date and your notes at the top of `CHANGELOG.md`.
5. Prints the git commands. It does not run git.

Then do these steps:

1. Read the diff: `git diff`
2. Commit: `git add -A && git commit -m "chore(release): v<version>"`
3. Tag: `git tag v<version>`
4. Push: `git push --follow-tags`
5. Update your own install (see "Update").

## Test a change before a release

Load the plugin from the folder for 1 session, with no install:

```bash
claude --plugin-dir /home/hashirjamal/pre-ai-dev/dev-skills
```

Check the plugin and the marketplace file:

```bash
./scripts/validate.sh
claude plugin validate .
```

`TESTING.md` has the test prompts for each skill and the results of the dry runs.

## Personal install without the plugin

Do not copy the skills to `~/.claude/skills/`. The skill names are `build`, `refactor` and `debug`. A personal skill with the name `debug` replaces the bundled `/debug` command of Claude Code. As a plugin, the names have the `pre-ai-dev:` prefix, so there is no conflict.

To use the skills with no marketplace, load the plugin from the folder:

```bash
claude --plugin-dir /home/hashirjamal/pre-ai-dev/dev-skills
```
