---
type: llm
weight: 3
---

The code defines named, reusable error values or types — package-level
sentinels (`var ErrOrderNotFound = errors.New("order not found")`) or a struct
implementing `error` — instead of constructing an anonymous
`errors.New("...")` at each return site.
