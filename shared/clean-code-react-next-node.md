# Clean code standard: React, Next.js, Node.js

This file is the quality standard for all code that you write or change.

## Contents

- Follow the project
- General and TypeScript
- React
- Next.js
- Node.js
- Testing
- Security and performance basics
- Pre-report self-check

## Follow the project

Do these checks before you apply a rule from this file.

- Read the folder layout. Find where features, types, services and tests live.
- Read the lint config, the formatter config and `tsconfig.json`.
- Read `package.json`. Find the framework version, the router type (App Router or Pages Router), the data library, the form library, the styling approach and the test tools.
- Read 2 or 3 existing files of the same type as the file that you will write. Copy their conventions.
- The conventions of the project win when they conflict with this file. Tell the user about each conflict: the rule, what the project does, and what you did.
- Do not add a new library, pattern or folder convention when the project already has one for the same job.

**Exception: a poor convention**

A convention is poor when following it breaks a core rule of this file. Examples: business logic in route handlers, `any` everywhere, 1 god file for a feature, raw strings for status values.

1. Do not copy the poor convention into new code without asking.
2. Ask the user before you write the code. Use the questions format in `report-templates.md`.
3. Give 2 options: follow the project, or apply this file in the new code only.
4. State the default: follow the project.
5. Do not refactor the existing code unless the user asks.

**Exception: a missing basic library**

A basic library is missing when the task needs a common tool and the project has none for that job. Examples: a form library for a complex form, a validation library (such as Zod), a data library for server state (such as TanStack Query).

1. Do not add the library without asking.
2. Do not hand-write a large replacement without asking.
3. Ask the user before you write the code. Name the library, the reason, and the cost (bundle size, new pattern).
4. State the default: no new library, and a simple solution that uses the existing tools.

## General and TypeScript

**Responsibility and size**

- Each file, function, component and module has a single responsibility. A file has one reason to change.
- Size signals are guides, not laws. Split when you see one of these: a component over about 150 lines, a function over about 40 lines, a file with more than 1 responsibility.
- Split by responsibility. Never split by line count only.
- Never create a helper that exists only to make a function shorter. A helper must have a name that describes one complete job.

**Single source of truth**

- Each rule, value, type, config value and piece of business logic has one home.
- Merge duplicate logic that must change together.
- Follow the rule of three. Do not create an abstraction after 2 similar cases when the cases can diverge.
- Do not copy a type by hand. Derive it from the source (`z.infer`, `typeof`, `ReturnType`, `Pick`, `Omit`).

**Constants**

- No magic strings and no magic numbers in logic.
- Use named constants, `as const` objects, string-literal unions or enums for: status values, roles, event names, route paths, query keys, error codes, storage keys, feature flags.
- Never compare to a raw string in logic. Write `order.status === ORDER_STATUS.PAID`, not `order.status === "paid"`.
- Follow the existing project choice between enums and `as const` objects.

**Types**

- Types live in their own files (`types.ts` or `*.types.ts`) next to the feature. Do not define shared types in a business-logic file.
- A type that only one function uses, such as a local props type, can stay in the same file when the project does this.
- Prefer type inference. Add an explicit type on exported functions and on public boundaries.
- Front end and back end share types through one place (a shared package, a shared folder or generated types).
- Use TypeScript strict mode.
- Do not use `any`. Use `unknown` and narrow it.
- Do not use `as` casts or `!` to silence the compiler. Narrow with a type guard or a schema.
- Use a discriminated union in place of 2 or more boolean flags that describe one state.
- Validate external data at the boundary (for example with Zod). Derive the type from the schema.

**Naming and control flow**

- Use names that show the intent. Use verbs for functions and nouns for data.
- Use `is`, `has` or `can` as the prefix of a boolean.
- Do not use abbreviations, except the ones that the project already uses.
- Use early returns in place of deep nesting.
- Remove dead code. Remove commented-out code.
- A comment explains WHY, not WHAT.

**Functions and modules**

