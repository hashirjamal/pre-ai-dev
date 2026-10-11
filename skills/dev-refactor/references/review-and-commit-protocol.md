<!-- Generated from shared/ - edit the file in shared/, then run scripts/sync-shared.sh -->

# Review and commit protocol

## Contents

- Approval gate
- Sequence before each commit
- Large change reminder
- Atomic commit rules
- Commit messages
- When to make a commit plan
- Large task procedure
- Scope rules

## Approval gate

- Never run `git commit`, `git push` or `git merge` without the explicit approval of the user for that commit.
- The approval counts only when the user gives it AFTER you show the Files-to-review list for that change.
- These replies count as approval: "approved", "commit it", or a reply with the same clear meaning.
- Silence does not count. An approval for an earlier commit does not count. A general "go ahead" from before the code existed does not count.
- If the user changes the code or asks for a change after the approval, the approval is no longer valid. Show the updated list and ask again.

## Sequence before each commit

1. Run the checks: typecheck, lint, tests. Use the scripts of the project.
2. Report the real results. If a check cannot run, say so and give the reason.
3. If a check fails, fix the cause or report it. Do not ask for approval as if the checks passed.
4. Show the Files-to-review list (see `report-templates.md`).
5. Write this line: "Read the files in the order above. Reply 'approved' only after you read them."
6. Stop. Wait for the reply.
7. After approval, commit only the files of that change.

## Large change reminder

A large change meets one of the thresholds in "When to make a commit plan".

- For a large change, write this gate line in place of the standard line: "This is a large change. Read the files in the order above. Reply 'approved' only after you read them."
- This line is the 1 reminder for that gate. Do not ask again after the user approves.
- Do not quiz the user about the code.
- If the user tells you to commit before you show the Files-to-review list, do not commit. Show the list and the gate line first.

## Atomic commit rules

- One commit is one logical change.
- Each commit builds and passes the tests on its own.
- Use separate commits for:
  - a pure refactor, move or rename (no behavior change)
  - tests
  - new behavior
  - config or dependency changes
- Never mix a refactor and a behavior change in one commit.
- Order the commits so that the user can revert each one alone.
- Put a preparation refactor before the behavior change that needs it.
- A test for new behavior can go in the same commit as the behavior when the project does this. A test that only adds coverage for existing behavior goes in its own commit.

## Commit messages

Use the Conventional Commits style: `<type>(<optional scope>): <summary>`.

- Types: `feat`, `fix`, `refactor`, `test`, `chore`, `docs`.
- Write the summary in the imperative, with a maximum of about 70 characters.
- Add a short body only when the summary does not explain the reason.
- Follow the existing commit convention of the project when it is different.

```text
refactor(orders): move price calculation to order.service

No behavior change. Prepares the refund feature.
```

## When to make a commit plan

Make a commit plan when one of these is true:

- The task crosses more than 1 layer and has more than about 200 changed lines.
- The task has more than 1 separate behavior.

A small task gets 1 commit.

## Large task procedure

1. Show the commit plan BEFORE you code. Use this format:

   ```markdown
   ## Commit plan
   1. `refactor(orders): move price calculation to order.service` - no behavior change
   2. `feat(orders): add refund service and types`
   3. `feat(orders): add refund route`
   4. `feat(orders): add refund dialog`
   ```

2. Wait for the user to accept or change the plan.
3. Work on one slice at a time. One slice is one commit of the plan.
4. After each slice:
   1. Run the checks.
   2. Show the Files-to-review list for that slice only.
   3. Wait for approval.
   4. Commit that slice only after approval.
5. If the plan must change during the work, tell the user before you continue.

The user can say "approve all remaining". Then do not pause between the remaining slices. Still run the checks for each slice, and make one commit for each slice. Stop if a check fails.

## Scope rules

- Never add an unrelated change to a slice.
- If you find an unrelated problem, report it in "Noticed, not changed". Do not fix it in the slice.
- Stage files by name. Do not use `git add -A` or `git add .`.
- Do not create Markdown files (reports, plans, notes, changelogs) in the project unless the user asks for them. Reports go in the chat.
- Never use `--no-verify`, `--amend` on a commit that the user approved, or a force push, unless the user tells you to.
