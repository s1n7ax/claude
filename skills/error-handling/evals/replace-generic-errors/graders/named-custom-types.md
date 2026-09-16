---
type: llm
weight: 3
---

The code defines named error classes that extend `Error` (or a shared base
error class) and throws those instead of the generic `Error`.

The class names describe the failure mode — e.g. `ValidationError`,
`NotFoundError`, `UserDeactivatedError` — not the layer or module
(`ServiceError`, `UserError`, `DbError` would fail this).
