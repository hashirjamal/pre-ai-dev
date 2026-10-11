# Refactoring catalog

Standard moves for a refactor with no behavior change. Each move has: when to use it, the steps, and the risk.
Do 1 move in 1 commit. Run the checks after each move.

## Contents

- React
- Next.js
- Node.js
- General
- Smells to ignore

## React

**Split a large component by responsibility**
- When: a component does more than 1 job (data, logic, 2 or more UI regions).
- Steps: 1. List the responsibilities. 2. Move 1 UI region to a new component with explicit props. 3. Repeat for each region. 4. Keep the same rendered output.
- Risk: a moved region loses access to state or a ref. A changed `key` or position resets child state.

**Extract a custom hook**
- When: a component holds state and logic that do not depend on the JSX.
- Steps: 1. Move the state, the effects and the handlers to `useX()`. 2. Return only what the component uses. 3. Keep the same order of hooks.
- Risk: a changed dependency list, or a new object reference on each render that causes an effect to run again.

**Separate container and presentational components**
- When: 1 component fetches data and also renders detailed UI.
- Steps: 1. Keep data and wiring in the container. 2. Move the UI to a component that gets props only. 3. Pass the loading, error and empty states as props or render them in the container.
- Risk: a state of the view (loading, error, empty) gets lost in the split.

**Colocate state**
- When: a parent holds state that only 1 child uses.
- Steps: 1. Confirm that no other component reads the state. 2. Move the state and its handlers into the child.
- Risk: the state resets when the child unmounts. Before the move, the parent kept it.

**Remove derived state**
- When: `useState` holds a value that the code can compute from props or other state.
- Steps: 1. Replace the state with a `const` computed in render. 2. Delete the effect that set it. 3. Move the computation to a pure function if it has more than 1 line.
- Risk: the first render had the initial value before. Now it has the computed value. Confirm that no code depended on the old first value.

**Replace a bad `useEffect`**
- When: an effect reacts to a user event, computes a value, or resets state.
- Steps: for an event, move the code into the event handler. For a computed value, use the move "Remove derived state". For a reset, put a `key` on the component.
- Risk: the timing changes (the code runs in the handler, not after render). A `key` resets all state of the component, not 1 value.

**Replace hand-written fetch with the data layer**
- When: a component uses `useEffect` + `fetch` + `useState`, and the project already has a data library.
- Steps: 1. Move the request to a fetch function. 2. Add a query key constant. 3. Replace the effect and the 3 state values with the query hook. 4. Keep the loading, error and empty views.
- Risk: this move can change behavior: caching, refetch on focus, retries. Set the options to match the old behavior, or ask the user.

**Replace prop drilling with composition or context**
- When: 3 or more levels pass a prop that they do not use.
- Steps: 1. Try composition first: pass the element as `children` or a slot. 2. Use context only for shared data that changes rarely.
- Risk: context causes a render of each consumer. Composition changes the component API.

**Replace boolean flags with a discriminated union**
- When: 2 or more booleans describe 1 state (`isLoading`, `isError`, `isSuccess`).
- Steps: 1. Define the union type with a `status` field. 2. Replace the booleans with 1 state value. 3. Update each read to check `status`.
- Risk: the old flags permitted combinations (loading and error together). Confirm which combinations occurred.

**Extract constants for statuses, query keys and routes**
- When: the same string or number is in 2 or more places, or logic compares to a raw string.
- Steps: 1. Create the `as const` object in a constants file. 2. Replace each raw value. 3. Derive the union type from the object.
- Risk: 2 strings with the same text but different meanings get merged. A string in a test, a database row or an API response still needs the same value.

**Move types to a types file**
- When: a logic file or a component file defines types that other files use.
- Steps: 1. Move the types to `*.types.ts` next to the feature. 2. Update the imports with `import type`.
- Risk: a circular import if the types file imports from the logic file.

**Extract a form schema**
- When: a component validates fields with hand-written `if` statements.
- Steps: 1. Write the schema with the validation library of the project. 2. Derive the form type from the schema. 3. Replace the checks. 4. Keep the same messages.
- Risk: the schema accepts or rejects a value that the old checks did not. Compare each rule.

## Next.js

**Move `"use client"` down to the smallest leaf**
- When: a page or a large component is a client component because of 1 interactive part.
- Steps: 1. Move the interactive part to its own file with `"use client"`. 2. Remove the directive from the parent. 3. Pass server content as `children`.
- Risk: the parent used a hook or a browser API in another place. A prop that is not serializable now crosses the boundary.

**Move data fetching to the Server Component**
- When: a client component fetches data on mount that the server can fetch.
- Steps: 1. Fetch in the Server Component through the service. 2. Pass the data as props. 3. Delete the client fetch and its states. 4. Add `loading.tsx` or `Suspense` for the wait.
- Risk: this move changes when the data loads and how it is cached. State the caching behavior. Ask the user if the data must update on the client.

**Thin a route handler or a Server Action**
- When: the handler holds business rules or database calls.
- Steps: 1. Move the rules to a service function. 2. Keep 4 steps in the handler: validate, authorize, call the service, respond. 3. Keep the same status codes and response shape.
- Risk: an authorization check or a `revalidatePath` call gets lost in the move.

**Split a page into feature components**
- When: `page.tsx` holds feature UI and logic.
- Steps: 1. Move each region to a component in the feature folder. 2. Keep only the wiring in `page.tsx`.
- Risk: a moved component needs `"use client"` and takes more code to the client than before.

