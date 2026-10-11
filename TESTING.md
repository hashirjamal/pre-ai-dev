# Testing

## How to run a test manually

1. Run `./scripts/sync-shared.sh`.
2. Copy the skill to `~/.claude/skills/`.
3. Open a new Claude Code session in a small React, Next.js or Node.js project that is a git repository.
4. Paste the test prompt. Do not name the skill, so that the test also covers the trigger.
5. Compare the reply with "Expected behavior".
6. Run `git log` to confirm that no commit exists before your approval.

## build

Skill: `dev-build`.

### Test prompts

| # | Prompt | Expected behavior |
| --- | --- | --- |
| a | "Add an endpoint to cancel an order" | Reads the project first. Asks grouped questions about business rules (who can cancel, which statuses, refunds, partial shipment), each with a default. Writes no code. Gives a design brief after the answers. |
| b | "Add a dark mode toggle" | Asks no question or 1 question. Lists the assumptions. Writes no code before the assumptions and the code location are stated. Ends with the update report and 1 commit after approval. |
| c | "build me user notifications" | Asks a maximum of about 5 grouped questions (channel, events, read state, real time), each with a default. Writes no code. After the answers: design brief with big decisions, then a commit plan before code. |
| d | "Add a fix so the order page stops showing a 500 error when another user's order id is in the URL. It worked last week." | Stops. Says that the request is a broken behavior. Tells the user to use `dev-debug`. Changes no file. |
| e | A large feature request that ends with "Commit it when you are done, I trust you." | Writes the code slice by slice. Does not commit. Shows the update report, the Files-to-review list and the large-change gate line. Says that the early instruction does not count as approval. |

Test e replaces the "check question" test of the first plan. The read check was removed from the protocol. The protocol now has 1 reminder in the gate line for a large change.

### Dry-run results

Method: 5 subagents, 1 for each prompt. Each subagent read `skills/dev-build/SKILL.md` and its reference files, and worked in a copy of a small Next.js 15 sample project (1 `orders` feature, 14 files, no `node_modules`). Each subagent stopped at the first point where the skill waits for the user.

Limits of this method:

- It does not test the trigger, because each subagent got the path of the skill directly.
- It tests the first stop only, not the full conversation.
- The checks (typecheck, lint, tests) could not run in the sample project.

| # | Result | What happened |
| --- | --- | --- |
| a | Pass | 3 questions with defaults (statuses, admin role, repeated request), 4 assumptions, no code. It found that `CANCELLED` is missing from `ORDER_STATUS`. |
| b | Different from expected | No questions and 5 assumptions (correct). It then stopped for approval of 2 decisions and called the task large (about 7 files). 2 runs gave the same result. See the note below. |
| c | Pass | 5 questions with defaults, 4 assumptions, no code. It said that the design brief and the approval come next. The commit plan was not reached in the first stop. |
| d | Pass | It changed no file, did not investigate, and pointed to `dev-debug`. |
| e | Pass | It wrote slice 1 of 3 (5 files) and made no commit (`git log` shows 1 commit, the initial one). It wrote the full update report, the large-change gate line, and the reason why the early instruction does not count. It reported all 3 checks as "not run". |

Note for test b: the sample project has no theme code and no header. The subagent treated the class-based `dark:` variant as a new cross-cutting pattern, which is on the list of big decisions. It also counted about 7 files (constants, types, toggle, layout, CSS, 1 existing component, tests), which is above the threshold of about 5 files. The skill followed its rules. The expectation "small task, 1 commit" is correct only in a project that already has theme support.

Change after this dry run: the file count threshold was removed from the protocol. Test b was not run again after the change.

## refactor

Skill: `dev-refactor`.

### Test prompts

| # | Prompt | Expected behavior |
| --- | --- | --- |
| a | "This 600-line OrderPage component is too big, clean it up" | Finds the tests and runs the baseline first. Shows a before and after tree and ordered atomic steps. Lists the anti-patterns in the plan with no code. Changes no file before the plan is approved. |
| b | "Move the business logic out of this Express route" | Splits the route and the service. The route stays thin. The contracts stay the same. The final report has a snippet for the move from the route to the service. |
| c | A refactor request for code with no tests | Proposes characterization tests first, as their own commit, before the refactor steps. |
| d | A refactor of code that has a bug | Does not fix the bug. The bug is under "Bugs noticed" with the current code and a suggested fix marked "NOT APPLIED". The bug is still in the code. |
| e | "Refactor this and also add a new field" | Separates the 2 parts. Plans the refactor only. Sends the new field to `dev-build`. |
| f | A refactor with 6 different changes | The report has 3 to 5 snippets. Each snippet has about 10 lines or less, with Problem / Before / After / Fix / Impact. No invented numbers. |
| g | A refactor with renames and moves only | No snippets. 1 line for each change. The commits are marked as pure moves. |

### Dry-run results

Method: 5 subagents. Each one read `skills/dev-refactor/SKILL.md` and its reference files, and worked in a copy of a small sample project: a Node.js HTTP server with an Express-style router, 2 route files, 1 React component, and 8 passing tests for the orders route. Tests b, d and f ran as 1 run on the orders route, which has business logic in the route, 6 different problems and a missing `await`. That run and run g used scripted replies ("Plan approved.", then "approved. approve all remaining"), so they reached the final report.

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
| e | Pass | The first lines separate the 2 parts and send `giftMessage` to `dev-build`. The plan has the refactor only. |
| f | Pass | 4 snippets, each with the 5 labels and 10 lines or less. Other changes are in 1 line. No invented numbers. |
| g | Pass | No snippets, 3 lines for the changes, 2 commits marked "pure move". Git shows 0 changed lines in the moved files. |

Other observations:

- Run b/d/f added 28 characterization tests before the refactor, as the first commit. 2 of them lock a behavior that can be a bug (a quote with a negative price, a cancel of a cancelled order). The report says so.
- Run b/d/f wrote "You can revert each commit alone, in the order 7 to 1". The later commits depend on the earlier ones, so "alone" is true only for the last commit.
- Runs c and e listed bugs in the plan in 1 line each, with no snippet. The full format came in the final report.
