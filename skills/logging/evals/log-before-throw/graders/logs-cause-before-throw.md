---
type: llm
weight: 3
---

Inside the `catch` block the original `cause` is logged *before* the wrapping
`InvoiceSyncError` is thrown, so the underlying failure is not erased by the
wrap.

Fail this if the catch block throws without logging, or logs only the new
wrapper message without the original error.
