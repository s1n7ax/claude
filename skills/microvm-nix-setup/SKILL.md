---
name: microvm-nix-setup
description: Use when setting up a microVM with microvm.nix, adding/changing virtiofs shares, writing a `nix run .` runner, or debugging "Failed to connect to proj-vm-virtiofs-*.sock" / "Can't drop privilege as nonroot user" / EPERM-on-write-to-virtiofs-share errors. Covers standalone (non-systemd-host) usage where the user runs the VM directly.
---

# microvm.nix standalone setup

## The one thing to know first

`microvm.declaredRunner` ships **two separate binaries**, and `nix run .` (which by default points at `microvm-run`) only launches qemu. virtiofsd is in a different binary (`virtiofsd-run`). If `apps.default` points at `microvm-run` alone, qemu starts, looks for `proj-vm-virtiofs-*.sock` files in CWD, finds nothing live, and dies with:

```
microvm@<host>: -chardev socket,id=fs0,path=<host>-virtiofs-ro-store.sock:
Failed to connect to '<host>-virtiofs-ro-store.sock': No such file or directory
```

Symptoms feel intermittent — it happens to "work" whenever some other process (a stale virtiofsd from an earlier session, a hand-run script) happens to have left compatible sockets lying around.

## Why supervisord's `virtiofsd-run` is not the answer for standalone use

The shipped `bin/virtiofsd-run` is `exec supervisord --configuration <conf>`, and `<conf>` declares `[supervisord] user=root` (designed for the systemd host integration). Running it as a normal user gives:

```
Error: Can't drop privilege as nonroot user
```

Don't try to patch the config at runtime. Skip supervisord and spawn the per-share virtiofsd processes yourself — `config.microvm.shares` already has every field you need.

## Template: self-contained `apps.default` wrapper

Replace the default `apps.<system>.default = { program = "${runner}/bin/microvm-run"; }` with a wrapper that starts virtiofsd, runs qemu, and cleans up on exit. Sockets are **relative paths**, so virtiofsd and qemu must share CWD — the wrapper already does, since both run from wherever the user invoked `nix run .`.

```nix
apps.${system}.default =
  let
    pkgs = nixpkgs.legacyPackages.${system};
    lib = nixpkgs.lib;
    cfg = self.nixosConfigurations.<host>.config;
    runner = self.packages.${system}.<host>;
    virtiofsdBin = lib.getExe cfg.microvm.virtiofsd.package;
    virtiofsShares = builtins.filter ({ proto, ... }: proto == "virtiofs")
      cfg.microvm.shares;
    spawnVirtiofsd = lib.concatMapStrings (s: ''
      ${virtiofsdBin} \
        --socket-path=${lib.escapeShellArg s.socket} \
        --shared-dir=${lib.escapeShellArg s.source} \
        --sandbox=none \
        --cache=${s.cache} \
        --xattr \
        --translate-uid "map:1000:$(id -u):1" \
        --translate-gid "map:100:$(id -g):1" \
        ${lib.optionalString s.readOnly "--readonly "}&
      VFSD_PIDS+=($!)
    '') virtiofsShares;
    expectedSockets = builtins.length virtiofsShares;
    wrapper = pkgs.writeShellScriptBin "<host>-run" ''
      set -euo pipefail
      shopt -s nullglob

      VFSD_PIDS=()
      QEMU_PID=
      cleanup() {
        [ -n "$QEMU_PID" ] && kill "$QEMU_PID" 2>/dev/null || true
        for pid in "''${VFSD_PIDS[@]}"; do kill "$pid" 2>/dev/null || true; done
        for _ in $(seq 1 30); do
          alive=0
          [ -n "$QEMU_PID" ] && kill -0 "$QEMU_PID" 2>/dev/null && alive=1
          for pid in "''${VFSD_PIDS[@]}"; do
            kill -0 "$pid" 2>/dev/null && alive=1
          done
          [ "$alive" -eq 0 ] && break
          sleep 0.1
        done
        [ -n "$QEMU_PID" ] && kill -KILL "$QEMU_PID" 2>/dev/null || true
        for pid in "''${VFSD_PIDS[@]}"; do kill -KILL "$pid" 2>/dev/null || true; done
        rm -f <host>.sock <host>-virtiofs-*.sock <host>-virtiofs-*.sock.pid
      }
      trap cleanup EXIT INT TERM

      rm -f <host>.sock <host>-virtiofs-*.sock <host>-virtiofs-*.sock.pid

      ${spawnVirtiofsd}

      expected=${toString expectedSockets}
      for _ in $(seq 1 100); do
        socks=(<host>-virtiofs-*.sock)
        [ "''${#socks[@]}" -ge "$expected" ] && break
        sleep 0.1
      done

      ${runner}/bin/microvm-run &
      QEMU_PID=$!
      wait "$QEMU_PID"
    '';
  in
  { type = "app"; program = "${wrapper}/bin/<host>-run"; };
```

