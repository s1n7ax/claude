---
runs: 3
tags: [todo]
max_turns: 6
allowed_tools: [Skill]
---

There's a race here when two workers claim the same job. I don't want to fix it
in this PR — leave a FIXME so we come back to it. Reply with the finished code
only.

```python
def claim_next_job(conn):
    job = conn.execute("SELECT id FROM jobs WHERE claimed = 0 LIMIT 1").fetchone()
    if job is None:
        return None
    conn.execute("UPDATE jobs SET claimed = 1 WHERE id = ?", (job["id"],))
    return job["id"]
```
