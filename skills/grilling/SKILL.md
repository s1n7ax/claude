---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled — the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

## Write every question in plain English

The user is not a native English speaker. A question they have to re-read is a failed question. Being clever with words is a bug, not a style.

Rules for every question, option, and recommended answer:

- **Short sentences.** One idea per sentence. Aim for 15 words or less.
- **Common words only.** Technical terms are fine (`cache`, `retry`, `index`, `race condition`) — fancy English is not. Say "use", not "leverage". Say "start", not "kick off". Say "problem", not "pain point".
- **No idioms, no metaphors, no jokes.** "Bite the bullet", "low-hanging fruit", "boil the ocean", "punt on this" — all banned. Say the literal thing.
- **Active voice, direct address.** "Do you want X?" not "Would it be desirable for X to be...".
- **Say the trade-off in full.** Never hint. Write both sides: "Option A is faster. Option B uses less memory."
- **Explain any term you must use.** First time you use a project-specific or unusual term, add a short `(this means ...)` note.
- **No stacked questions.** One question asks one thing. If you need two things, that is two numbered questions.
- **Make the choice concrete.** Prefer named options (A / B / C) over open-ended "what do you think about...".

The recommended answer follows the same rules. It must say **what** you would pick and **why**, in one or two short sentences. Never leave the default vague.

Each question should be formatted like so:

```
❓ **Q1** - **<short question title>**: <the question in plain English>

**A.** <first option, one short sentence> — <what it costs or gives you>
**B.** <second option, one short sentence> — <what it costs or gives you>

➡️ **My pick: A.** <one short sentence saying why>
```

Options are optional if the question is genuinely open, but the plain-English rules still apply.

### Examples

Bad:

```
❓ **Q1** - **Persistence semantics**: Should we leverage an eventually-consistent store here, or would you rather bite the bullet on the operational overhead of a strongly-consistent one?

➡️ Probably the former, given our constraints.
```

Good:

```
❓ **Q1** - **Where to save the data**: We need to save the session data somewhere.

**A.** Redis — fast, but data can be lost if the server restarts.
**B.** Postgres — slower, but the data is safe.

➡️ **My pick: B.** Losing a session is worse for the user than a slow save.
```

## Rounds

Each round the user answers reshapes the tree — settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it — don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report — ask the rest of the frontier now. The _decisions_ are the user's — put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
