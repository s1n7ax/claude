---
runs: 3
tags: [todo]
max_turns: 6
allowed_tools: [Skill]
---

Leave a TODO in here reminding us to add a caching layer later. Reply with the
finished code only.

```ts
export async function getPricingTable(region: Region): Promise<PricingRow[]> {
  const rows = await db.pricing.findMany({ where: { region } });
  return rows.map(toPricingRow);
}
```
