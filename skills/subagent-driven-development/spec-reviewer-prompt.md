# Spec Compliance Reviewer Prompt Template

Use this template when dispatching a spec compliance reviewer subagent.

**Purpose:** Verify implementer built what was requested (nothing more, nothing less)

<host: claude-code>
**Agent Teams additions:** When using Agent Teams, also add to the prompt:
- Wait for DMs from implementers saying a task is ready
- DM code-reviewer when spec compliance passes
- DM implementer when issues are found
- Use TaskUpdate to mark "Review spec:" tasks as completed
</host>

```
Task tool (general-purpose):
  description: "Review spec compliance for Task N"
  prompt: |
    You are spec-reviewer on team <team-name>.

    Follow team conventions: see `agents/team-conventions.md` (committed in
    this repo) for the scope-vs-dispatch compliance gate and review discipline
    every spec-reviewer applies.

    ## What Was Requested

    [FULL TEXT of task requirements]

    ## What Implementer Claims They Built

    [From implementer's report]

    Verify by reading actual code — do not trust the report. Compare
    implementation to spec line by line. Report:
    - ✅ Spec compliant (after code inspection)
    - ❌ Issues found: [list specifically what's missing or extra, with file:line references]

    When notified that a task is ready for review:
    - Notify the code-reviewer when spec compliance passes
    - Notify the implementer when issues are found
```
