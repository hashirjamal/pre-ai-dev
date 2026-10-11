# Common bug patterns

Use these lists to write hypotheses in Phase 2. Each row has the symptom, the usual cause and the quickest check.
A row is an idea, not a result. Confirm each hypothesis with evidence.

## Contents

- React
- Next.js
- Node.js
- General
- Debugging toolbox

## React

| Symptom | Usual cause | Quickest check |
| --- | --- | --- |
| A handler, timer or effect uses an old value of state or props | Stale closure: the callback is from an old render | Log the value in render and in the callback. Compare. |
| An effect does not run when a value changes, or runs with old data | Wrong or missing effect dependencies | Read the dependency list. Look for a disabled `exhaustive-deps` rule. |
| "Too many re-renders", or the page freezes | State update during render, or an effect that sets state that it depends on | Find each `setState` in the render body and in effects. Check the dependency of each effect. |
| The UI does not update after a state change | State mutation (`push`, `sort`, direct assignment) keeps the same reference | Search for mutation of the state value. Compare references before and after. |
| 2 values that must agree show different data | Derived state stored in `useState` is out of sync | Find a `useState` that an effect sets from other state or props. |
| A list row shows the input or state of a different row | Wrong keys: array index, or a key that is not unique | Read the `key`. Reorder or delete a row and watch the state. |
| The view shows old data after a fast change of filter or page | Race in a fetch effect: a late response overwrites a newer one | Make the first request slow. Check for a cleanup or an abort in the effect. |
| A warning about a state update on an unmounted component, or a leak | An async callback or a subscription with no cleanup | Check the return function of the effect. |
| An effect or a memoized child runs on each render | Referential equality: a new object, array or function on each render | Log the dependencies. Look for inline objects and functions. |
| "A component is changing an uncontrolled input to be controlled" | `value` is `undefined` on the first render | Log `value` on the first render. Check the initial state. |
| "Rendered more hooks than during the previous render" | A hook after an early return, or in a condition or a loop | Read the component from the top. Find a hook below a `return` or in an `if`. |
| State is not the new value directly after `setState` | State updates are async and batched. The variable is from this render. | Look for a read of the state in the lines after the set. |

## Next.js

| Symptom | Usual cause | Quickest check |
| --- | --- | --- |
| "Hydration failed", or "Text content does not match" | The server HTML and the first client render are different: dates, time zone, locale, random values, `window`, `localStorage`, browser-only data | Search the component for `Date`, `Math.random`, `window`, `localStorage`, `toLocale...`. Disable browser extensions. |
| "You're importing a component that needs useState", or a function prop error | Server and client boundary: a hook in a Server Component, or a prop that is not serializable | Find the nearest `"use client"`. Check the props that cross the boundary. |
| Old data stays after a write | Caching or revalidation: no `revalidatePath` or `revalidateTag`, or a cached fetch | Read the cache options of the fetch for this Next.js version. Check the write path for a revalidation call. |
| An environment variable is `undefined` in the browser | The name has no `NEXT_PUBLIC_` prefix, or the variable was not set at build time | Check the name and the time when the value is read. |
| "Too many redirects" | A middleware or redirect loop: the target matches the rule again | Read the `matcher` and the redirect condition. Follow 1 request by hand. |
| A page shows the same data for all users, or the data never changes | The route is static when it must be dynamic | Read the build output for the route type. Look for `cookies()`, `headers()` and the route config. |
| A user changes data that they must not change | A Server Action with no validation or no authorization | Read the action. Find the session check and the schema. |
| It works in development and fails in the production build | Differences in caching, static rendering, environment variables, strict mode effects, or file name case | Run `next build` and `next start` locally. Compare the environment. |

## Node.js