- Write logic as pure functions where possible. Keep side effects at the edges.
- Group folders by feature, not only by file type.
- Be careful with barrel files (`index.ts` re-exports). They can cause circular imports and larger bundles. Follow the existing project choice.
- Dependencies point in one direction: UI -> hooks or services -> data access. Shared code does not import from a feature.
- No circular imports.

## React

**Component design**

- A component is small and does one job.
- Split into 3 roles: page or container (data and wiring), presentational component (UI only), custom hook (logic and state).
- Put logic in custom hooks, not in JSX. Keep JSX readable.
- No business rules in components. Put them in a pure function or a service.
- Do not define a component inside another component.
- Prefer composition (`children`, slots) to deep prop drilling and to long prop lists.

**State**

- Keep state as local as possible. Lift state only when 2 components need it.
- Do not store derived data in state. Compute it during render.
- Use `useMemo` for derived data only after you measure a problem.
- Never mutate state or props.
- Use context only for shared data that changes rarely. Split contexts by concern.

**Effects**

- Use `useEffect` only to synchronize with a system outside React.
- Do not use an effect to compute derived data.
- Do not use an effect to react to a user event. Use the event handler.
- Do not use an effect to reset state. Use a `key`.
- List the correct dependencies. Do not disable the lint rule for dependencies.
- Clean up each subscription, timer and listener.

**Server state**

- API data goes through the data layer of the project: TanStack Query, SWR or the data features of the framework.
- Do not write `useEffect` + `fetch` + `useState` by hand.
- Each data view handles 4 states: loading, error, empty, success.

**Lists and forms**

- Use stable, unique keys. Never use the array index as the key of a dynamic list.
- Use one approach for forms: controlled inputs or the form library of the project.
- Share the validation schema with the server where possible.

**Accessibility**

- Use semantic HTML. Use `button` for an action and `a` for navigation.
- Each input has a label.
- Each interactive element works with the keyboard.
- Manage focus in dialogs, menus and route changes.
- Each image has alt text. Use an empty `alt` for a decorative image.
- Use `aria-*` only when semantic HTML is not sufficient.

**Performance and reliability**

- Use `React.memo`, `useMemo` and `useCallback` only for a measured problem or when a stable reference is necessary.
- If the project uses the React Compiler, do not add manual memoization.
- Put an error boundary around risky UI.

**Styling**

- Follow the styling approach of the project. Do not add a second approach.

## Next.js

These rules are for the App Router. The last group gives the differences for the Pages Router.

**Server and client components**

- Use Server Components by default.
- Add `"use client"` only at the smallest leaf that needs state, effects or browser APIs.
- Keep client bundles small. Pass server-rendered content into a client component as `children`.
- Do not import server-only code into a client component. Add `import "server-only"` to modules that must stay on the server.
- Pass only serializable props from a Server Component to a client component.

**Data**

- Fetch data on the server where possible.
- Avoid request waterfalls. Start independent requests in parallel (`Promise.all`).
- Use `Suspense`, `loading.tsx`, `error.tsx` and `not-found.tsx` for streaming and error states.
- State the caching and revalidation behavior of each data fetch that you add.
- Do not rely on a caching default that you did not check for the Next.js version of the project. The defaults changed between major versions.
- After a write, revalidate the data that the write changed (`revalidatePath`, `revalidateTag` or the equivalent of the project).

**Route handlers and Server Actions**

- Keep them thin. They do 4 steps: validate input, check authentication and authorization, call a service, return a response.
- No business logic in a route handler or a Server Action.
- A Server Action is a public endpoint. Validate and authorize in each one.

**Secrets and config**

- Never expose a secret to the client. Only `NEXT_PUBLIC_` variables go to the browser.
- Validate environment variables at startup in one config module.

**Framework features**

- Use `next/image`, `next/font` and the metadata API.
- Use dynamic imports for heavy client-only code.

**File layout**

- Keep route files (`page`, `layout`, `route`) thin. They do the wiring only.
- Feature code lives in feature folders.

**Pages Router differences**

