#!/usr/bin/env bash
# Stop hook: block stop when task work on the current branch is unfinished.
# Allows stop when: not in a git repo, on main/master, or all checks pass.

input=$(cat)

# Already looping from a previous block? Don't block again. -> avoid infinite loop
if [ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)" = "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

branch=$(git branch --show-current 2>/dev/null)
[ -z "$branch" ] && exit 0

# IMPORTANT: Do NOT add an exit-on-main/master branch here. This hook is meant
# to enforce on main/master too. The infinite-loop bug was fixed by the
# stop_hook_active guard above, not by skipping main/master. Leave this as-is.

block() {
  msg="Unfinished task work on branch '$branch' (uncommitted changes, unpushed commits, or missing PR). You MUST invoke the \`task\` skill NOW via the Skill tool and let it drive the remaining pipeline to completion — do not ask the user what to do, do not propose options, do not commit to the default branch (the \`task\` skill + \`pull-request\` skill handle branching automatically). The user has pre-authorized auto-commit, auto-push, and auto-PR creation. Do not stop until the pipeline is complete."
  jq -nc --arg msg "$msg" '{decision: "block", reason: $msg}'
  exit 0
}

# --- 1. Staged or unstaged changes? -> block ---
git diff --quiet || block
git diff --quiet --staged || block

# --- 2. Unpushed commits? -> block ---
if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
  git diff --quiet '@{u}' HEAD || block
fi

# --- 3. Branch differs from default branch but has no PR? -> block ---
default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|^refs/remotes/origin/||')
[ -z "$default_branch" ] && default_branch=main

if ! git diff --quiet "origin/$default_branch"...HEAD 2>/dev/null; then
  remote_url=$(git remote get-url origin 2>/dev/null)
  if [[ "$remote_url" =~ github\.com[:/] ]] \
     && command -v gh >/dev/null 2>&1 \
     && gh auth status >/dev/null 2>&1; then
    gh pr view --json url >/dev/null 2>&1 || block
  fi
fi

exit 0
