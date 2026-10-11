---
name: dev-debug
description: Finds the root cause of a problem in a software project of any stack (with extra references for React, Next.js and Node.js), fixes it, and explains the cause step by step. Use for "bug", "error", "exception", "not working", "broken", "crashes", "fails", "why does this happen", "flaky", "slow", "stack trace", "regression", "undefined", "500", "hydration error", "infinite loop". Not for new features (use dev-build) or pure refactoring (use dev-refactor).
---

# Debug

Find the root cause, make the smallest correct fix, and teach the user what happened. The walkthrough in Phase 6 is the main output. The user must understand the cause, the concept and the fix.

## Reference files

Read each file completely at the given time.

| File | Read it |
| --- | --- |
| [references/writing-style-ste.md](references/writing-style-ste.md) | Before the first message to the user |
| [references/common-bug-patterns.md](references/common-bug-patterns.md) | Before Phase 2 |
| [references/clean-code-react-next-node.md](references/clean-code-react-next-node.md) | Before Phase 4 |
| [references/debug-walkthrough-template.md](references/debug-walkthrough-template.md) | Before Phase 6 |
| [references/report-templates.md](references/report-templates.md) | Before Phase 7 |
| [references/review-and-commit-protocol.md](references/review-and-commit-protocol.md) | Before Phase 7 |

## Other stacks

This skill works for a project in any language or framework. The workflow, the walkthrough and the gate are the same for each stack.

- `clean-code-react-next-node.md` and `common-bug-patterns.md` are written for React, Next.js and Node.js. They are aids, not limits.
- If the project uses a different stack, do the work. Do not stop and do not refuse because the stack is not in a reference file.
- From the clean code file, use the general rules (single responsibility, single source of truth, constants, naming, tests) and the "Follow the project" section. Ignore the rules for a framework that the project does not use.
- From the bug patterns file, use the "General" table and the debugging toolbox. Write the other hypotheses from your knowledge of the stack of the project.
- Follow the conventions, the tools and the test framework of the project.

## Hard rules

- Never fix before you understand the cause.
- Never write "it works now" without a verified result.
- Do not change code at random to see if the problem goes away.
- No refactoring, no new features and no dependency upgrades inside a bug fix. If an upgrade is the root cause, ask the user first.
- Be honest about uncertainty. If you did not confirm the cause, write "likely" and say what evidence confirms it.
- Never skip the walkthrough. For a small bug, make each part shorter, but keep the 8 parts.
- Never run `git commit`, `git push` or `git merge` before the user approves the Files-to-review list. An instruction to commit that the user gave earlier does not count.
- If the request is new behavior, stop and tell the user to use `dev-build`. If it is cleanup with no broken behavior, tell the user to use `dev-refactor`.
- Write all text to the user in the style of `writing-style-ste.md`.
- Write reports in the chat. Do not create Markdown files in the project unless the user asks.

## Workflow

### Phase 0: Gather

Collect the facts:

- The exact error or symptom
- The steps
- The expected behavior and the actual behavior
- The environment: browser, Node.js version, development or production
- What changed recently: `git log`, `git diff`, a new dependency, a new deploy

Look in the code, the logs and the git history first. Ask the user only for the facts that you cannot find.

### Phase 1: Reproduce

Reproduce the problem before you change code. Run the exact steps, or write a failing test.

If you cannot reproduce the problem:

1. Say so plainly.
2. Do not write a fix for a cause that you guessed.
3. Tell the user what you tried and what you found.
4. Ask for what you need: the exact steps, a log, a request, the data, the environment.
5. Stop and wait.

### Phase 2: Hypothesize and test

1. Write 2 to 4 hypotheses. Rank them. Use `common-bug-patterns.md` for ideas.
2. Test the hypothesis that is cheapest and most likely first.
3. Use evidence: logs, a debugger, a minimal reproduction, `git bisect`, removal of 1 variable at a time.
4. Record each hypothesis as "confirmed" or "ruled out", with the reason. Keep the dead ends for the walkthrough.

Remove each temporary log and each debug change before Phase 4.

### Phase 3: Root cause

1. Separate the symptom (what the user saw) from the cause (why it occurred).
2. Ask "why" a maximum of 5 times. Stop at the cause that, when fixed, prevents the full class of the problem.
3. State the root cause in 1 to 2 plain sentences, with the file and the lines.
4. Name the concept behind it. Examples: stale closure, race condition, referential equality, hydration mismatch, N+1 query, event loop blocking, missing `await`, mutation of shared state, cache invalidation, floating-point money, time zone, off-by-one.

### Phase 4: Fix

1. Make the smallest correct fix at the root cause, not at the symptom.
2. Add a regression test that fails before the fix and passes after the fix. If a test is not practical, say why.
3. Search for the same pattern in callers and in similar code. Report what you found. Do not fix the other places without asking.
4. Follow the clean code file: the fix must not add a god file, a magic string or duplicate logic.
5. Do not refactor around the fix. List each problem in the code path of the bug under "Noticed, not changed" and suggest `dev-refactor`. Do not list problems in unrelated files.
6. If the fix needs a business decision, ask the user in the questions format, with a default.
7. If the fix changes what the user of the product sees (text, format, layout, timing), stop before you write the fix. Describe the change and wait for the approval.

### Phase 5: Verify

1. Run the reproduction again.
2. Run the new test. Confirm that it fails without the fix and passes with the fix.
3. Run typecheck, lint and the full test suite.
4. Report the real results. If a check cannot run, say so.

### Phase 6: Teach

Write the walkthrough with the 8 parts of `debug-walkthrough-template.md`:

1. The symptom
2. How we reproduced it
3. How we narrowed it down
4. The root cause
5. The concept behind it (concept card)
6. The fix and why it works
7. How to catch it next time
8. One check question

Tell the real path, including the dead ends that taught something. Ask exactly 1 check question. Give the answer only after the user replies or asks for it.

### Phase 7: Report and gate

After the walkthrough, write the short update report from `report-templates.md`:

- **What I did:** 2 to 4 bullets. Do not repeat the walkthrough.
- **Key decisions:** only if there are any.
- **Assumptions I made**, **Open questions**, **Not checked / risks**
- **Same pattern in other places:** what the search in Phase 4 found.
- **Noticed, not changed**
- **Checks**, **Files to review**, **Commit plan**, **Gate**

A bug fix is usually 1 commit: the fix and the regression test together. If you split it, follow the atomic commit rules.

Then apply the gate from `review-and-commit-protocol.md`: stop, wait for the approval, and commit only after it.
