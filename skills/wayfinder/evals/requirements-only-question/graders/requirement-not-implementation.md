---
type: llm
weight: 4
---

The question is about **what the recorder must do**, from the user's point of
view — the kind of thing that would still matter if the code were thrown away
and rebuilt with different tools.

Passing examples: how a recording is started and stopped; where files are saved
and whether that is configurable; whether audio is captured; what happens if it
crashes mid-recording; whole screen versus a chosen window; what "done" looks
like for this project.

Fail this if the question is an implementation choice dressed as a requirement —
which capture library or tool (ffmpeg, OBS, GStreamer, PipeWire, wlroots), which
programming language or framework, which screen-capture API, process or threading
model, storage format library, or file/module layout. Asking the *consequence* of
such a choice ("is it OK if the user has to install another program first?")
passes; naming the tools does not.
