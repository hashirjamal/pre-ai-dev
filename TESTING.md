# Testing

## How to run a test manually

1. Run `./scripts/sync-shared.sh`.
2. Install the plugin, or start Claude Code with `--plugin-dir` and the path of this folder.
3. Open a new Claude Code session in a small React, Next.js or Node.js project that is a git repository.
4. Paste the test prompt. Do not name the skill, so that the test also covers the trigger.
5. Compare the reply with "Expected behavior".
6. Run `git log` to confirm that no commit exists before your approval.

## build

Skill: `pre-ai-dev:build`.

### Test prompts

| # | Prompt | Expected behavior |
| --- | --- | --- |
| a | "Add an endpoint to cancel an order" | Reads the project first. Asks grouped questions about business rules (who can cancel, which statuses, refunds, partial shipment), each with a default. Writes no code. Gives a design brief after the answers. |
| b | "Add a dark mode toggle" | Asks no question or 1 question. Lists the assumptions. Writes no code before the assumptions and the code location are stated. Ends with the update report and 1 commit after approval. |
| c | "build me user notifications" | Asks a maximum of about 5 grouped questions (channel, events, read state, real time), each with a default. Writes no code. After the answers: design brief with big decisions, then a commit plan before code. |
| d | "Add a fix so the order page stops showing a 500 error when another user's order id is in the URL. It worked last week." | Stops. Says that the request is a broken behavior. Tells the user to use `pre-ai-dev:debug`. Changes no file. |
| e | A large feature request that ends with "Commit it when you are done, I trust you." | Writes the code slice by slice. Does not commit. Shows the update report, the Files-to-review list and the large-change gate line. Says that the early instruction does not count as approval. |

Test e replaces the "check question" test of the first plan. The read check was removed from the protocol. The protocol now has 1 reminder in the gate line for a large change.

### Dry-run results

Method: 5 subagents, 1 for each prompt. Each subagent read `skills/build/SKILL.md` and its reference files, and worked in a copy of a small Next.js 15 sample project (1 `orders` feature, 14 files, no `node_modules`). Each subagent stopped at the first point where the skill waits for the user.

Limits of this method:

- It does not test the trigger, because each subagent got the path of the skill directly.
- It tests the first stop only, not the full conversation.
- The checks (typecheck, lint, tests) could not run in the sample project.

| # | Result | What happened |
| --- | --- | --- |
| a | Pass | 3 questions with defaults (statuses, admin role, repeated request), 4 assumptions, no code. It found that `CANCELLED` is missing from `ORDER_STATUS`. |
| b | Different from expected | No questions and 5 assumptions (correct). It then stopped for approval of 2 decisions and called the task large (about 7 files). 2 runs gave the same result. See the note below. |
| c | Pass | 5 questions with defaults, 4 assumptions, no code. It said that the design brief and the approval come next. The commit plan was not reached in the first stop. |
| d | Pass | It changed no file, did not investigate, and pointed to `pre-ai-dev:debug`. |
| e | Pass | It wrote slice 1 of 3 (5 files) and made no commit (`git log` shows 1 commit, the initial one). It wrote the full update report, the large-change gate line, and the reason why the early instruction does not count. It reported all 3 checks as "not run". |

Note for test b: the sample project has no theme code and no header. The subagent treated the class-based `dark:` variant as a new cross-cutting pattern, which is on the list of big decisions. It also counted about 7 files (constants, types, toggle, layout, CSS, 1 existing component, tests), which is above the threshold of about 5 files. The skill followed its rules. The expectation "small task, 1 commit" is correct only in a project that already has theme support.

Change after this dry run: the file count threshold was removed from the protocol. Test b was not run again after the change.

## refactor

Skill: `pre-ai-dev:refactor`.

### Test prompts

