---
type: llm
weight: 2
---

Every log call passes a structured object of key/value fields as the first
argument (e.g. `logger.info({ userId, orderId }, "order placed")`).

Fail this if any log message is assembled by string interpolation or
concatenation (e.g. `logger.info(`order ${id} placed`)`).
