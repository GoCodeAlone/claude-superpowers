---
name: alignment-check
description: Use after writing-plans to verify the implementation plan covers all design requirements without drift or scope creep
---

# Design-to-Plan Alignment Check

## Overview

Verify that an implementation plan faithfully covers every requirement in the approved design — nothing missing, nothing extra. This is an automated gate between planning and execution.

**Core principle:** Every design requirement maps to a plan task. Every plan task traces to a design requirement. Drift in either direction is caught before execution begins.

## When to Use

Invoked automatically by `writing-plans` in autonomous mode. Can also be invoked manually after writing a plan.

## The Process

1. **Read the design doc** — extract every requirement, constraint, and acceptance criterion
2. **Read the plan doc** — extract every task with its description and files
3. **Forward trace** — for each design requirement, find the plan task(s) that implement it
4. **Reverse trace** — for each plan task, find the design requirement it satisfies
5. **Report** — PASS or FAIL with specific items

## Dispatching the Alignment Agent

<host: claude-code>

Dispatch a `balanced`-tier agent to perform the comparison:

```
Agent tool (general-purpose, model: balanced):
  description: "Check alignment: design vs plan"
  prompt: |
    You are verifying that an implementation plan aligns with its design document.

    ## Design Document
    [Read: docs/plans/YYYY-MM-DD-<topic>-design.md]

    ## Implementation Plan
    [Read: docs/plans/YYYY-MM-DD-<feature>.md]

    ## Your Job

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
```

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
- `writing-plans` (autonomous mode) — after plan is written
- Manual invocation — when user wants to verify alignment

**Calls:**
- `writing-plans` (on FAIL) — for plan revision
- `subagent-driven-development` (on PASS, autonomous mode) — to begin execution
