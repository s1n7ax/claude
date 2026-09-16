---
type: llm
weight: 2
---

The unexpected database failure is wrapped with `%w` (e.g.
`fmt.Errorf("get order %s: %w", id, err)`) so the underlying cause survives,
rather than being flattened into a new string like `errors.New("query failed")`.