- There are no Server Components and no Server Actions. All page components go to the client.
- Fetch server data in `getServerSideProps` or `getStaticProps`. Keep these functions thin: call a service and return the props.
- Set revalidation with `revalidate` in `getStaticProps`.
- API routes in `pages/api` follow the same thin-handler rule.
- Use `_app.tsx`, `_document.tsx` and `next/head` in place of layouts and the metadata API.
- Do not mix router conventions in one route.

## Node.js

Follow the framework of the project (Express, Fastify, Nest or a similar one).

**Layers**

- Use 3 layers: route or controller (HTTP only) -> service (business logic) -> repository or data access (database).
- No business logic in routes.
- No HTTP objects (`req`, `res`) in services.
- No database calls in routes or controllers.

**Input**

- Validate all input at the boundary with a schema: body, params, query, headers.
- Never trust client data.
- Use separate types for requests (DTOs) and for the domain.

**Errors**

- Use typed or custom error classes with codes.
- Use one error-handling middleware.
- Use one shape for all error responses.
- Never swallow an error. A `catch` block must handle the error, rethrow it or log it with context.
- Never send a stack trace or internal detail to a client.

**Async**

- Always `await` a promise or return it. Handle each rejection.
- Do not block the event loop with heavy CPU work or sync I/O.

**Config**

- Read configuration from validated environment variables in one config module.
- No secrets in code.
- Do not read `process.env` outside the config module.

**Data**

- Use a transaction for a write with more than 1 step.
- Check each check-then-write sequence for race conditions. Use a unique constraint, a lock or an atomic query.
- Make an operation idempotent when a client can retry it (payments, webhooks, job handlers).
- Avoid N+1 queries.
- Paginate each list endpoint.
- Add an index for each new query pattern.

**Authentication and authorization**

- Check authentication and authorization on each protected route, in middleware or guards.
- Check the order of the middleware.
- Check ownership of the resource, not only the role of the user.

**Logging**

- Use the structured logger of the project. Include context such as the request id.
- No `console.log` in production code.
- Do not log secrets or personal data.

**Module boundaries**

- Use dependency injection or clear module boundaries. A service must be testable without the network and without the database.

**API design**

- Use consistent names and correct status codes.
- Follow the versioning approach of the project.

## Testing

- Test behavior, not implementation.
- Write unit tests for services and pure logic.
- Write integration tests for routes.
- Write component tests for UI behavior with Testing Library. Query by role and label, not by class name or test id, where possible.
- A bug fix needs a test that fails before the fix and passes after the fix.
- Risky new logic needs a minimum of 1 test: money, security, data writes, parsers, branching logic.
- Do not weaken or delete a failing test to make the checks pass. Tell the user.

## Security and performance basics

**Security**

- Injection: use parameterized queries. Never build SQL, shell commands or HTML from raw input.
- XSS: do not use `dangerouslySetInnerHTML` with data that is not sanitized.
- CSRF: protect each state-changing request that uses cookie authentication.
- Authorization gaps: check each new endpoint and each new Server Action.
- Sensitive data: return only the fields that the client needs. Do not return full database rows.
- Dependencies: add a dependency only when it is necessary. Tell the user about each new dependency.

**Performance**

- Avoid re-renders that are not necessary, large bundles and slow queries.
- Measure before you optimize. State the measurement in the report.

## Pre-report self-check

Answer each question with yes or no before you write the report. Fix each "no", or list it in "Not checked / risks".

1. Does each file that I changed have one responsibility?
2. Is each route, handler, Server Action and controller thin, with the business logic in a service?
3. Is each component free of business rules, with the logic in a hook or a pure function?
4. Does each rule, value and type have a single source of truth, with no duplicate logic?
5. Did I replace each raw string and number in logic with a named constant?
6. Are the types in type files, with no `any` and no unsafe cast?
7. Is all external data validated at the boundary with a schema?
8. Does each data view handle the loading, error and empty states?
9. Is each `useEffect` a synchronization with an outside system, with correct dependencies and cleanup?
10. Does each protected endpoint check authentication and authorization, and is each error handled?
11. Did I follow the conventions of the project, list each conflict with this file, and ask about each poor convention and each missing basic library?
12. Did I run typecheck, lint and tests, and do I have the real results?