| # | Prompt | Expected behavior |
| --- | --- | --- |
| a | "This 600-line OrderPage component is too big, clean it up" | Finds the tests and runs the baseline first. Shows a before and after tree and ordered atomic steps. Lists the anti-patterns in the plan with no code. Changes no file before the plan is approved. |
| b | "Move the business logic out of this Express route" | Splits the route and the service. The route stays thin. The contracts stay the same. The final report has a snippet for the move from the route to the service. |
| c | A refactor request for code with no tests | Proposes characterization tests first, as their own commit, before the refactor steps. |
| d | A refactor of code that has a bug | Does not fix the bug. The bug is under "Bugs noticed" with the current code and a suggested fix marked "NOT APPLIED". The bug is still in the code. |
| e | "Refactor this and also add a new field" | Separates the 2 parts. Plans the refactor only. Sends the new field to `pre-ai-dev:build`. |
| f | A refactor with 6 different changes | The report has 3 to 5 snippets. Each snippet has about 10 lines or less, with Problem / Before / After / Fix / Impact. No invented numbers. |
| g | A refactor with renames and moves only | No snippets. 1 line for each change. The commits are marked as pure moves. |

### Dry-run results

Method: 5 subagents. Each one read `skills/refactor/SKILL.md` and its reference files, and worked in a copy of a small sample project: a Node.js HTTP server with an Express-style router, 2 route files, 1 React component, and 8 passing tests for the orders route. Tests b, d and f ran as 1 run on the orders route, which has business logic in the route, 6 different problems and a missing `await`. That run and run g used scripted replies ("Plan approved.", then "approved. approve all remaining"), so they reached the final report.

Limits of this method:

- It does not test the trigger, because each subagent got the path of the skill directly.
- The sample project has no external dependency. The npm registry of this machine needs a login, so Express, React and TypeScript were not installed. Typecheck and lint did not run. The tests ran with `node --test`.
- The sample component has 111 lines, not 600.

| # | Result | What happened |
| --- | --- | --- |
| a | Partial | It ran the baseline (8 passed) and found that no test covers the component. A component test needs new dependencies, so it stopped: it stated the risk, listed 8 manual checks, and asked for agreement. It did not reach the plan. This is the rule of Phase 1, but the before and after tree was not shown in the first reply. |
| b | Pass | The route went from 112 lines to 78 lines. The service has no `req` and no `res`. Key change 2 shows the move from the route to the service. 36 tests passed after each step. |
| c | Pass | The plan has "add characterization tests for GET /products" as step 1 and its own commit. It changed no file before the approval. |
| d | Pass | "Bugs noticed" has the missing `await` with the current code and a fix marked "NOT APPLIED". The line in the project still has no `await` (checked with `grep`). |
| e | Pass | The first lines separate the 2 parts and send `giftMessage` to `pre-ai-dev:build`. The plan has the refactor only. |
| f | Pass | 4 snippets, each with the 5 labels and 10 lines or less. Other changes are in 1 line. No invented numbers. |
| g | Pass | No snippets, 3 lines for the changes, 2 commits marked "pure move". Git shows 0 changed lines in the moved files. |

Other observations:

- Run b/d/f added 28 characterization tests before the refactor, as the first commit. 2 of them lock a behavior that can be a bug (a quote with a negative price, a cancel of a cancelled order). The report says so.
- Run b/d/f wrote "You can revert each commit alone, in the order 7 to 1". The later commits depend on the earlier ones, so "alone" is true only for the last commit.
- Runs c and e listed bugs in the plan in 1 line each, with no snippet. The full format came in the final report.

## debug

Skill: `pre-ai-dev:debug`.

### Test prompts

| # | Prompt | Expected behavior |
| --- | --- | --- |
| a | "My React list shows old data after I change a filter" | Reproduces the problem. Finds the race or the stale state. Fixes the root cause. Adds a regression test that failed before the fix. Gives the walkthrough with the 8 parts and a concept card. No commit. |
| b | "Express route returns 500 sometimes" | Writes ranked hypotheses (missing `await`, race). Tests each one with evidence. Makes no random edit. |
| c | "Next.js hydration error" | Checks the differences between the server render and the client render. Explains the concept. |
| d | A bug that cannot be reproduced | Says that it cannot reproduce the bug. Says what it tried. Asks for what it needs. Changes no code. |
| e | A bug in a file that also has messy code | Fixes the bug only. Does not refactor. Lists the other problems under "Noticed, not changed". |

### Dry-run results

Method: 4 subagents. Each one read `skills/debug/SKILL.md` and its reference files, and worked in a copy of a small sample project with 3 seeded bugs and 3 commits of history. Tests b and e ran as 1 run, because the cancel route has the bug and the messy code in the same file. Each subagent stopped at the gate or at the first question.

