---
type: llm
weight: 2
---

Log calls pass a structured object of key/value fields (e.g.
`logger.error({ err, tenantId }, "invoice sync failed")`) rather than building
the message by string interpolation or concatenation.
