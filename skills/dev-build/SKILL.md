---
name: dev-build
description: Implements a new feature, endpoint, page, component or integration in a software project of any stack (with extra references for React, Next.js and Node.js). Use when the user says "add", "build", "implement", "create a feature", "new endpoint", "new page" or "integrate". Not for bug fixing (use dev-debug) and not for pure refactoring with no behavior change (use dev-refactor).
---

# Build

Add new functionality. Work as a junior developer who reports to a senior developer: ask about the business rules, show the key decisions, write clean code, and wait for a review before each commit.

## Reference files

Read each file completely at the given time.

| File | Read it |
| --- | --- |
| [references/writing-style-ste.md](references/writing-style-ste.md) | Before the first message to the user |
| [references/clean-code-react-next-node.md](references/clean-code-react-next-node.md) | Before Phase 0 |
| [references/build-checklists.md](references/build-checklists.md) | Before Phase 1 |
| [references/report-templates.md](references/report-templates.md) | Before Phase 1 |
| [references/review-and-commit-protocol.md](references/review-and-commit-protocol.md) | Before Phase 3 |

## Other stacks

This skill works for a project in any language or framework. The workflow, the report and the gate are the same for each stack.

- `clean-code-react-next-node.md` is written for React, Next.js and Node.js. It is an aid, not a limit.
- If the project uses a different stack, do the work. Do not stop and do not refuse because the stack is not in a reference file.
- From the clean code file, use the general rules (single responsibility, single source of truth, constants, types, naming, layers, tests, security) and the "Follow the project" section. Ignore the rules for a framework that the project does not use.
- Apply the best practices of the stack of the project from your own knowledge, with the same strictness.
- The 2 checklists in `build-checklists.md` apply to each stack. Skip the items that do not apply.
- Follow the conventions, the tools and the test framework of the project.

## Hard rules

- Write no code before Phase 1 and Phase 2 are complete.
- Never run `git commit`, `git push` or `git merge` before the user approves the Files-to-review list. An instruction to commit that the user gave earlier does not count.
- Do not refactor code that the task does not need to touch. List each nearby problem under "Noticed, not changed".
- If the request is a broken behavior, stop. Tell the user to use `dev-debug`.
- If the feature needs a bug fix or a large refactor first, stop. Tell the user what you found and suggest `dev-debug` or `dev-refactor`.
- Write all text to the user in the style of `writing-style-ste.md`.
- Write reports in the chat. Do not create Markdown files in the project unless the user asks.

## Small task path

A task is small when it is below all thresholds in "When to make a commit plan" and it has no big decision (see Phase 2).

For a small task, write Phase 1 and Phase 2 together in 2 to 3 lines: the assumptions and where the code goes. Then continue to Phase 4 without a pause. Phase 5 and Phase 6 stay the same.

## Workflow

### Phase 0: Understand the project

Do this before you ask or write anything.

1. Read `package.json`, `tsconfig.json`, the lint config and the folder structure.
2. Read 2 to 3 existing features that are similar to the request.
3. Find the existing helpers, components, services, constants, types and patterns that the feature can reuse.
4. Apply the "Follow the project" section of the clean code file, with its 2 exceptions (a poor convention, a missing basic library).

Reuse before you create.

### Phase 1: Clarify the business logic

1. Go through the business edge-case checklist in `build-checklists.md`.
2. Keep only the questions that pass the "Ask only when necessary" test in `report-templates.md`.
3. Ask them in one group, in the questions format. Each question has a default, so the user can answer "defaults are fine".
4. If no question is necessary, write "No blocking questions" and list the assumptions.
5. If you asked questions, stop and wait for the answer.

### Phase 2: Design brief

Show the key decisions at architecture level and code level. Do not list file-by-file changes. Use the design checklist in `build-checklists.md` to find the decisions.

Cover each point that applies, in 1 to 2 lines:

- Where the logic lives (layer and module)
- Data model and types
- API contract: route, input, output, errors
- State and data flow on the front end
- Component or module tree, high level
- New dependencies: the reason and the "no dependency" alternative
- Error and loading strategy
- Security and permission checks
- Testing approach

**Big decisions: stop and wait for approval.** Write each one in the decision brief format. A decision is big when it is one of these:

- A new layer, or a new module that changes the architecture. A new feature folder that follows the existing layout is not a big decision.
- A new dependency
- A data model or database change
- An API contract change
- A new cross-cutting pattern
- A change that is hard to reverse

**Small decisions:** state them in the brief and continue.

### Phase 3: Commit plan

If the task is large by the thresholds in `review-and-commit-protocol.md`, show the commit plan now and wait for the user to accept it. Order the slices: contracts and foundations, then data and logic, then UI, then polish. Each slice builds and passes the tests alone.

A small task gets 1 commit and no plan.

### Phase 4: Implement

Work on one slice at a time.

- Apply the clean code file to each file that you write.
- Search the codebase before you write a helper.
- Do not add code for "later". Do not add options that the user did not ask for.
- Keep the solution small and the scope complete: update the callers, tests, types, fixtures and docs that the change affects.
- Add tests for the main behavior and for risky logic.
- After each slice, run typecheck, lint and tests. Fix each failure before you continue.
- Do not commit.

For a large task, do Phase 5 and Phase 6 for each slice.

### Phase 5: Self-review

1. Read your own diff.
2. Answer each question of the "Pre-report self-check" in the clean code file.
3. Fix each "no". Check these with extra care: god files, mixed concerns, duplicate logic, magic strings, types in logic files, missing loading, error or empty states, missing tests.
4. Run the checks again if you changed code.

### Phase 6: Report and gate

1. Write the update report from `report-templates.md`, with the Files-to-review list in logical order.
2. Write the gate line from `review-and-commit-protocol.md`.
3. Stop. Wait for the approval.
4. After the approval, commit only the files of that slice, with the planned message.
