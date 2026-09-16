---
type: llm
weight: 3
---

`#` comments are confined to a header block at the top of the script, a section
header, or a note explaining a genuinely non-obvious choice (e.g. why
`--record` is used, why the timeout is 180s).

Fail this if any comment simply restates what the next line does — "build the
docker image", "push the image", "update the deployment".
