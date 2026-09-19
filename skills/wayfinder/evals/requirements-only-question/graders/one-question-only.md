---
type: llm
weight: 3
---

The message puts exactly **one** question to the user and then waits.

Fail this if it asks two or more questions at once — a numbered list of
questions, a questionnaire, or a main question with extra ones bolted on
("...and also, what OS versions matter?"). A single question offered with
several answer options is one question and passes.
