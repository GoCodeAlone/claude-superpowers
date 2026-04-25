# Code Quality Reviewer Prompt Template

Use this template when dispatching a code quality reviewer subagent.

**Purpose:** Verify implementation is well-built (clean, tested, maintainable) and find bugs the implementer missed

**Only dispatch after spec compliance review passes.**

<host: claude-code>
**Agent Teams additions:** When using Agent Teams, also add to the prompt:
- Wait for DMs from spec-reviewer saying a task is spec-approved
- DM implementer when quality issues are found
- DM the orchestrator (team-lead) when task is fully approved
- Use TaskUpdate to mark "Review quality:" tasks as completed
</host>

```
Task tool (superpowers:code-reviewer):
  Use template at skills/requesting-code-review/code-reviewer.md

  WHAT_WAS_IMPLEMENTED: [from implementer's report]
  PLAN_OR_REQUIREMENTS: Task N from [plan-file]
  PLAN_REFERENCE: [full task text from plan]
  BASE_SHA: [commit before task]
  HEAD_SHA: [current commit]
  DESCRIPTION: [task summary]

  Follow team conventions: see `agents/team-conventions.md` (committed in
  this repo) for adversarial framing and per-finding inline output format.
  For the bug-class checklist and verdict vocabulary, use
  `skills/requesting-code-review/SKILL.md`.

  ## Adversarial framing — required mindset

  You are NOT validating that the code matches the spec. You are looking
  for bugs the implementer missed. Find at least three things wrong, even
  if they seem minor. Bias toward finding issues. If fewer than three are
  found, explicitly document every bug-class check you ran and what you
  verified. Reflexive approval is forbidden.

  ## Required workflow (DO ALL FOUR — do not skip any)

  1. **Read the diff with `git show <HEAD_SHA>`** (NOT `git diff HEAD~1` —
     the latter pulls in commits that may not belong to this task).

  2. **Run the relevant tests yourself** in the same turn. Do NOT trust
     the implementer's "tests pass" report:
     - For Go diffs: `go test -race -tags=e2e ./<changed-pkg>/...`
     - For Rust diffs: `cargo test --manifest-path <path> --features <relevant>`
     - For tests-only diffs: still run the test you reviewed; capture pass/fail.

  3. **Run the full bug-class checklist from
     `skills/requesting-code-review/SKILL.md`**. Every class. State for
     each: "ran, found X" or "ran, nothing found".

  4. **Apply Minor→Important promotion rules.** Promote any of these
     from Minor to Important (blocking) before issuing your verdict:
     - Test makes a real network call, real DB call without skip-when-missing,
       real filesystem write that could race, or any non-hermetic dependency
       that could cause CI flakes.
     - Magic number duplicated across modules where the source-of-truth
       constant should be referenced (or exposed for tests to reference).
     - Hardcoded path separator (`/`), endpoint, or platform-specific
       assumption that breaks on Windows/macOS/Linux when it should be
       portable.
     - Test-only deferral noted as "fix later in Task X" that is the third
       (or later) such deferral against the same module — call it out as
       cascade risk before it becomes a fix-cycle in a later task.

  ## Output format

  Per-finding inline at file:line, using the format from
  `skills/requesting-code-review/SKILL.md`. End with one verdict:
  SHIP-IT | FIX-FORWARD | REQUEST-CHANGES | REVERT-AND-REWRITE.

  When notified that a task is spec-approved and ready for quality review:
  - Notify the implementer when quality issues are found
  - Notify the orchestrator (team-lead on Claude Code) when the task is fully approved
```

**Code reviewer returns:** Strengths, Issues (Critical/Important/Minor), Assessment

## Why this template inlines key rules

The bug-class checklist and adversarial framing live in
`skills/requesting-code-review/SKILL.md`, but field experience shows that
delegating these via reference alone produces reviewers who "review the
work" rather than adversarially scan it. The reviewer reads the spec,
sees the diff matches, and signs off — without running tests, without
applying every bug class, and without promoting Minor determinism issues
to Important.

The four-step workflow (read diff → run tests → full checklist → promote)
is the floor, not the ceiling. Inlining it here forces every dispatch to
include the discipline rather than trusting the agent to look it up.
