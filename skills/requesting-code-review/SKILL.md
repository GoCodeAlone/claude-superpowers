---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

## Reviewer brief — adversarial framing

The reviewer subagent's instructions must use **adversarial framing**, not validation framing.

**Required prompt phrasing in every dispatch:**

> Find at least three things wrong with this code, even if they seem minor. Bias toward finding issues. You are NOT validating that the code matches the dispatch — you are looking for bugs the original author missed.

Why: the same base model produces dramatically different output under "find what's wrong" vs. "review the work." Validation framing biases toward approval; adversarial framing biases toward rigor. The shift is mechanical and reproducible.

**Forbidden phrasing**: "review the work", "verify the implementation matches the plan", "confirm correctness", any prompt that implies the reviewer's job is to validate. These produce sign-offs that miss real bugs.

**Reflexive approval is forbidden.** If the reviewer finds nothing wrong, they must state which checks were run (the bug-class checklist below) and what specifically they verified. A bare "looks good" is rejected.

## Bug-class checklist (must scan)

The reviewer must explicitly scan for each of these bug classes on every diff. The checklist is the floor, not the ceiling — additional findings are welcome.

| Class | Definition |
|---|---|
| **Symmetry violations** | Sibling methods in the same struct/class/handler family follow a convention; one method drifts from it. The new method omits a key the others set, or wraps an error the others don't, or returns a shape the others don't. |
| **Error swallowing** | `_, err := ...; result` patterns, `_ = err`, `if err != nil { log(err) }` followed by silent recovery, errors caught and not propagated when they should be. |
| **Comment-vs-code drift** | Comments describing behavior the code no longer has; comments naming files, functions, or variables that have been renamed. |
| **Test-name-vs-body mismatch** | A test named `..._HandlesNotFound` that actually simulates a list-API error rather than the not-found path. The name and the body disagree. |
| **Missing edge cases** | Tests covering only the happy path. No empty/nil/malformed inputs. No network-error or timeout paths. No boundary values. |
| **Concurrency bugs** | Goroutines/threads without sync, race conditions, channel-close patterns, missing locks, double-unlock. |
| **Type-coercion silent failures** | Encode/decode where `int → float64` is silently lossy, where `[]any → []string` is rejected without a clear error, where `nil` and zero-value diverge. |
| **Dead/unreachable code** | Branches no test exercises and no caller can reach. Either delete or cover. |
| **Scope-vs-dispatch drift** | The implementation ships materially MORE or LESS than the dispatch asked for. Both directions are findings. (See the dedicated gate below.) |

For each finding, the reviewer cites the bug class explicitly. This makes patterns visible across reviews and lets the team identify recurring weaknesses.

Dispatch superpowers:code-reviewer subagent to catch issues before they cascade.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch code-reviewer subagent:**

Use Task tool with superpowers:code-reviewer type, fill template at `code-reviewer.md`

**Placeholders:**
- `{WHAT_WAS_IMPLEMENTED}` - What you just built
- `{PLAN_OR_REQUIREMENTS}` - What it should do
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit
- `{DESCRIPTION}` - Brief summary

**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)

## Example

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch superpowers:code-reviewer subagent]
  WHAT_WAS_IMPLEMENTED: Verification and repair functions for conversation index
  PLAN_OR_REQUIREMENTS: Task 2 from docs/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## Integration with Workflows

**Subagent-Driven Development:**
- Review after EACH task
- Catch issues before they compound
- Fix before moving to next task

**Executing Plans:**
- Review after each batch (3 tasks)
- Get feedback, apply, continue

**Ad-Hoc Development:**
- Review before merge
- Review when stuck

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

See template at: requesting-code-review/code-reviewer.md
