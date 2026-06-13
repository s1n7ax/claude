---
name: task
description: Use whenever the user invokes `/task`, says "let's work on <something>", pastes a project-management ticket URL (GitHub issue, Jira, Linear, etc.) as the work to do, or otherwise asks to start a new piece of coding work end-to-end. Drives a coding task through a fixed pipeline — understand the requirement, plan, ticket, branch, implement, test via end-user API, commit, PR, review — running autonomously without pausing for user confirmation between stages. Use this even when the user does not say the word "task"; if they are framing the next chunk of work, this skill applies.
---

# Task workflow

Drive a coding task through the stages below in order. Run autonomously end-to-end — do not pause for user confirmation between stages. Skip a stage only when it is genuinely not applicable (e.g. a ticket already exists); note the skip and the reason and continue.

The input the user gave you may be a description, a ticket URL, or a vague phrase. Treat all three the same — start at the Understand stage.

You are pairing with a senior engineer. Be terse, do not lecture.

## Understand the requirement

Understand the **end-user requirement**, not the list of code changes the input happens to mention. Tickets and users routinely describe a proposed solution; recover the underlying problem so you can choose a better approach if one exists.

If the input is a ticket URL, fetch the details in this order:

1. A relevant MCP
2. A supported CLI
3. `WebFetch` on the URL as a last resort

Read the ticket body, comments, and linked context.

Restate the requirement in your own words — one short paragraph — and record it so later stages can refer back. Commit to your reading and proceed; do not ask the user to confirm.

## Explore the code and plan

Read the relevant code first. Do not plan on guesses about the codebase.

Generate candidate solutions internally, sorted most-recommended first. Pick the best one and record the plan: concrete files, functions, behaviour. If any part is genuinely fuzzy, note the uncertainty and pick the safer option.

## Ticket

If a ticket already exists for this work, skip.

Otherwise create one. To pick the project-management tool, check in order:

1. Per-project memory: `~/.claude/projects/<project-slug>/memory/project-management.md`
2. If missing and the repo has a GitHub remote, default to GitHub Issues. Write the default to the memory file so future invocations remember.

The memory file should be tiny — tool name and identifiers. Example:

```
Tool: GitHub Issues
Repo: s1n7ax/nixos
```

Create the ticket via MCP > CLI > web (same fallback as the Understand stage). Capture the ticket ID and URL.

## Branch

Branch from the **latest** default branch:

```
git fetch origin
git checkout <default-branch>
git pull --ff-only
git checkout -b <ticket-id>-<short-kebab-description>
```

Branch name: `<ticket-id>-<short-kebab-description>` (e.g. `PROJ-123-add-force-flag`, `gh-42-fix-login-redirect`).

If the current branch was clearly created for this same ticket (matches the ticket ID, or clearly describes the same work), reuse it instead of branching fresh.

If the working tree is dirty, stash with a descriptive label and continue:

```
git stash push -u -m "task: pre-branch <ticket-id>"
```

## Implement

Make the changes per the plan. Read before editing, keep changes scoped to the plan.

If the plan turns out to be wrong mid-implementation, pivot to the next-best option from the Plan stage and continue. Note the deviation and its reason in the eventual PR description.

## Test via the end-user API

Use the **`end-user-test`** skill.

## Commit

Use the **`git-commit`** skill.

## Pull request

Use the **`pull-request`** skill.

## Review

Use the **`post-review`** skill.
