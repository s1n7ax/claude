---
type: llm
weight: 3
---

The TODO is written as a doc comment (`/** ... */`) and is backed by an issue
tracker: it carries a GitHub / Jira / Linear issue URL, or the response created
the issue, or the response explicitly asked the user for the issue link /
placed a clearly-marked placeholder URL to be filled in.

Fail this if a bare untracked TODO was left with no issue reference at all.
