#!/usr/bin/env bash

# Don't block again if we are already inside a Stop-hook-triggered stop.
# Prevents the infinite loop fixed in #38 — keep this guard.
input=$(cat)
if [ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)" = "true" ]; then
  exit 0
fi

git rev-parse --git-dir >/dev/null 2>&1 || exit 0

branch=$(git branch --show-current 2>/dev/null)
[ -z "$branch" ] && exit 0

block() {
  msg="Unfinished task work on branch '$branch': $1. You MUST invoke the \`task\` skill NOW via the Skill tool and resume from its Commit stage"
  jq -nc --arg msg "$msg" '{decision: "block", reason: $msg}'
  exit 0
}

# --- Step 1: untracked files? (git diff doesn't see these) ---
[ -n "$(git ls-files --others --exclude-standard)" ] && block "untracked files in the working tree"

# --- Step 2: unstaged changes? ---
git diff --quiet || block "unstaged changes in the working tree"

# --- Step 3: staged but uncommitted changes? ---
git diff --quiet --staged || block "staged changes that are not committed"

# --- Step 4: committed but unpushed changes? ---
if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
  git diff --quiet '@{u}' HEAD || block "local commits that have not been pushed"
fi

# --- Step 5: non-default branch with no open PR? ---
default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|^refs/remotes/origin/||')
[ -z "$default_branch" ] && default_branch=main

if [ "$branch" != "$default_branch" ] &&
  ! git diff --quiet "origin/$default_branch"...HEAD 2>/dev/null; then
  remote_url=$(git remote get-url origin 2>/dev/null)
  if [[ "$remote_url" =~ github\.com[:/] ]] &&
    command -v gh >/dev/null 2>&1 &&
    gh auth status >/dev/null 2>&1; then
    gh pr view --json url >/dev/null 2>&1 || block "'$branch' has no open PR"
  fi
fi

exit 0