Replace `<host>` with the actual hostname (matches `networking.hostName` in the VM module, e.g. `proj-vm`).

## Why each wrapper detail matters — don't trim these

| Decision | Reason |
|---|---|
| `--sandbox=none` | Default `--sandbox=namespace` needs CAP_SYS_ADMIN or unprivileged user namespaces; spawning standalone as a normal user it fails silently or oddly. |
| `--translate-uid` / `--translate-gid` | Without these, virtiofsd needs `CAP_SETUID`/`CAP_SETGID` to `setresuid/setresgid` to the guest caller's identity for each op. As a normal user it can't, and any guest user whose uid/gid doesn't match virtiofsd's gets EPERM on every write — even though the host dir grants the right perms and the share mounts `rw`. NixOS's default `isNormalUser` puts the guest user in gid `users` (100), but the host `s1n7ax` typically has a per-user gid like 992. The `map:1000:$(id -u):1` / `map:100:$(id -g):1` form makes the wrapper portable: it derives the host ids from the user actually running `nix run .`. Root in the guest is unaffected (different code path), which is the diagnostic tell. |
| No `--socket-group=...` | microvm.nix sets `kvm` by default. If the user isn't in the `kvm` group, virtiofsd can't chgrp the socket and exits. The current user owns the socket anyway; qemu (same user) can read it. |
| `&` + `wait` (NOT `exec`) | `exec` replaces the bash with qemu — no trap, virtiofsd children orphan. With `&` + `wait`, bash stays alive; `wait` is interruptible by signals so SIGTERM fires the trap. |
| Foreground bash defers signals | Without `&`, bash queues signals until the foreground command exits. `wait` does not defer — that's the only reason this works. |
| Clean `.sock` AND `.sock.pid` | virtiofsd creates `<socket>.pid` and flock's it. Old `.pid` files (even with no live owner) sometimes report EAGAIN on re-creation. Always clean both at start and on exit. |
| TERM-then-KILL loop | qemu sometimes ignores TERM until the guest stops; we give 3s grace then KILL. |
| Compute `expected` from `microvm.shares` | Don't hardcode the share count — if someone adds a share, the wrapper still waits for the right number of sockets. |

## Clean shutdown: use the QMP socket, not Ctrl-C

`microvm.declaredRunner` adds `-qmp unix:<host>.sock,server,nowait` to the qemu args, so QEMU is always listening for QMP on `<host>.sock` next to the virtiofs sockets. Use this for shutdown.

Ctrl-C in the wrapper sends SIGINT, which trips the trap and `kill`s qemu with SIGTERM. qemu exits hard, leaving virtiofsd to log a stream of cosmetic errors as the vhost-user socket disappears under it:

```
vhost VQ 0 ring restore failed: -22: Invalid argument (22)
Failed to read msg header. Read -1 instead of 12.
set virtio-user-fs status to 15 failed, old status: 15
```

Nothing on the host or in the shares is corrupted — but the noise looks alarming and obscures real problems. The fix is ACPI shutdown via QMP: qemu does an orderly exit, virtiofsd sees a clean disconnect.

Stop script template (depends only on `socat`, fetched on demand via `nix shell`):

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

SOCK=<host>.sock

