---
runs: 3
tags: [logging]
max_turns: 6
allowed_tools: [Skill]
---

This project uses pino — `src/log.ts` exports `logger`. Nothing is logged when
this blows up in production. Fix that. Reply with the finished code only.

```ts
export async function syncInvoices(tenantId: string) {
  try {
    const rows = await billing.fetchInvoices(tenantId);
    await db.invoices.bulkUpsert(rows);
    return rows.length;
  } catch (cause) {
    throw new InvoiceSyncError(`sync failed for ${tenantId}`, { cause });
  }
}
```
