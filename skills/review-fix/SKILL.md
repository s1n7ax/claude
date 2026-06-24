---
name: review-fix
description: Use when the user invokes `/review-fix` to work through a pull request's review feedback.
---

# review-fix

1. Resolve the PR for the current branch (or the one the user named); stop if none. Skip resolved/outdated.
2. Triage each against the actual code — challenge every suggestion — into **valid**, **unclear**, or **ignored** (wrong/nit; record a one-line reason).
3. For each **unclear** one, grill the user: `grill-me` for a one-off ambiguity, `grill-with-docs` when it forces a documentable design decision. Then it lands in valid or ignored.
4. List **valid** changes ordered by criticality (file:line + why); list **ignored** ones with their reasons.
5. Reply briefly on the PR to each **ignored** comment explaining the skip
6. Present the valid changes via **AskUserQuestion** (multiSelect; split across questions by priority tier if more than 4).
7. Hand the selected changes to the **`task`** skill in one pass — it reuses the existing ticket/branch/PR.
