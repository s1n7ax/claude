---
type: llm
weight: 4
---

Exactly **one** issue is produced, and it holds the whole roadmap.

Fail this if the response creates or proposes more than one issue — an epic plus
child issues, one ticket per step, a separate "spec" issue, or a parent issue
with sub-issues to be filed next. Mentioning that pull requests will later link
back to this one issue is fine and still passes.
