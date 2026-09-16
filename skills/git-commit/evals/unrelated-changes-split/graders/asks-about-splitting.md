---
type: llm
weight: 4
---

The response notices that the staged work spans three unrelated concerns (a
README typo, a cart subtotal bug fix, and new retry/backoff behaviour) and
*asks the user* whether to split them into separate commits.

Fail this if the response instead:
- hands back a single commit message covering all three, or
- hands back three separate commit messages as a decided plan without asking.

Asking and then offering the split messages conditionally ("if you want to
split, here's what I'd use") passes.
