# Build checklists

Use these checklists to find questions and decisions. They are not a list of questions to ask.
Answer each item from the request and the code first. Skip each item that does not apply to the feature.

## Contents

- 1. Design checklist
- 2. Business edge-case checklist

## 1. Design checklist

Use it in Phase 2 to find the key decisions.

**Layers**

- Which layer holds the new logic: route, service, repository, hook, component?
- Which existing module does the feature belong to? Is a new module necessary?
- Do the dependencies point in one direction?
- Which existing code can the feature reuse?

**Contracts**

- What are the new types and schemas? Where is their single source of truth?
- What is the API contract: route, method, input, output, status codes, error codes?
- Does the feature change an existing contract? Who uses that contract?
- Which new constants are necessary (status values, roles, query keys, error codes)?

**Data**

- Does the data model change? Is a migration necessary?
- What happens to the existing rows?
- Which queries are new? Does each one have an index?
- Which writes need a transaction?

**State and data flow**

- Which data is server state and which data is client state?
- Where does each piece of state live?
- Which caches must the feature invalidate or revalidate after a write?
- Which parts are Server Components and which parts need `"use client"`?

**Errors**

- Which errors can occur? Which error class and code does each one use?
- What does the user see for each error?
- What are the loading, empty and error states of each view?

**Security**

- Who can call each new entry point? Where is the check?
- Does the check include ownership of the resource?
- Which input is validated, and where?
- Does the response return only the fields that the client needs?

**Tests**

- What is the main behavior to test?
- Which logic is risky (money, security, data writes, parsers, branching)?
- Which test level fits each one: unit, integration, component?

**Performance**

- Does the feature add a request waterfall or an N+1 query?
- Does a list need pagination?
- Does the feature add a heavy client dependency?

**Rollout**

- Is the change backward compatible with the current clients and data?
- Is a feature flag, an environment variable or a migration step necessary?
- Can the user revert the change with no data loss?

## 2. Business edge-case checklist

Use it in Phase 1. Each item is a question that a developer can ask the product owner.

| Topic | Question |
| --- | --- |
| Roles and permissions | Who can do this action? Who must not see it? |
| Empty, zero, one, many | What happens with 0 items, 1 item and 10,000 items? |
| Limits and pagination | Is there a maximum (count, size, length, rate)? What happens at the limit? |
| Duplicates and idempotency | What happens when the user sends the same request 2 times? |
| Concurrent actions | What happens when 2 users change the same record at the same time? |
| Partial failure and rollback | If step 2 of 3 fails, what state must the data have? |
| Time zones and dates | Which time zone applies: the user, the server or the business? Are the limits inclusive? |
| Money and rounding | Which currency and precision? Which rounding rule? Who gets the remainder? |
| Deletion | Is the deletion soft or hard? Can the user restore the record? What happens to linked records? |
| Audit and history | Must the system record who did the action and when? |
| Notifications | Who gets a notification, through which channel, and when? |
| Validation rules | Which fields are required? What are the formats and the ranges? |
| Error messages | What must the user see when the action is refused? |
| Existing data | What happens to the records that exist before this feature? |
| Backward compatibility | Do old clients, links or integrations continue to work? |
| State transitions | From which statuses is the action permitted? Can the user undo it? |
