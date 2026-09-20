---
runs: 3
tags: [planning]
max_turns: 8
allowed_tools: [Skill]
---

/wayfinder 42

Picking my screen recorder work back up. It is issue #42 in `s1n7ax/screenrec`,
labelled `wayfinder:map`. The body is:

```markdown
## Destination

A CLI that records the whole Linux desktop to an mp4 I can play anywhere.

## Requirements

- one hotkey toggles recording on and off, sound on stop
- saves to ~/Videos/recordings, named by date and time
- whole screen only, no audio, for now
- a crash mid-recording must still leave a playable file

## Map

- [x] grill: how recording starts and stops — [result](https://github.com/s1n7ax/screenrec/issues/42#issuecomment-111)
- [x] research: screen capture on Wayland vs X11 — [result](https://github.com/s1n7ax/screenrec/issues/42#issuecomment-112)
- [x] task: confirm the capture portal works on my machine — [result](https://github.com/s1n7ax/screenrec/issues/42#issuecomment-113)
- [ ] implement: hotkey listener that toggles a recording flag
- [ ] implement: encoder pipeline writing fragmented mp4

## Implementation notes

- ffmpeg over OBS — already installed, no GUI needed
```

Carry on from here.

Shell access is broken on this box, so you cannot run `gh` or write files. Write
out: (a) which step you are taking and why, (b) the code for it, (c) the exact
comment you would post on #42 and the checklist line you would tick, and (d) how
you would end this session.
