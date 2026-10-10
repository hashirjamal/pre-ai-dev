# Report templates

Write all reports in the style of `writing-style-ste.md`.
Write all reports in the chat. Do not save a report to a file unless the user asks for it.
Omit a section only when it has no content. Then write the heading with "None."

## Contents

- 1. Update report
- 2. Files-to-review list
- 3. Decision brief
- 4. Questions format

## 1. Update report

Write this report at the end of each task.

```markdown
## What I did
- <3 to 6 short bullets. Outcome level. No line-by-line changes.>

## Key decisions
- <Architecture level: where the logic lives, data flow, new modules, new dependencies, patterns, trade-offs.>
- <Each decision ends with: "Rejected: <alternative>, because <reason>." in one line.>

## Assumptions I made
- <Business logic or requirement that I assumed.> (confirm or correct)

## Open questions
<Use the questions format in section 4. Write "None." when no question is necessary.>

## Not checked / risks
<1 to 2 lines. Checks that did not run, paths that I did not test, known risks.>

## Checks
- Typecheck: <pass | fail | not run: reason>
- Lint: <pass | fail | not run: reason>
- Tests: <N passed, N failed | not run: reason>

## Files to review
<Use the list in section 2.>

## Commit plan
<Use the rules in review-and-commit-protocol.md. For a small task: 1 commit message.>

## Gate
Read the files in the order above. Reply 'approved' only after you read them.
```

Rules:

- "Key decisions" holds architecture points only. Use the decision brief in section 3 for a decision that needs an answer from the user.
- "Assumptions I made" holds each business rule that the user did not state and that the code now depends on.
- Report the real results of the checks. Do not write "pass" for a check that did not run.

## 2. Files-to-review list

A numbered list in logical reading order. Never use alphabetical order.

**Order of layers**

1. Contracts and foundations: types, schemas, constants, config
2. Data layer: repositories, queries, migrations, API clients
3. Business logic: services, hooks, pure functions
4. Entry points: routes, handlers, Server Actions
5. UI: components, then pages
6. Tests
7. Tool config and docs

Inside a layer, order by dependency. Put the file that other files use first.

**Format of each file**

```markdown
1. `path/to/file.ts` (read first)
   Change: <the key change, 1 short line>
   Check: <why it matters, or what to check, 1 short line>
```

Rules:

- Write exactly 2 lines for each file.
- Mark the file with the highest risk with "(read first)" or "(read carefully)". Mark 1 file, or a maximum of 2 files for a large change.
- Put all trivial files in one last line: "Not listed: `package-lock.json`, 3 files with formatting changes only."

**Example**

```markdown
1. `features/orders/orders.types.ts`
   Change: Added `RefundRequest` and the `REFUND_STATUS` constant.
   Check: The status values must match the values of the payment provider.
2. `features/orders/refund.service.ts` (read carefully)
   Change: New `createRefund()` with a partial refund calculation.
   Check: The rounding rule on line 42 is an assumption.
3. `app/api/orders/[id]/refund/route.ts`
   Change: New POST handler. It validates, authorizes and calls the service.
   Check: Only the owner of the order and an admin can call it.
4. `features/orders/RefundDialog.tsx`
   Change: New dialog with the refund form.
   Check: The error state shows the message from the server.
5. `features/orders/refund.service.test.ts`
   Change: 6 tests for full, partial and repeated refunds.
   Check: There is no test for a refund in a second currency.

Not listed: `package-lock.json`.
```

## 3. Decision brief

Use this brief for a key decision that the user must see or approve. Write as a junior developer who reports to a senior developer.

```markdown
**Decision:** <what I chose, 1 line>
**Why:** <the main reason, 1 to 2 lines>
**Alternative I rejected:** <the alternative and the reason, 1 line>
**Impact if you disagree:** <what must change and how large the change is, 1 line>
```

Rules:

- Write a decision brief for: a new module or layer, a new dependency, a change of data flow, a schema or API contract change, a change of pattern.
- Do not write a decision brief for a choice that the conventions of the project already make.
- Ask before you code when the decision is expensive to reverse. Report after you code when it is cheap to reverse.

## 4. Questions format

Use this format for questions about business logic and edge cases.

**Ask only when necessary**

Ask a question only when all 3 conditions are true:

- The answer changes the code, the data or the behavior.
- The code, the docs and the task do not give the answer.
- A wrong guess is expensive to fix later.

If one condition is false, do not ask. Use a sensible default and list it in "Assumptions I made".
Zero questions is a correct result. Do not add questions to fill the section.

Do not ask:

- A question with an obvious answer.
- A question about a general best practice. Apply the practice.
- A question that only confirms what the user already said.

```markdown
**Business logic**
1. <Question in 1 sentence?>
   Default if no answer: <the assumption that I will use>

**Edge cases**
2. <Question in 1 sentence?>
   Default if no answer: <the assumption that I will use>
```

Rules:

- Ask a maximum of about 5 questions. Ask the questions with the highest impact first.
- Ask all questions in one group, not one at a time.
- Each question has a default assumption.
- Do not ask a question that the code or the docs of the project can answer.
- A question must be specific: "Can a user refund an order after 30 days?", not "What are the refund rules?"
- If the user does not answer, use the default. Then list it in "Assumptions I made".
