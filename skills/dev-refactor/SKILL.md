---
name: dev-refactor
description: Restructures or cleans up existing code of any stack (with extra references for React, Next.js and Node.js) with no behavior change. Use when the user says "refactor", "clean up", "split this file", "too big", "god component", "extract", "remove duplication", "move logic out of the route" or "make this maintainable". Not for adding features (use dev-build) and not for fixing bugs (use dev-debug).
---

# Refactor

Change the structure of existing code. The behavior stays the same. Work in small steps that the user can review and revert one at a time.

## Reference files

Read each file completely at the given time.

| File | Read it |
| --- | --- |
| [references/writing-style-ste.md](references/writing-style-ste.md) | Before the first message to the user |
| [references/clean-code-react-next-node.md](references/clean-code-react-next-node.md) | Before Phase 2 |
| [references/refactoring-catalog.md](references/refactoring-catalog.md) | Before Phase 3 |
| [references/report-templates.md](references/report-templates.md) | Before Phase 3 |
| [references/review-and-commit-protocol.md](references/review-and-commit-protocol.md) | Before Phase 3 |
| [references/key-change-snippet-format.md](references/key-change-snippet-format.md) | Before Phase 4 |

## Other stacks

This skill works for a project in any language or framework. The workflow, the report and the gate are the same for each stack.

- `clean-code-react-next-node.md` and `refactoring-catalog.md` are written for React, Next.js and Node.js. They are aids, not limits.
- If the project uses a different stack, do the work. Do not stop and do not refuse because the stack is not in a reference file.
- From the clean code file, use the general rules (single responsibility, single source of truth, constants, types, naming, layers, tests) and the "Follow the project" section. Ignore the rules for a framework that the project does not use.
- From the catalog, use the "General" moves and the "Smells to ignore" list. The Node.js moves for layers (service, repository, config, typed errors) apply to each back end. Use the standard refactoring moves of the stack of the project for the rest.
- Follow the conventions, the tools and the test framework of the project.

## Hard rules

- No behavior change. If a step needs one, stop and ask.
- No refactor without a safety net or a manual check that the user agreed to.
- No new dependency unless the user approves it.
- Small steps that the user can revert. No rewrite of a full area in one step.
- Never fix a bug inside a refactor. Report it under "Bugs noticed" with a snippet.
- Never run `git commit`, `git push` or `git merge` before the user approves the Files-to-review list. An instruction to commit that the user gave earlier does not count.
- If the request also asks for new behavior (a new field, a new rule, a new endpoint), separate the 2 parts. Do the refactor here. Tell the user to use `dev-build` for the new behavior after the refactor.
- If the request is a broken behavior, stop. Tell the user to use `dev-debug`.
- Write all text to the user in the style of `writing-style-ste.md`.
- Write reports in the chat. Do not create Markdown files in the project unless the user asks.

## Workflow

### Phase 0: Scope

1. Confirm what to refactor: the files, the feature or the folder that the user named.
2. Do not make the scope larger without asking.
3. Write 1 to 2 lines about the behavior that must stay the same: public exports, route contracts, props, rendered output, database effects.

### Phase 1: Safety net

1. Find the tests that cover the scope.
2. Run typecheck, lint and tests. Record the result as the baseline.
3. If the baseline is red, tell the user before you continue.
4. If the scope has no tests, propose small characterization tests (tests that lock the current behavior). Write them before the refactor, as their own commit.
5. If tests are not possible, tell the user the risk plainly and list the manual checks. Do not stop here. Continue to Phase 2 and Phase 3, and send the risk, the manual checks and the plan in 1 reply. The approval of the plan is also the agreement to the manual checks.

### Phase 2: Diagnose

Use the clean code file as the standard. Look for these problems inside the scope:

- God files and god components, mixed concerns
- Business logic in routes or components
- Duplicate logic, no single source of truth
- Raw string comparisons, types in logic files
- Prop drilling, derived state in `useState`, wrong use of `useEffect`, hand-written data fetching
- Deep nesting, dead code, unclear names
- Circular imports, wrong dependency direction

Give evidence for each problem: the file, the size, the number of responsibilities. Rank the problems by value and risk. Do not fix all of them. Select the ones with the highest value inside the scope.

### Phase 3: Plan

Show these 4 parts. Then stop and wait for the approval of the plan.

1. **Before and after structure:** a short file tree, with the role of each new file in 1 line.
2. **Anti-patterns to fix:** a list with 1 line for each. No code snippets in the plan.
3. **Ordered steps:** each step is 1 atomic commit, keeps the app working, and can be reverted alone. Use separate steps for: characterization tests, moves and renames, extraction, new constants and types, removal of duplicates, deletion of dead code. Mark each step that is a pure move.
4. **Key decisions:** in the decision brief format. Say where each responsibility moves and why, which abstractions you add, which abstractions you refuse to add, and the risks.

### Phase 4: Execute

Do one step at a time.

1. Record the "before" code of each key anti-pattern, with the file path, before you change it. Keep the record in your working notes, not in a file.
2. Make the change. Use the moves in `refactoring-catalog.md`. Prefer mechanical changes.
3. Run typecheck, lint and tests. Continue only when the result is the same as the baseline or better.
4. Show the step report (see Phase 6) and wait for the approval. Then commit that step.

Rules during a step:

- Keep the public APIs stable unless the user approved a change.
- Keep the error handling and the validation when you move code.
- Do not rewrite code for taste.
- If you find a bug, do not fix it. Record it for "Bugs noticed". If the refactor cannot continue without the fix, stop and ask.
- If you find a question about business logic, ask the user. Do not guess.

### Phase 5: Verify no behavior change

Do these checks after the last step. State what you checked and what you could not check.

- The tests pass.
- The public exports and the route contracts are the same as before.
- There are no new circular imports.
- There are no unused files or exports.
- The effect on imports or on the bundle is acceptable.

### Phase 6: Report and gate

**Step report (each step before the last one):** the step name, the check results, the Files-to-review list for that step, and the gate line. Keep it short.

**Final report (with the last step):** use the update report from `report-templates.md` with these sections, in this order.

1. **What I did:** 3 to 6 bullets at outcome level, then the before and after structure.
2. **Key changes: before and after:** follow `key-change-snippet-format.md`. Show the 3 to 5 changes with the highest value.
3. **Key decisions**
4. **What stayed the same on purpose:** public exports, contracts, behavior.
5. **Assumptions I made**
6. **Open questions**
7. **Not checked / risks**
8. **Bugs noticed:** follow the bug format in `key-change-snippet-format.md`. Write "None." when there are none.
9. **Noticed, not changed:** other problems that are out of scope.
10. **Checks:** the baseline result and the final result.
11. **Files to review**
12. **Commit plan:** the status of each commit (done, waits for approval). Mark each commit that is a pure move.
13. **Gate**

Then apply the gate from `review-and-commit-protocol.md`: stop, wait for the approval, and commit only after it.
