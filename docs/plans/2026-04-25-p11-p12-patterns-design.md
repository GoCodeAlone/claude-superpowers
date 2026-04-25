# Design: P11 (Shortcut Bias) + P12 (One-Sided Boundary Wiring) Patterns

**Date:** 2026-04-25  
**Branch:** `skills/pr6-shortcut-bias-incomplete-impl`  
**Status:** Approved — autonomous execution

## Problem

Two failure patterns appear repeatedly but are not named or described in any skill:

**P11 — Shortcut bias / band-aid fixes:** An implementation passes tests and satisfies the immediate symptom, but sidesteps the root cause. The underlying defect remains; only its surface expression is suppressed. Future changes re-expose it.

**P12 — One-sided boundary wiring:** A change crosses an interface boundary (producer→consumer, client→server, plugin→host, caller→callee) but only one side is implemented, tested, or validated at runtime. The other side is left as a stub, a TODO, or implicitly assumed to work.

Neither pattern is in the bug-class checklist, the TDD skill, or the runtime-launch-validation skill. Reviewers and implementers have no named target to aim at.

## Approach

In-place additions to three existing skills. No new files, no shared pattern docs — the skills are the single source of truth for reviewers and implementers respectively.

### 1. `skills/requesting-code-review/SKILL.md`

Add two rows to the bug-class checklist table (after the existing "Scope-vs-dispatch drift" row):

| Class | Definition |
|---|---|
| **Shortcut / band-aid fix** | The fix suppresses a symptom without addressing the root cause. Examples: nil-guard on a value that should never be nil (why is it nil?); retry loop masking a race condition; special-case for one known-bad input instead of fixing the upstream producer; failing test deleted instead of fixed. Ask: "would this still fail if the root cause were restored?" |
| **One-sided boundary wiring** | A change touches an interface boundary (producer→consumer, caller→callee, plugin→host) but only one side is implemented or tested. The other side is a stub, TODO, or unchecked assumption. Both sides of every boundary must be wired and have test coverage of the crossing. |

### 2. `skills/test-driven-development/SKILL.md`

**P11 — Proper-solution rule:** Add under "Common Rationalizations" (or as a new subsection before "Red Flags") a rule: a test passing doesn't prove the fix is correct — only that the symptom is gone. The implementer must verify the root cause is addressed by asking "if I revert only the root-cause fix and keep the symptom suppressor, does the test still pass?" If yes, the test proves nothing about correctness.

**P12 — Interface boundary coverage:** Add under "When the Bug Is a Class Invariant Violation" (or as a sibling section) a rule: when a change crosses an interface boundary, both sides require test coverage AND at least one test must exercise the crossing end-to-end (not mock both sides independently). Applies when: adding a new method on both a server and its client; adding a new field that flows from producer to consumer; adding a plugin hook that the host must call.

### 3. `skills/runtime-launch-validation/SKILL.md`

**P12 — Boundary launch row:** Add a row to the per-change-class table:

| Change class | What to launch | What to observe |
|---|---|---|
| Interface boundary change (new method, field, or hook crossing a producer→consumer or caller→callee boundary) | Launch both sides; exercise a real call across the boundary (not a mock or stub on either end) | The consumer receives and processes the new data/method/hook correctly; no fallback silently swallows the new path |

## Invariants (after state)

1. Both P11 and P12 appear in the requesting-code-review bug-class table with precise, example-rich definitions.
2. The TDD skill names the proper-solution rule explicitly — a passing test is not proof the root cause is fixed.
3. The TDD skill names the both-sides-coverage rule — interface boundary changes require end-to-end test coverage.
4. The runtime-launch-validation skill has an explicit entry for interface boundary changes.
5. Sanitization: all examples are generic (no project/company/product/version references).

## Out of Scope

- No new skill files.
- No changes to `agents/team-conventions.md` (it already points to the requesting-code-review skill for bug-class rules).
- No changes to the brainstorming or subagent-driven-development skills.
