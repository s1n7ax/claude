---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

Interview the user relentlessly about every aspect of this plan until you reach shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one.

Ask one question per turn using the AskUserQuestion tool. Enumerate 2-4 distinct paths as options. Make the first option your recommendation: append "(Recommended)" to its label and put your reasoning in its description. Use the other options' descriptions to explain their tradeoffs.

Use multiSelect only when the question is genuinely multi-pick (e.g., "which concerns are you defending against?"). Otherwise keep it single-select to force commitment to one path.

If a question can't be enumerated as 2-4 distinct options (genuinely open-ended exploration), ask it in plain prose instead.

If a question can be answered by exploring the codebase, explore the codebase instead.