find_qemu_pid() {
  ps -eo pid,cmd --no-headers | awk '/-name <host>/ && !/awk/ { print $1; exit }'
}

QEMU_PID=$(find_qemu_pid)
if [ -z "$QEMU_PID" ]; then
  echo "<host> doesn't appear to be running."
  exit 0
fi

if [ -S "$SOCK" ]; then
  {
    printf '{"execute":"qmp_capabilities"}\n'
    printf '{"execute":"system_powerdown"}\n'
    sleep 1
  } | nix shell nixpkgs#socat --command socat - "UNIX-CONNECT:$SOCK" >/dev/null 2>&1 || true
else
  echo "QMP socket missing; sending SIGTERM to qemu pid $QEMU_PID."
  kill -TERM "$QEMU_PID" 2>/dev/null || true
fi

for _ in $(seq 1 60); do
  kill -0 "$QEMU_PID" 2>/dev/null || { echo "stopped cleanly."; exit 0; }
  sleep 0.5
done

kill -TERM "$QEMU_PID" 2>/dev/null || true
sleep 2
kill -0 "$QEMU_PID" 2>/dev/null && kill -KILL "$QEMU_PID" 2>/dev/null || true
```

Two non-obvious decisions in there — don't simplify them away:

- **Detect qemu by `-name <host>` in the cmdline, not `pgrep -f 'qemu.*<host>'`.** qemu's `argv[0]` is renamed to `microvm@<host>` (via `exec -a`) and the cmdline contains no literal `qemu` substring anywhere. A `qemu.*<host>` pattern always matches nothing, so the script will falsely report "stopped cleanly" the moment it polls — leaving qemu running. Matching on `-name <host>` (the qemu argument) is reliable. `pidof qemu-system-x86_64` also works (reads `/proc/PID/exe`) but isn't VM-scoped if you run more than one.
- **Don't equate "QMP socket missing" with "VM not running".** The QMP socket can vanish while qemu is alive (a second `nix run .` invocation does `rm -f <host>.sock <host>-virtiofs-*.sock` at startup, then fails to bind the SSH-forward port and exits — orphaning the first VM's socket). Find qemu by PID first; treat the QMP socket as the *preferred* shutdown channel, with SIGTERM-by-PID as the fallback.

The wrapper's existing trap still runs once `wait` returns, so virtiofsd is cleaned up normally — just without the vhost-error spam.

Don't try to make the wrapper itself do the QMP dance on SIGINT — the wrapper has no separate path to talk to qemu before killing it. Drive shutdown from outside (a sibling script, a VS Code task, etc.) and the wrapper just observes qemu exiting on its own.

## What sockets look like while the VM is running

After boot, expect to see in CWD:

- `<host>.sock` — the QMP listener, held by qemu for its lifetime.
- `<host>-virtiofs-*.sock.pid` — one per virtiofs share, flock'd by each virtiofsd.

You will **not** see `<host>-virtiofs-*.sock` (without `.pid`). virtiofsd unlinks the listening socket after qemu completes the vhost-user handshake — vhost-user is single-connection, so the listener has nothing left to do. The FDs stay open inside the processes (`ls -la /proc/$pid/fd | grep socket`), just nameless. This is normal; don't go hunting for a phantom bug. If `<host>.sock` is also missing while qemu is alive, *that's* the real anomaly (see the stop-script bullet above).

## Nested virtiofs mounts

If you mount a subdirectory as its own share (e.g. `~/.claude` → `nix/claude` AND `~/.claude/skills` → `~/.claude/skills`), the **mount point inside the parent source must exist on the host**. The VM cannot create it inside a read-only mount during boot — it will fail with "Failed to mount X" and drop into emergency mode.

Fix: create the empty directory in the parent source (e.g. `mkdir -p nix/claude/skills && touch nix/claude/skills/.gitkeep`).

## Symptom → fix checklist

| Symptom | Likely cause |
|---|---|
| `Failed to connect to <host>-virtiofs-*.sock` | virtiofsd never started — wrapper isn't bundling it, or `apps.default` still points at bare `microvm-run`. |
| `Can't drop privilege as nonroot user` | You invoked `virtiofsd-run` (supervisord-based) as a non-root user. Skip supervisord, spawn per-share virtiofsd directly. |
| `Error creating pid file '...sock.pid': Resource temporarily unavailable` | Stale `.sock.pid` from prior run, OR previous virtiofsd still alive holding the flock. Clean files; check for zombie virtiofsd processes (often surviving because qemu uses `exec -a microvm@<host>` and `pkill -f qemu` misses it — use `pidof qemu-system-x86_64` or kill by PID). |
| `Failed to mount /path/to/nested-mount` → emergency mode | The nested mount point doesn't exist in the parent share's source on the host. Create the empty dir host-side. |
| EPERM on `mkdir`/`touch`/write inside a virtiofs share as a non-root guest user (root in the guest works, share mounts `rw`, host perms look correct) | virtiofsd is running without `CAP_SETUID`/`CAP_SETGID` and can't impersonate the guest caller because guest gid (e.g. `users`=100) ≠ virtiofsd's host gid (e.g. `s1n7ax`=992). Add `--translate-uid "map:1000:$(id -u):1"` and `--translate-gid "map:100:$(id -g):1"` to the virtiofsd args in the wrapper. Verify in-guest with `stat <path>` — guest gid showing as `UNKNOWN` is the smoking gun. |
| Port forward error: `Could not set up host forwarding rule 'tcp::<port>-:22'` | Previous qemu still holding the port. `ss -tlnp \| grep <port>` to find the PID. |
| Wrapper survives but virtiofsd zombies remain after Ctrl-C | Wrapper used `exec` to launch qemu, so the trap never fires. Switch to `&` + `wait`. |
| Shutdown logs flood with `vhost VQ ring restore failed: -22` / `Failed to read msg header` / `set virtio-user-fs status to 15 failed` | Cosmetic. qemu was killed (SIGTERM/SIGINT) before virtiofsd could finish the vhost-user handshake. Use ACPI shutdown via QMP at `<host>.sock` (`system_powerdown`) instead of Ctrl-C. See "Clean shutdown" section. |
| Stop script says "VM not running" but qemu is in fact alive | Either (a) script uses `pgrep -f 'qemu.*<host>'`, which never matches because qemu's `argv[0]` is `microvm@<host>` and the cmdline has no `qemu` substring, or (b) script treats a missing QMP socket as "not running" and bails. Fix both: detect qemu via `ps -eo pid,cmd \| awk '/-name <host>/ {print $1; exit}'` (or `pidof qemu-system-x86_64`), and fall back to SIGTERM-by-PID when the QMP socket is missing. See "Clean shutdown" stop-script template. |
| `<host>-virtiofs-*.sock` files missing while VM is running (only `.sock.pid` present) | Normal — virtiofsd unlinks the vhost-user listener after qemu connects (single-connection protocol). Don't recreate them; don't panic. `<host>.sock` (QMP) should still be there. |

## Diagnosing a stuck environment

```bash
ps --forest -ef | grep -E 'virtiofsd|microvm@'   # zombie processes — qemu shows as `microvm@<host>`, not `qemu`
ss -tlnp | grep ':22'                            # who holds the forwarded SSH port
pidof qemu-system-x86_64                         # finds qemu despite the renamed argv[0]
ls -la *-virtiofs-*.sock*                        # leftover sockets / pid files
```

When killing zombies, prefer kill by PID over `pkill -f` — qemu's renamed `argv[0]` (e.g. `microvm@proj-vm`) bypasses most `-f` patterns that look for "qemu".

## Verification after changes

After editing the flake or VM config, run end-to-end at least once:

```bash
nix flake check --no-build
nix run . > /tmp/vm-boot.log 2>&1 &
sleep 15 && grep -E 'Failed to mount|emergency|login:' /tmp/vm-boot.log
# ssh into the VM and `mount | grep virtiofs` to confirm every share is present
kill -TERM <wrapper-pid>
# confirm no leftover sockets/pid files and no remaining virtiofsd/qemu
```

Two back-to-back boots is the best smoke test — it confirms cleanup is sound.
