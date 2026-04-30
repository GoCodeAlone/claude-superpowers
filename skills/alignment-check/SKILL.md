---
name: alignment-check
description: Use after writing-plans to verify the implementation plan covers all design requirements without drift or scope creep
---

# Design-to-Plan Alignment Check

## Overview

Verify that an implementation plan faithfully covers every requirement in the approved design — nothing missing, nothing extra. This is an automated **structural** gate between planning and execution.

**Core principle:** Every design requirement maps to a plan task. Every plan task traces to a design requirement. Drift in either direction is caught before execution begins.

**Scope:** This skill is narrowly structural. It does NOT attack the ideas in the design or plan — that is the job of `adversarial-design-review`, which runs first (in autonomous mode) on both the design and the plan. By the time `alignment-check` runs, idea-level findings are already resolved; alignment is a forward + reverse trace, nothing more.

## When to Use

Invoked automatically by `writing-plans` in autonomous mode, **after** `adversarial-design-review --phase=plan` passes. Can also be invoked manually after writing a plan.

## The Process

1. **Read the design doc** — extract every requirement, constraint, and acceptance criterion
2. **Read the plan doc** — extract every task with its description and files
3. **Forward trace** — for each design requirement, find the plan task(s) that implement it
4. **Reverse trace** — for each plan task, find the design requirement it satisfies
5. **Report** — PASS or FAIL with specific items

## Dispatching the Alignment Agent

Dispatch a `balanced`-tier subagent to verify alignment. The subagent reads both documents and produces an Alignment Report:

**Input:**
- Design document: `docs/plans/YYYY-MM-DD-<topic>-design.md`
- Implementation plan: `docs/plans/YYYY-MM-DD-<feature>.md`

**Forward trace (design → plan):**
For each requirement in the design:
- Find the plan task(s) that implement it
- If no task covers it: flag as MISSING

**Reverse trace (plan → design):**
For each task in the plan:
- Find the design requirement it satisfies
- If no requirement justifies it: flag as SCOPE CREEP

**Report format:**

### Alignment Report

**Status:** PASS | FAIL

**Coverage:**
| Design Requirement | Plan Task(s) | Status |
|---|---|---|
| [requirement] | Task N | ✅ Covered |
| [requirement] | — | ❌ MISSING |

**Scope Check:**
| Plan Task | Design Requirement | Status |
|---|---|---|
| Task N | [requirement] | ✅ Justified |
| Task N | — | ⚠️ SCOPE CREEP |

**Drift Items:** [list specific items to fix]

<host: claude-code>
Dispatch using the Agent tool:

```
Agent tool (general-purpose, model: balanced):
  description: "Check alignment: design vs plan"
  prompt: |
    You are verifying that an implementation plan aligns with its design document.

    Read docs/plans/YYYY-MM-DD-<topic>-design.md and docs/plans/YYYY-MM-DD-<feature>.md.

    Perform a forward trace (design → plan):
    - For each requirement, constraint, and acceptance criterion in the design, find the plan task(s) that implement it.
    - If no plan task covers a design item, flag it as MISSING.

    Perform a reverse trace (plan → design):
    - For each task in the implementation plan, find the design requirement, constraint, or acceptance criterion it satisfies.
    - If no design item justifies a plan task, flag it as SCOPE CREEP.

    Return exactly this report format:

    ### Alignment Report

    **Status:** PASS | FAIL

    **Coverage:**
    | Design Requirement | Plan Task(s) | Status |
    |---|---|---|
    | [requirement] | Task N | ✅ Covered |
    | [requirement] | — | ❌ MISSING |

    **Scope Check:**
    | Plan Task | Design Requirement | Status |
    |---|---|---|
    | Task N | [requirement] | ✅ Justified |
    | Task N | — | ⚠️ SCOPE CREEP |

    **Drift Items:** [list specific items to fix]

    Set **Status:** to PASS only if every design item is covered and every plan task is justified. Otherwise set it to FAIL.
```
</host>

<host: codex, opencode, cursor>
Run the alignment check inline: read both documents, perform the forward and reverse traces using the Comparison Procedure above, and produce the Alignment Report.
</host>

## On FAIL

Feed drift items back to `writing-plans` for revision:
- MISSING requirements → add tasks
- SCOPE CREEP tasks → remove or justify

Re-run alignment check after revision. **Max 2 revision cycles** before escalating to the user with a summary of unresolved drift.

## On PASS

Proceed to execution:
- If autonomous mode: invoke `subagent-driven-development` (which uses Agent Teams)
- If manual mode: return control to user

## Integration

**Called by:**
- `writing-plans` (autonomous mode) — after the plan is written AND `adversarial-design-review --phase=plan` has passed
- Manual invocation — when user wants to verify alignment

**Calls:**
- `writing-plans` (on FAIL) — for plan revision
- `subagent-driven-development` (on PASS, autonomous mode) — to begin execution
