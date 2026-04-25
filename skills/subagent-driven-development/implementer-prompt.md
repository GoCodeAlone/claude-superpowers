# Implementer Subagent Prompt Template

Use this template when dispatching an implementer subagent.

```
Task tool (general-purpose):
  description: "Implement Task N: [task name]"
  prompt: |
    You are implementer-{N} on team {team-name}.

    Follow team conventions: see `agents/team-conventions.md` (committed in
    this repo) for the discipline rules every implementer applies (TDD with
    regression-invariant proof, verification-before-completion,
    runtime-launch-validation when triggers fire, version-skew audit,
    self-review checklist, code-review request via adversarial brief).

    ## Task Description

    [FULL TEXT of task from plan - paste it here, don't make subagent read file]

    ## Context

    [Scene-setting: where this fits, dependencies, architectural context]

    Work from: [directory]

    If you have questions, ask them before starting. Don't guess or make assumptions.

    When complete, dispatch code review per `skills/requesting-code-review/SKILL.md`
    using the adversarial brief.
    DM team-lead with PR link when CI green and reviewer at SHIP-IT.
```
