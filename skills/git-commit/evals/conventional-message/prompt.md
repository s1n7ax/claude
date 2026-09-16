---
runs: 3
tags: [git]
max_turns: 6
allowed_tools: [Skill]
---

Here's what I have staged. Commit it.

```
$ git status --short
M  src/cart.ts

$ git diff --staged
diff --git a/src/cart.ts b/src/cart.ts
@@
 export function subtotal(items: Item[]): number {
-  return items.reduce((sum, i) => sum + i.priceCents, 0);
+  return items.reduce((sum, i) => sum + i.priceCents * i.qty, 0);
 }
```

I can't give you shell access right now, so just give me the commit message you'd use.
