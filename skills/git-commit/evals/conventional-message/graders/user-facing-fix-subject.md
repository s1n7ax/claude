---
type: llm
weight: 3
---

The subject line is a `fix:` and describes the bug from the user's point of
view — line items with a quantity above 1 were undercharged / the cart total
ignored quantity.

Fail this if the subject only restates the implementation change ("multiply
priceCents by qty", "update reduce callback", "change subtotal function").
