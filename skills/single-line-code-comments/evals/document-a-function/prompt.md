---
runs: 3
tags: [comments]
max_turns: 6
allowed_tools: [Skill]
---

Add comments to this so the next person picks it up quickly. Reply with the
finished code only.

```ts
export function priceWithTax(cents: number, region: Region): number {
  const rate = TAX_RATES[region] ?? TAX_RATES.default;
  const gross = Math.round(cents * (1 + rate));
  return gross % 5 === 0 ? gross : gross + (5 - (gross % 5));
}
```
