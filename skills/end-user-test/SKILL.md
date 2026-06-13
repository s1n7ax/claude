---
name: end-user-test
description: Use to validate a code change by exercising it through the end-user API rather than via internal helpers — real HTTP requests, real browser interaction, real CLI invocations, real library imports, real config application. Invoked from the `task` skill after Implement, but also use whenever the user asks to test/validate/verify a change end-to-end.
---

# Test via the end-user API

Theme: exercise the change the way the end user would, not via internal helpers.

- HTTP backend: start the app, send real HTTP requests (`curl`, `httpie`, etc.) against the endpoint
- Frontend: drive the UI via the browser and validate in the browser. If the project has Storybook (or similar component sandbox), prefer running that over the full app — it's faster and isolates the component under test.
- CLI tool: run the built binary with real arguments
- Library: call the public exported API from a small script
- Infra/config: apply the config to a real (or local) target and verify the observable effect

Also run the project's existing test suite.

If anything fails: fix, retest, repeat. Do not move on with failing tests.

## Record the results

Capture evidence that the change actually works so later stages (PR description, review, future tasks) can cite it instead of re-running everything.

Write to `.claude/test-results/<ticket-id>.md` in the repo root (create the directory if missing). One file per ticket, appended on each test run.

Each entry should include:

- UTC timestamp and the commit SHA tested
- What was exercised (endpoint, UI flow, CLI command, script) and the exact command(s)
- Observed output — request/response bodies, screenshots/links, log excerpts, exit codes
- Test-suite invocation and pass/fail summary
- Verdict: pass / fail / partial, with a one-line reason

Keep entries terse — the goal is reproducible proof, not narrative. Link to screenshots or large logs rather than inlining them.

If no ticket ID is available, use the branch name as the filename.
