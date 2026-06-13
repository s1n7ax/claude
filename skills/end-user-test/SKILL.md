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

## Attach the proofs to the ticket

Upload the test proofs — logs, screenshots, command output, whatever you produced — as a comment on the ticket. If no ticket exists, post on the PR instead.

The form of the proof doesn't matter; what matters is that it lands on the ticket or PR so reviewers can see it without checking out the branch.
