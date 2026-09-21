# Skill ablation evals

Every skill in this directory has an `evals/` suite. Each case runs twice —
once with the skill loaded, once without — and the harness reports the score
delta.

**The delta is the whole point.** A skill earns its place only if the
with-skill arm scores meaningfully higher than the baseline. A delta at or
near `0.00` means the base model already behaves the way the skill says, and
the skill is dead weight: delete it.

## Running

```bash
skills/run-evals.sh                 # every skill
skills/run-evals.sh todo-comments   # one skill
```

Raw JSON lands in `<skill>/evals/results/latest.json`, a browsable HTML report
in `<skill>/evals/results/<timestamp>/report.html`. Results are gitignored.

## Reading the output

```
CASE                WITH  W/OUT Δ      RUNS COST
use-project-logger  1.00  1.00  0.00   6    $0.45
```

- `Δ ≥ ~0.15` — the skill is doing real work. Keep it.
- `Δ ≈ 0.00` with both arms high — the model already does this. Delete the skill.
- `Δ ≈ 0.00` with both arms low — either the skill isn't landing, or the
  graders are testing something the skill never asked for. Read the failing
  grader before concluding anything.

Each case also carries a `skill-fired` grader marked `arm: with-only`. It is
not scored; it only confirms the skill actually triggered in the with arm. If
it fails, the case is measuring nothing — fix the skill's `description` before
reading the delta.

## Last measured (2026-09-16, claude-sonnet-5, 3 runs per arm)

| Skill | with | without | Δ | verdict |
|---|---|---|---|---|
| todo-comments | 0.69 | 0.00 | **+0.69** | keep |
| ~~single-line-code-comments~~ | 0.94 | 0.38 | +0.56 | **deleted** |
| error-handling | 0.91 | 0.49 | **+0.42** | keep |
| git-commit | 0.84 | 0.48 | **+0.35** | keep |
| ~~logging~~ | 0.97 | 0.85 | +0.11 | **deleted** |

`logging` was removed on the strength of this run: the baseline already reached
for the project's configured logger and structured fields without being told,
so the skill was only worth 0.11 of a mostly-already-passing score.

`single-line-code-comments` was removed later for a different reason — not the
numbers, which were strong, but the policy itself: a blanket ban on `//` and `#`
was more rule than this project wants to carry.

## Layout

```
skills/<name>/evals/<case>/prompt.md       # frontmatter = execution config, body = the prompt
skills/<name>/evals/<case>/graders/*.md    # frontmatter = grader config, body = criteria
```

Grader types in use: `regex` (deterministic text checks), `llm` (judged
criteria, 3 votes), `tool_used` (did a tool fire).

## Requirements

`claude plugin eval` is in early access. It's switched on for this machine via
`env.CLAUDE_CODE_WALNUT_SPIRE=1` in `settings.json`; `run-evals.sh` also
exports it.

## Known limitation

Cases here are text-only — the model is asked for finished code in its reply
rather than being given `Write`/`Bash` against a scaffolded repo. The eval
sandbox runs `Bash` through `bwrap`, which is not on the sandbox's `PATH` on
this NixOS box, so every `Bash` call fails with `bwrap: command not found`.

This mainly costs coverage on `git-commit`: its "do not modify the codebase"
rule can't be observed without letting the agent loose in a real repo. The two
rules that *are* covered — conventional-commit subject lines and asking before
splitting unrelated changes — are the ones most likely to differentiate it.
