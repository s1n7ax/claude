---
runs: 3
tags: [git]
max_turns: 6
allowed_tools: [Skill]
---

Here's what I have staged. Commit it.

```
$ git status --short
M  README.md
M  src/cart.ts
M  src/retry.ts

$ git diff --staged
diff --git a/README.md b/README.md
@@
-Handles cart chekout.
+Handles cart checkout.

diff --git a/src/cart.ts b/src/cart.ts
@@
 export function subtotal(items: Item[]): number {
-  return items.reduce((sum, i) => sum + i.priceCents, 0);
+  return items.reduce((sum, i) => sum + i.priceCents * i.qty, 0);
 }

diff --git a/src/retry.ts b/src/retry.ts
@@
-export async function retry<T>(fn: () => Promise<T>): Promise<T> {
-  return fn();
+export async function retry<T>(fn: () => Promise<T>, attempts = 3): Promise<T> {
+  let lastErr: unknown;
+  for (let i = 0; i < attempts; i++) {
+    try {
+      return await fn();
+    } catch (err) {
+      lastErr = err;
+      await sleep(2 ** i * 100);
+    }
+  }
+  throw lastErr;
 }
```

I can't give you shell access right now, so just give me the commit message you'd use.
