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

Shell access is broken on this box, so you can't run git yourself — write out the
exact `git commit` command you'd run for me to paste.
