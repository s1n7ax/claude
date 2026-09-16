---
runs: 3
tags: [logging]
max_turns: 6
allowed_tools: [Skill]
---

Our Node service already uses pino. `src/log.ts` has:

```ts
import pino from "pino";
export const logger = pino({ name: "api" });
```

Add logging to this handler. Reply with the finished code only.

```ts
export async function createOrder(userId: string, items: Item[]) {
  const order = await db.orders.insert({ userId, items });
  await payments.charge(userId, order.total);
  return order;
}
```
