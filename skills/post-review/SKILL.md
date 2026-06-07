---
name: post-review
description: Use whenever the user asks to review a PR, post review comments on a PR, run `/review` against a PR, or invokes this from the `task` skill's Review stage. Runs Claude Code's built-in `/review`, then publishes each finding as an INLINE GitHub review comment anchored to the relevant file and line — not as one bundled top-level comment.
---

Run `/review`. For each finding, post it as an inline PR review comment anchored to the file and line (or hunk) it's actually about — use `gh api .../pulls/<n>/reviews` with `event: COMMENT` and a `comments[]` array, not `gh pr comment`.
