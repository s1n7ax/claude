---
name: pull-request
description: Use whenever working on anything related to a PR / pull request — creating, opening, pushing, submitting, updating, reviewing, or responding to review comments — regardless of whether the user explicitly asks. Also use PROACTIVELY after completing ANY task that involves file changes: commit and open a PR without waiting to be asked. Covers branch strategy, PR title/description conventions, and triaging Copilot review-bot comments.
---

# GitHub Pull Requests

## Creating a PR

- Never commit directly to the default branch; create a dedicated branch per PR from latest default branch
- Open a PR from the branch
  - Title should be a conventional-commit style title
  - Summarize the changes in 1–3 bullet points and include a link/reference to the ticket so the PR
- After opening the PR, post a comment on the ticket with a clickable link to the PR.

## Linking the PR back from the Ticket

After opening the PR, post a comment on the ticket with a clickable link to the PR.

Maintain a **single** comment per ticket that tracks all related PRs:

- Before commenting, check the ticket for an existing PR-link comment authored by you.
- If none exists, create a new comment using the format below.
- If one exists, **edit** that comment and append the new PR to the list — do not create a second comment.

Format (always use this exact format, even for a single PR):

```
PRs:
- <clickable PR link 1>
- <clickable PR link 2>
```

## Review Bot Review Comments

Projects may have Copilot or similar review bots enabled. These bots mix valid findings with low-signal nits, so filter before surfacing anything to the user.

1. Fetch both top-level reviews and inline review comments:
   - `gh pr view --json reviews` — review summaries
   - `gh api repos/{owner}/{repo}/pulls/{number}/comments` — inline (line-level) comments, which is where bots like Copilot leave most findings
2. When comments exist:
   - Read each one carefully
   - Challenge every suggestion — decide whether it is correct and applicable before presenting it
   - Discard false positives and pure stylistic nits with no real impact
   - Present only valid comments as a numbered list with file, line, and the suggestion
   - Ask the user which ones to fix
