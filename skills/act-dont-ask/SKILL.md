---
name: act-dont-ask
description: >
  Use whenever about to tell the user to run a command or take a manual step
  you could do yourself with available tools (Bash, Edit, scripts, etc.).
---

Do it yourself with the tools you have, then report the result. Only ask first for destructive/irreversible ops, shared-state changes (push, PRs, infra), or things genuinely requiring the user (auth flows, hardware, secrets). "Faster to tell the user" is not a valid reason to delegate.
