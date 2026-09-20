---
type: llm
weight: 3
---

The result is written back into issue #42 itself: a comment on #42 with what was
done, and the matching checklist line ticked in the body (ideally linked to that
comment).

Fail this if the response opens a new issue for the step, writes the result to a
separate file or document as the record of it, or reports only in chat with
nothing going back to #42. A pull request that references #42 alongside the
comment is fine.
