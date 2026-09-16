---
runs: 3
tags: [error-handling]
max_turns: 6
allowed_tools: [Skill]
---

Clean up the error handling in this module. Reply with the finished code only.

```ts
export async function getUser(id: string) {
  if (!id) throw new Error("id is required");
  const row = await db.users.findById(id);
  if (!row) throw new Error("user not found");
  if (row.deletedAt) throw new Error("user is deactivated");
  return row;
}
```
