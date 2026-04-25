# Code Quality Reviewer Prompt Template

Use this template when dispatching a code quality reviewer subagent.

**Purpose:** Verify implementation is well-built (clean, tested, maintainable)

**Only dispatch after spec compliance review passes.**

```
Task tool (superpowers:code-reviewer):
  Use template at skills/requesting-code-review/code-reviewer.md

  WHAT_WAS_IMPLEMENTED: [from implementer's report]
  PLAN_OR_REQUIREMENTS: Task N from [plan-file]
  BASE_SHA: [commit before task]
  HEAD_SHA: [current commit]
  DESCRIPTION: [task summary]

  Follow team conventions: see `agents/team-conventions.md` (committed in
  this repo) for adversarial framing and per-finding inline output format.
  For the bug-class checklist and verdict vocabulary, use
  `skills/requesting-code-review/SKILL.md`.

  When operating as a team member:
  - Wait for DMs from spec-reviewer saying a task is spec-approved
  - DM implementer when quality issues are found
  - DM team lead when task is fully approved
  - Use TaskUpdate to mark "Review quality:" tasks as completed
```

**Code reviewer returns:** Strengths, Issues (Critical/Important/Minor), Assessment