**Centralize env config**
- When: `process.env` is read in more than 1 file.
- Steps: 1. Create 1 config module that reads and validates each variable. 2. Replace each read. 3. Keep the same defaults.
- Risk: validation at startup makes the app fail on a missing variable that it tolerated before. A server variable imported into client code breaks the build.

## Node.js

**Extract a service from a fat route**
- When: a route or controller holds business logic.
- Steps: 1. Move the logic to a service function with plain inputs and outputs. 2. The route maps the request to the inputs and the result to the response. 3. Keep the same status codes, response shape and error cases.
- Risk: the service gets `req` or `res`. An early `return res.status(...)` inside the logic changes into a thrown error with a different response.

**Extract a repository from a service**
- When: a service holds database queries.
- Steps: 1. Move each query to a repository function with a name for its intent. 2. The service calls the repository. 3. Keep the same query and the same transaction limits.
- Risk: 2 queries that were in 1 transaction now run in 2.

**Centralize validation and error handling**
- When: each route has its own validation code and its own `try/catch` response.
- Steps: 1. Create 1 validation helper or middleware. 2. Create 1 error middleware. 3. Move 1 route at a time. 4. Keep the same status codes and error shape.
- Risk: the error shape or the status code changes for a client. Compare the responses before and after.

**Replace scattered `process.env` with a config module**
- When: `process.env` is read outside 1 config module.
- Steps: the same as "Centralize env config".
- Risk: the same as "Centralize env config". A value read at import time, not at call time, changes the behavior of tests that set the variable later.

**Introduce typed errors**
- When: the code throws plain `Error` objects or strings, and routes match on the message text.
- Steps: 1. Add an error class with a code constant. 2. Replace each `throw`. 3. Map the codes to status codes in 1 place. 4. Keep the same status codes and messages.
- Risk: code that matched on `error.message` stops matching.

**Remove `req` and `res` from services**
- When: a service function takes `req` or `res`.
- Steps: 1. List the fields that the service reads. 2. Pass them as plain parameters. 3. Return a value or throw a typed error. The route sends the response.
- Risk: the service set a header or a cookie on `res`. Move that to the route.

**Fix an N+1 query with no change of results**
- When: the code runs 1 query for each item of a list.
- Steps: 1. Record the results for a known data set. 2. Replace the loop with 1 batch query or a join. 3. Compare the results: same rows, same order, same handling of missing rows.
- Risk: high. The order, duplicates and missing rows can change. Do this move only with a test that compares the output.

## General

**Extract a function**
- When: a block of code does 1 complete job with a clear name.
- Steps: 1. Move the block to a function. 2. Pass the inputs as parameters. 3. Return the result. Do not change outer variables.
- Risk: the block changed a variable of the outer scope. Do not extract only to make a function shorter.

**Introduce a parameter object**
- When: a function takes 4 or more parameters, or 2 parameters of the same type in sequence.
- Steps: 1. Define a type for the object. 2. Change the signature. 3. Update each caller.
- Risk: a caller outside the scope (public API) breaks. Ask before you change a public signature.

**Replace magic strings and numbers with constants**
- When: logic contains a raw value with a meaning.
- Steps: the same as "Extract constants for statuses, query keys and routes".
- Risk: the same.

**Merge duplicates (rule of three)**
- When: 3 or more copies of the same logic exist, or 2 copies that must change together.
- Steps: 1. Diff the copies. 2. Confirm that each difference is an accident, not a rule. 3. Move the logic to 1 function. 4. Replace 1 copy at a time.
- Risk: 2 copies that look the same have different business rules. A merged function with flags for each caller is worse than the duplicates.

**Delete dead code**
- When: no code calls a function, export, branch or file.
- Steps: 1. Search for each use: imports, string references, dynamic imports, routes by file name, config files. 2. Delete. 3. Run the checks.
- Risk: the code is used by reflection, a framework convention or another package.

**Break a circular import**
- When: 2 modules import each other.
- Steps: 1. Find the shared part. 2. Move it to a third module that the 2 modules import. Alternative: move a type to a types file and use `import type`.
- Risk: the order of module initialization changes.

**Rename for intent**
- When: a name does not say what the thing is or does.
- Steps: 1. Use the rename tool of the editor or the language server. 2. Search for the old name in strings, tests and docs.
- Risk: a public export, a database column or a JSON key has the same name. Do not rename those.

**Flatten nesting with early returns**
- When: a function has 3 or more levels of `if`.
- Steps: 1. Invert the first condition and return early. 2. Repeat. 3. Keep the same order of checks.
- Risk: a changed order of checks changes which error the caller gets.

## Smells to ignore

These things look bad but are not worth a change in a refactor.

- 2 similar blocks that can diverge. Wait for the third.
- A long file with 1 responsibility: a constants list, a schema, a config, a set of small pure functions.
- A long function that is a flat sequence of steps with clear names.
- A style that the formatter or the linter of the project accepts.
- A name that is not perfect but is clear in its context.
- A pattern that is old but consistent in the full project. Report it. Do not change 1 file only.
- Code that works, has tests, and that the task does not touch.
- A local props type in a component file, when the project does this.
- A missing `useMemo` or `useCallback` with no measured problem.
- Generated code and vendored code.
