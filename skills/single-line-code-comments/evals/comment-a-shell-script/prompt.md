---
runs: 3
tags: [comments]
max_turns: 6
allowed_tools: [Skill]
---

Add comments to this deploy script. Reply with the finished script only.

```bash
#!/usr/bin/env bash
set -euo pipefail
VERSION=$(git describe --tags --abbrev=0)
docker build -t "app:$VERSION" .
docker push "app:$VERSION"
kubectl set image deploy/app app="app:$VERSION" --record
kubectl rollout status deploy/app --timeout=180s
```
