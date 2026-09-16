---
type: llm
weight: 3
---

The TODO is tied to a tracked issue rather than left floating. Any of these
pass:

- it carries a real GitHub / Jira / Linear issue URL
- the response created the issue and referenced it
- the response asked the user for the issue link, or left a clearly-marked
  placeholder URL for the user to fill in

Fail this only if a bare TODO was left with no issue reference and no mention
of tracking it.