| Symptom | Usual cause | Quickest check |
| --- | --- | --- |
| A result is old or missing sometimes. "UnhandledPromiseRejection". | Missing `await`: the code continues before the promise is complete | Search the function for calls that return a promise and have no `await` or `return`. |
| Duplicate rows, or a count below zero, under load | Race condition: check-then-write with no lock, constraint or transaction | Send 2 requests at the same time. Read the code between the read and the write. |
| All requests are slow at the same time | Event loop blocking: sync I/O or heavy CPU work in a request | Look for `*Sync` calls, large loops and large `JSON.parse`. Measure the event loop delay. |
| Requests hang after a period, then time out | Connection pool is empty: a connection that is not released, or a transaction with no end | Check each path, including error paths, for the release. Read the pool metrics. |
| An endpoint gets slower as the data grows | N+1 queries, or a query with no index | Log the queries of 1 request and count them. Run `EXPLAIN`. |
| `req.body` is `undefined`, a CORS error, or a route with no authentication | Wrong middleware order | Read the order of registration: body parser, CORS, authentication, routes, error handler. |
| A user sees the data of a different user | Shared mutable module state between requests | Search for module-level `let` and objects that a request writes to. |
| A date is 1 day off, or wrong near midnight | Time zone: local time mixed with UTC, or a date with no time zone | Log the ISO string and the time zone of the server. Test near midnight UTC. |
| A total is off by a small amount | Float money: arithmetic on decimal numbers | Compute the same value in integer minor units. Compare. |
| The client gets 200 or an empty body when the operation failed | A swallowed error, or a wrong status code | Read each `catch` block. Find the ones that do not rethrow, log or respond. |
| A page has a missing item or a repeated item | Off-by-one in pagination, or an order that is not stable | Check the offset arithmetic and the `ORDER BY`. Test page 1, page 2 and the last page. |
| Memory grows until a restart | Leak: listeners that are added again and again, or a cache with no limit | Take 2 heap snapshots and compare. Look for `on(` in a request path and for module-level maps. |
| It works on 1 machine or in 1 environment only | Differences in config, Node.js version, dependency version or data | Compare `node -v`, the lock file, the environment variables and the data. |

## General

| Symptom | Usual cause | Quickest check |
| --- | --- | --- |
| "Cannot read properties of undefined" | A path that can be `undefined` or `null` and has no check | Read the stack trace. Log the object 1 level above the failed property. |
| The types are correct, but the runtime value is different | A type lie: `as`, `any`, `!`, or external data with no validation | Search the path for casts. Log the real value at the boundary. |
| A field is missing, or has a different type or name | Wrong assumption about the shape of API data | Log the raw response. Compare it with the type. |
| Text has wrong characters, or sorting and number formats are wrong | Encoding or locale | Check the encoding of the source. Check the locale of `toLocale...`, `Intl` and sort calls. |
| A test fails sometimes, or only in the full run | Flaky test: real time, the order of the tests, or shared state | Run the test alone, then 20 times. Look for `Date.now()`, timers and shared fixtures. |
| "It works on my machine" | Differences in environment | The same check as the last row of the Node.js table. |

## Debugging toolbox

- **Stack trace:** read from the top to the first line that is in your own code. Start there. Lines in `node_modules` are usually the messenger, not the cause.
- **Failing test first:** write a test that shows the bug before the fix. It is the reproduction and the regression test.
- **Minimal reproduction:** remove code until the bug stops. The last piece that you removed is part of the cause.
- **`git bisect`:** use it for a regression. Give it 1 good commit and 1 bad commit. It finds the commit that started the bug with a binary search.
- **Logging with context:** log the value, the place and an id (request id, user id). Remove the temporary logs before the fix is complete.
- **Browser devtools:** the console for errors, the sources panel for breakpoints, the application panel for storage and cookies.
- **Network tab:** check the request body, the response, the status code, the timing and the order of the requests. It shows if the problem is on the client or on the server.
- **React Developer Tools and Profiler:** inspect props and state. Record a session to see which component renders and why.
- **Node.js inspector:** start with `node --inspect` or `node --inspect-brk`. Use breakpoints in place of many logs.
- **Change 1 variable at a time:** if you change 2 things and the bug stops, you do not know which change was the cause.
