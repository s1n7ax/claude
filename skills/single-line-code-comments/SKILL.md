---
name: single-line-code-comments
description: Use whenever adding, editing, or asked to write comments in code. This project forbids inline single-line comments (`//`, `#`, `--`) — only doc comments (`/** */`, docstrings, `///`) are permitted.
---

# Comment Policy

## Rule

Do not add single-line comments (`//`, `#`, `--`, etc.). Only doc comments (`/** */`, `"""..."""`, `///`, or the language equivalent) are allowed.

## Why

Single-line comments tend to accumulate as stale narration of what the next line does ("increment counter", "loop over items"). They decay quickly as code changes and rarely carry information the code itself doesn't already express. Doc comments, by contrast, describe contracts and intent at API boundaries — callers depend on them, so they stay maintained.

## How to apply

- If logic genuinely isn't self-evident, extract a well-named function or variable instead of commenting.
- If context is required (a non-obvious workaround, a link to an issue), put it in the doc comment on the enclosing function or type.
- `TODO:` markers follow the `todo-comments` skill and use doc-comment form there as well.

## Languages without doc-comment syntax

Shell, YAML, Dockerfile, TOML, `.env` and similar have only `#`. The spirit of the rule still applies: don't narrate the next line. Reserve `#` for header blocks at the top of a file or section, or to document a non-obvious choice (e.g. a flag, a workaround). If you find yourself writing inline `#` to explain what a line does, rename the variable / restructure the file instead.
