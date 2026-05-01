---
name: recording-decisions
description: Use when the design or plan makes a non-trivial trade-off that future contributors will need context for - records an Architecture Decision Record (ADR) in decisions/ so the rejected alternatives and reasoning are durable, not lost in transcript history
---

# Recording Decisions

## Overview

Architecture Decision Records (ADRs) capture the **why** behind a choice — particularly the alternatives that were rejected and the reasoning. Designs in `docs/plans/` say *what* we built; ADRs say *why this and not that*.

`adversarial-design-review` produces a report alongside each design that lists "Options the author may not have considered" and a verdict reasoning paragraph. That covers idea-level alternatives at one moment in time. ADRs are the persistent index across the project: a rename, a refactor, or a new contributor's "why is it like this?" question goes through `decisions/`, not through hunting for the right adversarial-review report inside an old design folder.

**Core principle:** record once, in a stable location, with a stable number, in Michael Nygard's three-section format.

## When to use this skill

Invoke this skill when **any** of these conditions hold:

1. **Divergence from precedent.** The design / plan picks a path that differs from a previously-established pattern in this repo (e.g., a different testing strategy, a different state-management choice, a different deployment shape than other components).
2. **Non-trivial trade-off.** The design weighs ≥2 plausible approaches and picks one for reasons that won't be obvious from reading the code. A flat file vs. SQLite vs. Postgres choice. A library-pin floor (`>=X.Y`) vs. exact pin (`==X.Y.Z`) decision. Sync vs. async. Polling vs. webhook.
3. **Adversarial-review override.** The design author accepted an adversarial-review finding as "yes, but here's why" rather than fixing it. The acceptance reasoning belongs in an ADR so future contributors don't re-litigate.
4. **Cross-skill structural change.** Any change that affects multiple skills' integration (e.g., introducing a new gate in the autonomous pipeline, renaming a step that other skills cite).

If none of the four conditions hold, an ADR is not required. ADRs are not for every commit — they are for choices that future contributors will read the code and ask "why is it like this?" about.

## Process

1. **Pick the next free number.** ADRs are numbered sequentially: `0000-template.md`, `0001-...md`, `0002-...md`. With four-digit zero-padded prefixes, lexicographic sort is equivalent to numeric sort:
   ```bash
   ls decisions/ | grep -E '^[0-9]{4}-' | sort | tail -1
   ```
   Take the prefix of the result and add 1.
2. **Copy the template.**
   ```bash
   cp decisions/0000-template.md decisions/NNNN-<short-slug>.md
   ```
   The slug is kebab-case, ≤6 words: `0007-pin-postgres-major-version-only.md`.
3. **Fill the three sections.** Context, Decision, Consequences. Each section is short (≤150 words is a good target). If you can't say it in 150 words, the trade-off probably isn't crisp yet.
4. **Set status.** New ADRs start as `Status: Accepted`. Superseded ADRs are not deleted — they get `Status: Superseded by NNNN` and the new ADR cites them in its Context.
5. **Cite from the design / plan.** The design or plan that triggered the ADR MUST cite it: `See decisions/0007-pin-postgres-major-version-only.md`. This is the back-link that makes ADRs discoverable.
6. **Commit alongside the design / plan.** ADRs are committed in the same commit as the design (when triggered by `brainstorming`) or the same commit as the plan (when triggered by `writing-plans`).

## ADR format (Michael Nygard, lightly extended)

```markdown
# NNNN. <Short verb-led title>

**Status:** Accepted | Superseded by MMMM | Deprecated
**Date:** YYYY-MM-DD
**Decision-makers:** <handles or roles>
**Related:** <design path>, <plan path>, <adversarial-review report>, <prior ADRs>

## Context

<What is the situation? What forces are at play? What constraints exist?
What did we know at the time? What did we explicitly NOT know? Cite sources
where possible.>

## Decision

<We will <verb> <thing> because <reason>. Be precise. Name the alternatives
considered and rejected, with one sentence each on why they were rejected.>

## Consequences

<What becomes easier? What becomes harder? What new constraints does this
introduce? What does this cost us if we want to undo it later? List 2-5
consequences; both positive and negative are required — a one-sided list
is a smell.>
```

## Integration

**Called by:**
- `brainstorming` — when the design triggers any of the four conditions above.
- `writing-plans` — when the plan introduces a non-obvious choice not already covered by an ADR.
- `adversarial-design-review` — recommended when an Important finding is accepted by the author with reasoning.
- Manual — any contributor recording a decision retroactively.

**Calls:** none. ADRs are leaves; they record state, not next steps.

## Anti-patterns

- **ADR for every task.** ADRs are for choices, not for documenting work. If the entry is just "we built feature X", it belongs in the design / plan / commit message, not in `decisions/`.
- **ADR as future tense.** ADRs record decisions that have been made, not proposals. Use the design doc for proposals; promote to an ADR after the choice is locked.
- **Editing accepted ADRs.** Accepted ADRs are immutable except for status changes (Accepted → Superseded by NNNN). To change the decision, write a new ADR that supersedes the old one. The old one stays in the repo; future contributors need to see the history.
- **Skipping the alternatives.** "Decision: use Postgres" with no rejected alternatives is a non-ADR. The Nygard format demands the trade-off — without it, it's a glorified README entry.

## Why this skill is light by design

ADRs work when they're cheap to write and hard to dodge. This skill is intentionally short: a numbering rule, a template, a four-condition trigger, and a commit convention. The heavy lifting (figuring out what to write) lives in the design and adversarial-review process. This skill is the storage protocol.