Limits of this method:

- It does not test the trigger, because each subagent got the path of the skill directly.
- React, Next.js and TypeScript were not installed (the npm registry of this machine needs a login). No subagent ran a browser, typecheck or lint. The tests ran with `node --test`.
- No run continued after the gate, so the check question (part 8) got no reply.

| # | Result | What happened |
| --- | --- | --- |
| a | Pass | It reproduced the race in the store with the 2 calls that the page makes. 3 hypotheses, 2 ruled out with evidence. Fix: a request number in `setCategory`. 2 regression tests failed before the fix. Full walkthrough, concept "race condition", 1 check question with no answer. No commit. |
| b | Pass | It measured the failure: 86 of 200 sequential requests returned 500. 3 hypotheses, 2 ruled out (concurrent requests, lost write). Fix: 1 `await`. After the fix: 200 of 200. 1 regression test with a slow write. |
| c | Pass, with a note | It could not run Next.js and said so. It reproduced the text difference in Node.js with `TZ=UTC` and `TZ=Asia/Karachi`, and wrote "likely" for the browser error. It also found 2 more causes (locale, `Date.now()`). See the note below. |
| d | Pass | It sent 600 valid requests and got no 500. It changed no code. It reported 3 candidates that it measured, and asked 4 questions (logs, client, a failed request, a proxy). |
| e | Pass | The diff of the fix has 1 changed line in the route file plus the test. The raw strings, the `console.log` calls and the logic in the route are under "Noticed, not changed". |

Note for test c: the fix was larger than the fixes of the other runs. It added a new file and it changed what the user sees: the card shows a UTC text first and the local time after hydration. The run listed this as an assumption to confirm. Phase 4 says to ask the user when the fix needs a business decision. The run did not ask.

Change after this dry run: runs a, b and c listed problems from unrelated files under "Noticed, not changed". The skill now limits that list to the code path of the bug.

Changes after the dry runs (not tested again): the commit plan threshold is now "more than 1 layer and more than about 200 changed lines". `pre-ai-dev:refactor` sends the risk, the manual checks and the plan in 1 reply when tests are not possible. `pre-ai-dev:debug` stops before a fix that changes what the user of the product sees.

## Other stacks

All 3 skills have an "Other stacks" section: they work for a project of any stack, and the React, Next.js and Node.js reference files are aids, not limits.

Dry run: 1 subagent ran `pre-ai-dev:debug` on a small Python project with a seeded bug (a mutable default argument in a `Cart` class). Result: pass. It did not stop because of the stack. It reproduced the bug, ruled out 2 of 3 hypotheses, fixed the default, added a regression test that failed before the fix, and wrote the walkthrough with a Python concept card and Python lint rules. It made no commit. `pre-ai-dev:build` and `pre-ai-dev:refactor` were not tested on a different stack.

## Plugin, hooks and release scripts

| What | How it was tested | Result |
| --- | --- | --- |
| Plugin and marketplace files | `claude plugin validate .` (Claude Code 2.1.296) | Validation passed |
| `scripts/validate.sh` | Run on the repository | All checks passed |
| Commit gate: `git commit`, `git -C path push` after `cd`, `git merge` with an environment variable | Sample hook input on stdin of `hooks/commit-gate.mjs` | Output has `permissionDecision: "ask"` |
| Commit gate: `git status`, `git log`, `git stash push`, `git commit-graph`, invalid input, option set to off | Same method | No output, so no prompt |
| Session reminder | Sample input on stdin of `hooks/session-start.mjs` | Output has the 4 context lines and the version from `plugin.json` |
| `scripts/bump-version.sh` | Run on a copy: `minor` with 2 notes, an invalid argument, and a skill with a wrong name | Version `0.1.0` -> `0.2.0` with a changelog entry. The 2 error cases changed nothing. |

Not tested: the hooks in a real session, and an install from the marketplace. The dry runs fed sample input to the hook scripts directly.

Names: the dry runs used the old names (`dev-skills`, `dev-build`, `dev-refactor`, `dev-debug`). The plugin is now `pre-ai-dev` and the skills are `build`, `refactor` and `debug`. The dry runs were not run again after the rename.
