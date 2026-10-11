# Key change and bug formats

Use these formats in the final report of a refactor.

## Contents

- Key change format
- Rules for key changes
- Bug format
- Example 1: business logic inside the route (Node.js)
- Example 2: derived state in useState (React)
- Example 3: raw string comparison (TypeScript)
- Example 4: a "Bugs noticed" entry

## Key change format

Use exactly this format for each key change.

````markdown
### <number>. <anti-pattern name in plain words> (`<file path>`)
**Problem:** <1 sentence. What was wrong.>
**Before:**
```ts
<trimmed code>
```
**After:**
```ts
<trimmed code>
```
**Fix:** <1 to 2 sentences. What changed and why it works.>
**Impact:** <1 to 2 sentences. What is better.>
````

## Rules for key changes

**Selection**

- Show only the 3 to 5 changes with the highest value. Select by learning value and risk, not by the number of changed lines.
- If there are more changes, put them in 1 line: "Other changes of the same type: ...".
- If the same problem was in many places, show 1 example. Then write the count: "Same fix in 6 other files."
- Do not show a snippet for a mechanical change: a rename, a file move, formatting, an import update. Describe it in 1 line.
- If the refactor has only mechanical changes, write no snippets. Write 1 line for each change.

**Snippets**

- A snippet has a maximum of about 10 lines.
- Trim the code. Use `// ...` for the parts that you removed.
- Show only the lines that matter to the point.
- The snippet must be correct and readable on its own.
- Keep the real names of the project when they help. Remove noise.
- The "Before" snippet is the real code from before the change, not code from memory.

**Text**

- Name the anti-pattern in plain words: "business logic inside the route", "derived state in useState", "raw string comparison", "useEffect for an event".
- If the anti-pattern has a common name, add it 1 time in brackets.
- Problem, Fix and Impact together have about 60 words or less. Code does not count.
- Do not use praise words such as "much cleaner" or "better design". Say what is different.
- State only an impact that you can justify: readability, testability, reuse, bundle size, safety, fewer bugs.
- Never invent a number. If you did not measure an impact, write "not measured".

## Bug format

Do not fix a bug inside a refactor. Use this format for each bug.

````markdown
**Bug:** <1 sentence.>
**Where:** `<file path>`, lines <from> to <to>
**Current code:**
```ts
<maximum 8 lines>
```
**Likely cause:** <1 sentence.>
**Suggested fix (NOT APPLIED):**
```ts
<maximum 8 lines>
```
**Next step:** Use `dev-debug` to confirm the cause and apply the fix.
````

Rules:

- Write "Likely cause" when you did not confirm the cause. Write "Cause" only when you confirmed it.
- Give the line numbers of the code after the refactor.
- The code that the refactor leaves in the project must still have the bug.

## Example 1: business logic inside the route (Node.js)

````markdown
### 1. Business logic inside the route (`src/routes/orders.routes.ts`)
**Problem:** The route handler calculated the order total and wrote to the database.
**Before:**
```ts
router.post("/orders", async (req, res) => {
  const { items, coupon } = req.body;
  let total = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  if (coupon === "VIP10") total = total * 0.9;
  const order = await db.order.create({ data: { items, total } });
  res.status(201).json(order);
});
```
**After:**
```ts
router.post("/orders", async (req, res) => {
  const { items, coupon } = req.body;
  const order = await createOrder({ items, coupon });
  res.status(201).json(order);
});
```
**Fix:** The calculation and the database write moved to `createOrder()` in `order.service.ts`. The route reads the request and sends the response only.
**Impact:** A unit test can call `createOrder()` with no HTTP server. A second entry point can use the same rule.
````

## Example 2: derived state in useState (React)

````markdown
### 2. Derived state in useState (`src/features/cart/CartSummary.tsx`)
**Problem:** The component stored the cart total in state and updated it in an effect.
**Before:**
```tsx
const [items, setItems] = useState<CartItem[]>([]);
const [total, setTotal] = useState(0);

useEffect(() => {
  setTotal(items.reduce((sum, item) => sum + item.price * item.quantity, 0));
}, [items]);
```
**After:**
```tsx
const [items, setItems] = useState<CartItem[]>([]);
const total = calculateCartTotal(items);
```
**Fix:** The component computes `total` during render with the pure function `calculateCartTotal()`. The effect and the second state value are gone.
**Impact:** `total` cannot be out of date. Each change of `items` causes 1 render, not 2. Render time: not measured.
````

## Example 3: raw string comparison (TypeScript)

````markdown
### 3. Raw string comparison (`src/features/orders/order.rules.ts`)
**Problem:** The code compared the order status to raw strings in 7 files.
**Before:**
```ts
if (order.status === "shipped" || order.status === "delivered") {
  return false;
}
```
**After:**
```ts
// orders.constants.ts
export const ORDER_STATUS = { PENDING: "pending", SHIPPED: "shipped", DELIVERED: "delivered" } as const;
export type OrderStatus = (typeof ORDER_STATUS)[keyof typeof ORDER_STATUS];

// order.rules.ts
if (order.status === ORDER_STATUS.SHIPPED || order.status === ORDER_STATUS.DELIVERED) {
  return false;
}
```
**Fix:** `ORDER_STATUS` is the single source of the status values. The `OrderStatus` type comes from the object.
**Impact:** The compiler rejects a status with a spelling error. A new status needs a change in 1 file. Same fix in 6 other files.
````

## Example 4: a "Bugs noticed" entry

````markdown
**Bug:** The cancel endpoint can return the order with the old status.
**Where:** `src/features/orders/order.service.ts`, lines 41 to 44
**Current code:**
```ts
export async function cancelOrder(orderId: string) {
  orderRepository.updateStatus(orderId, ORDER_STATUS.CANCELLED);
  return orderRepository.findById(orderId);
}
```
**Likely cause:** The call to `updateStatus()` has no `await`, so the read can run before the write is complete.
**Suggested fix (NOT APPLIED):**
```ts
export async function cancelOrder(orderId: string) {
  await orderRepository.updateStatus(orderId, ORDER_STATUS.CANCELLED);
  return orderRepository.findById(orderId);
}
```
**Next step:** Use `dev-debug` to confirm the cause and apply the fix.
````
