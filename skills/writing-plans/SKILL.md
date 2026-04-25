---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** This should be run in a dedicated worktree (created by brainstorming skill).

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`

## Plan Mode Detection

**Prefer Claude's Plan Mode when available.** If you are running in Claude Code and can enter Plan Mode (e.g. via `Shift+Tab` or the `/plan` command), use it to draft the implementation plan. If Claude's Plan Mode is not available (Cursor, Codex, OpenCode, or other environments), use the Built-In Planning Process below.

### Using Claude's Plan Mode (Claude Code)

1. **Enter Plan Mode** — explore the codebase, analyze the design, and draft the implementation plan using Claude's native Plan Mode
2. **Follow the plan format below** — structure your Plan Mode output using the same Plan Document Header and Task Structure defined in this skill
3. **Exit Plan Mode** — once the plan is fully drafted
4. **Save the plan** — write the plan to `docs/plans/YYYY-MM-DD-<feature-name>.md` using the exact format from Plan Document Header and Task Structure sections below
5. **Continue the pipeline** — proceed to Execution Handoff as normal

The plan document you save MUST follow the same format described in Plan Document Header and Task Structure below, regardless of whether it was drafted in Plan Mode or with the built-in process. This ensures downstream skills (alignment-check, executing-plans, subagent-driven-development) work correctly.

### Built-In Planning Process (Non-Claude Code)

When Claude's Plan Mode is not available, use the full planning process described in the sections below to write the plan directly.

## Autonomous Mode

When invoked from brainstorming with autonomous context (design already approved):

1. **Skip user plan review** — write the plan directly without presenting it for approval
2. **Invoke alignment-check** — dispatch the alignment verification agent
3. **On alignment PASS** — invoke subagent-driven-development to begin execution
4. **On alignment FAIL** — revise the plan based on drift items, re-check (max 2 cycles)
5. **On persistent FAIL** — escalate to user with unresolved drift summary

The autonomous flag propagates through the entire pipeline: writing-plans → alignment-check → execution → PR creation → PR monitoring.

## Design-only mode

Design-only mode is active if ANY of: `--design-only` flag or propagation from brainstorming. If signals conflict, the most-restrictive wins (i.e., design-only takes effect). Default is execution dispatched.

Do not add YAML frontmatter to signal design-only mode. Saved plan documents must keep the standard format so downstream skills can parse them reliably, with `# [Feature Name] Implementation Plan` as the first line of the file.

**Behavior in design-only mode:**

1. Save the plan to `docs/plans/<filename>.md` as normal.
2. Commit the plan as normal.
3. Invoke `superpowers:alignment-check` as normal.
4. **On alignment PASS: STOP.** Do NOT invoke subagent-driven-development.
5. **On alignment FAIL:** revise the plan based on drift items, re-check (max 2 cycles) — same as default Autonomous Mode. After revision, if PASS, still STOP (do not proceed to execution).
6. **On persistent FAIL after the max 2 cycles:** escalate to the user with an unresolved drift summary — same as Autonomous Mode step 5. Do NOT invoke subagent-driven-development or dispatch any execution.
7. The plan + design sit in `docs/plans/` for future execution. The orchestrator (or a future invocation) can resume by passing the plan to `subagent-driven-development` directly once alignment issues are resolved.

**When to use:**

- Design exploration ahead of available implementation capacity.
- Cross-cutting designs that affect multiple workstreams; lock the design in before any one workstream starts.
- Designs with prerequisites in-flight elsewhere; queue the plan now, execute when prerequisites land.

**Default (no flag):** alignment-check PASS → invoke subagent-driven-development. Same as before.

## Verification per change class

When writing a plan task, the verification step must match the change class. A green unit-test run is sufficient ONLY for internal-logic refactors. Other classes need stronger evidence.

| Change class | Verification | Expected output |
|---|---|---|
| Internal logic refactor | unit tests | all green |
| Schema migration | apply against ephemeral DB; down + re-apply | no orphaned tables; migration tool reports applied / schema version updated |
| API endpoint | exercise endpoint with representative inputs (curl, gRPC, etc.) | HTTP 200 + expected JSON body |
| Build pipeline / Dockerfile | build artifact + launch + healthcheck (see `runtime-launch-validation`) | transcript captured; exit 0 |
| Version pin update | run version-skew audit (see `finishing-a-development-branch` Step 1c) + relaunch artifact | transcript captured; audit clean |
| CLI command | `cmd --help` + representative invocation | help text correct; exit 0 |
| UI component | render in browser/dev server | screenshot or visual confirmation |
| Plugin / extension | load into host + exercise representative call | exit 0; representative call returns expected value |
| Documentation / comments | spell-check + render preview | no broken anchors |
| Hook / trigger / event handler | fire the event; observe handler runs | logged side effect confirmed; assertion passes |

These examples are illustrative minimums; per-task `Expected:` fields must be literal values the check can assert against.

Every plan task must include the verification step appropriate to its change class, as defined in the table above. For tasks whose `finishing-a-development-branch` Step 1b trigger conditions are met, include that runtime-launch-validation step in the TDD breakdown as well; otherwise, use the class-appropriate verification without implying Step 1b is required.

The plan author writes the expected output literally — not "passes tests" but "logs `engine ready` within 10 seconds and `/healthz` returns 200".

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

**Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## Remember
- Exact file paths always
- Complete code in plan (not "add validation")
- Exact commands with expected output
- Reference relevant skills with @ syntax
- DRY, YAGNI, TDD, frequent commits

## Execution Handoff

### Autonomous Mode (from brainstorming pipeline)

When running autonomously (design already approved, no user interaction):

1. Save the plan to `docs/plans/<filename>.md`
2. Commit the plan
3. Invoke `superpowers:alignment-check` to verify design-to-plan alignment
4. On PASS: invoke `superpowers:subagent-driven-development` (which uses Agent Teams when available)
5. Do NOT ask the user for execution choice — the pipeline is autonomous

### Manual Mode (direct invocation)

When invoked directly by the user (not from brainstorming pipeline):

**"Plan complete and saved to `docs/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

**2. Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Stay in this session
- Fresh subagent per task + code review

**If Parallel Session chosen:**
- Guide them to open new session in worktree
- **REQUIRED SUB-SKILL:** New session uses superpowers:executing-plans
