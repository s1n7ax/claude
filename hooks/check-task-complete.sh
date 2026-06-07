#!/usr/bin/env bash
# Stop hook: block stop when task work on the current branch is unfinished.
# Allows stop when: not in a git repo, on main/master, session made no edits,
# circuit breaker tripped (same stuck state repeated), or all checks pass.

payload=$(cat)

cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

branch=$(git branch --show-current 2>/dev/null)
[ -z "$branch" ] && exit 0

# --- 0. Did this session actually edit anything? ---
# If the assistant never called Edit/Write/MultiEdit/NotebookEdit in this
# transcript, treat it as a Q&A / casual session and let stop through —
# uncommitted changes are pre-existing, not this session's responsibility.
transcript_path=$(printf '%s' "$payload" | jq -r '.transcript_path // empty' 2>/dev/null)
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  if ! grep -Eq '"name"[[:space:]]*:[[:space:]]*"(Edit|Write|MultiEdit|NotebookEdit)"' "$transcript_path"; then
    exit 0
  fi
fi

# --- Circuit breaker state ---
git_dir=$(git rev-parse --git-dir 2>/dev/null)
state_file="$git_dir/claude-stop-hook-state"
# Hash of current "unfinished" state: branch + HEAD + status + upstream diff
state_hash=$(
  {
    echo "$branch"
    git rev-parse HEAD 2>/dev/null
    git status --porcelain 2>/dev/null
    git rev-parse '@{u}' 2>/dev/null
  } | sha1sum | awk '{print $1}'
)

block() {
  # Increment block counter for this state; if stuck (same state 3+ times), give up.
  prev_hash=""
  prev_count=0
  if [ -f "$state_file" ]; then
    prev_hash=$(awk 'NR==1' "$state_file")
    prev_count=$(awk 'NR==2' "$state_file")
    [ -z "$prev_count" ] && prev_count=0
  fi
  if [ "$prev_hash" = "$state_hash" ]; then
    count=$((prev_count + 1))
  else
    count=1
  fi
  printf '%s\n%s\n' "$state_hash" "$count" >"$state_file"

  if [ "$count" -ge 3 ]; then
    # Stuck — stop blocking so the user can intervene.
    exit 0
  fi

  msg="Unfinished task work on branch '$branch' (uncommitted changes, unpushed commits, or missing PR). You MUST invoke the \`task\` skill NOW via the Skill tool and let it drive the remaining pipeline to completion — do not ask the user what to do, do not propose options, do not commit to the default branch (the \`task\` skill + \`pull-request\` skill handle branching automatically). The user has pre-authorized auto-commit, auto-push, and auto-PR creation. Do not stop until the pipeline is complete."
  jq -nc --arg msg "$msg" '{decision: "block", reason: $msg}'
  exit 0
}

# Reset counter on success path below by removing state file at the end.

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

# Clean exit — clear circuit-breaker state.
rm -f "$state_file" 2>/dev/null
exit 0
