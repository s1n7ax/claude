---
name: nvim-headless-test
description: Use when modifying Neovim Lua configuration that affects window management, autocmds, buffer behavior, statusline, or any UI-observable behavior — and when debugging why an autocmd or window event fires unexpectedly. Runs the real config in a headless nvim so assertions reflect actual behavior.
---

# Neovim Headless Testing

## How to run

```bash
nvim --headless -u init.lua -c "luafile test_file.lua" 2>&1
```
