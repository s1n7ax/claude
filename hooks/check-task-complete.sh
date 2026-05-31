#!/usr/bin/env bash
# Stop hook: block stop when task work on the current branch is unfinished.
# Allows stop when: not in a git repo, on main/master, or all checks pass.

cat >/dev/null

cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

branch=$(git branch --show-current 2>/dev/null)
[ -z "$branch" ] && exit 0
case "$branch" in
  main|master) exit 0 ;;
esac

block() {
  msg="Unfinished task work on branch '$branch'. Check the current state (uncommitted changes, unpushed commits, missing PR, etc.) and execute the remaining steps of the \`task\` skill from wherever you currently are in its pipeline. The user has authorized auto-commit, auto-push, and auto-PR creation — do not pause to confirm. Do not stop until the pipeline is complete."
  jq -nc --arg msg "$msg" '{decision: "block", reason: $msg}'
  exit 0
}

[ -n "$(git status --porcelain 2>/dev/null)" ] && block

git remote get-url origin >/dev/null 2>&1 || exit 0

git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1 || block
[ -n "$(git log '@{u}..HEAD' --oneline 2>/dev/null)" ] && block

remote_url=$(git remote get-url origin 2>/dev/null)
if [[ "$remote_url" =~ github\.com[:/] ]] \
   && command -v gh >/dev/null 2>&1 \
   && gh auth status >/dev/null 2>&1 \
   && gh repo view --json name >/dev/null 2>&1; then
  gh pr view --json url >/dev/null 2>&1 || block
fi

exit 0
