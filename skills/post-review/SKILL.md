---
name: post-review
description: Use whenever the user asks to review a PR, post review comments on a PR, run `/review` against a PR, or invokes this from the `task` skill's Review stage. Also use proactively after opening a PR if a review is expected. Runs Claude Code's built-in `/review` against the current branch's PR, then publishes each finding as an INLINE GitHub review comment anchored to the exact file and line — not as one fat top-level comment. Findings that can't be anchored go in the review body so nothing is lost.
---

# Post review comments on a PR

The goal is a PR review that reads like a careful human did it: each finding sits next to the code it's about, on the right file and line, so the author can respond inline. GitHub's "submit one giant review comment with everything in it" is the default failure mode and is what this skill exists to avoid.

## Inputs

- **PR**: default to the open PR for the current branch (`gh pr view --json number,baseRefName,headRefOid,url`). If there is no PR, stop and tell the user.
- **Review source**: Claude Code's built-in `/review` slash command output.

## Workflow

### 1. Identify the PR and its diff

```
gh pr view --json number,baseRefName,headRefOid,url,headRefName
gh pr diff <number>                       # unified diff
gh api repos/{owner}/{repo}/pulls/<number>/files --paginate  # per-file diffs
```

Hold onto the head commit SHA and the per-file diff hunks. You'll need them to validate that each finding's line is actually part of the diff — GitHub will reject inline comments on lines outside the diff range.

### 2. Run the review

Invoke `/review`. Treat its output as the raw set of findings. Do not post it verbatim; you're going to restructure it.

### 3. Structure the findings

For each finding, extract:

- `path`: file path relative to repo root
- `line`: the line number on the **new** version of the file (RIGHT side). For findings about removed code, use the **old** line and `side: LEFT`.
- `start_line` (optional): if the finding spans multiple lines, set the range
- `body`: the comment itself — short, concrete, actionable. One finding per comment.
- `severity` (internal, for sorting/filtering): blocking / suggestion / nit

Drop pure restatements ("this function does X"), tautological style nits, and anything you can't tie to a concrete change.

### 4. Anchor each finding to the diff

For every finding, check the per-file diff hunks: is `line` (with the right `side`) inside a hunk that this PR touches?

- **In the diff** → goes in `comments[]` as an inline comment.
- **Not in the diff** but clearly about a specific file → put it in the review body under a `## Notes on <file>` section.
- **Not about any specific file** (architectural, high-level) → put it in the review body summary.

This is the key rule: never silently drop a finding because it can't be anchored. Demote it to the body instead.

### 5. Submit one review with inline comments

Use the Reviews API, not `gh pr comment` (which only creates issue-style top-level comments) and not `gh pr review --comment --body` (which posts a single body without inline anchors).

```
gh api \
  --method POST \
  repos/{owner}/{repo}/pulls/<number>/reviews \
  -f event=COMMENT \
  -f body="<top-level summary + unanchored findings>" \
  -f commit_id=<headRefOid> \
  --input <(jq -n --argjson comments "$COMMENTS_JSON" '{comments: $comments}')
```

Where each entry in `comments` looks like:

```json
{
  "path": "src/auth/login.ts",
  "line": 42,
  "side": "RIGHT",
  "body": "This swallows the error from `verifyToken`; the caller will see success even when the token is invalid."
}
```

For a multi-line range, add `start_line` and `start_side`. For a comment on removed code, use `side: "LEFT"` and the pre-change line number.

Pass `event: COMMENT` (not `APPROVE` or `REQUEST_CHANGES`) unless the user explicitly asked for an approval/blocking review. The skill's job is to surface findings, not to gate the PR.

### 6. Body format

The top-level `body` should be terse. Suggested template:

```
## Review summary
<1–3 sentences: what this PR does well, what the main concerns are.>

## General notes
<bullets — architectural or cross-file findings that don't anchor to a line.>

## Notes on <path/to/file>
<bullets — file-scoped findings that don't anchor to a specific line in the diff.>
```

Skip any section that has no content. If there are no unanchored findings at all, the body is just the summary.

## Why the structure matters

Inline comments make findings actionable — the author can reply in context, mark them resolved, and reviewers can see threads next to the code. A single bundled comment makes findings impossible to triage and impossible to respond to without manually quoting lines back. That's the whole reason for doing this.

## Failure modes to avoid

- **Don't post via `gh pr comment`** — that creates an issue comment on the PR, not a review, and it can't be anchored to lines.
- **Don't use `gh pr review --comment --body "..."`** for the findings — it posts the body without inline comments.
- **Don't guess line numbers** from the review text. If `/review` quoted a snippet but didn't give a line, grep the file for the snippet and use the actual line number. If you still can't pin it, demote to the body.
- **Don't post a comment on a line outside the diff** — the API will reject the whole review. Validate before submitting.
- **Don't approve or request changes** unless the user explicitly asked. `event: COMMENT`.
- **One finding per inline comment.** Don't bundle multiple unrelated findings into one comment just because they're in the same file.
