#!/usr/bin/env bash
# Ablation harness for the local skills in this directory.
#
# Each case is scored twice: once with the skill loaded, once without it.
# The delta is what the skill is worth. A delta at or near 0.00 means the base
# model already does what the skill says, so the skill can be deleted.
#
# Usage: skills/run-evals.sh [skill-name ...]     (default: every skill with evals/)
set -euo pipefail

export CLAUDE_CODE_WALNUT_SPIRE=1

SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

targets=("$@")
if [ ${#targets[@]} -eq 0 ]; then
  targets=()
  for d in "$SKILLS_DIR"/*/evals; do
    [ -d "$d" ] && targets+=("$(basename "$(dirname "$d")")")
  done
fi

for name in "${targets[@]}"; do
  echo
  echo "=== $name ==="
  claude plugin eval "$SKILLS_DIR/$name" \
    --ablation with-without \
    --no-publish \
    --threshold 0 \
    --json "$SKILLS_DIR/$name/evals/results/latest.json"
done
