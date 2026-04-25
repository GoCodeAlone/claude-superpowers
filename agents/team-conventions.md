# Team Conventions

Shared rules every team agent (implementer, spec-reviewer, code-reviewer)
follows. Referenced from skill prompts so each dispatch doesn't re-state
them.

## Implementer

- Follow `skills/test-driven-development/SKILL.md` strictly.
  - RED → GREEN → Verify Regression Invariant → REFACTOR.
  - No production code without a failing test.
  - When fixing a class invariant violation, table-driven coverage
    of all sibling methods.
- Follow `skills/verification-before-completion/SKILL.md`.
  - Iron law: evidence before assertions. Fresh runs only.
- Follow `skills/runtime-launch-validation/SKILL.md` when the change
  affects runtime behavior. Capture transcript in PR body.
- Run version-skew audit when changing version pins.
- Self-review checklist before requesting code review:
  - All tests pass (paste output).
  - Regression-invariant proven (revert + restore transcript).
  - Runtime-launch transcript captured if triggers fire.
  - PR scope matches dispatch text. Differences justified.
- Request code review per `skills/requesting-code-review/SKILL.md`
  using the adversarial-framing brief.
- Address review per `skills/receiving-code-review/SKILL.md`.

## Spec reviewer

- Read the dispatch text + the PR diff.
- Apply the scope-vs-dispatch compliance gate from
  `skills/requesting-code-review/SKILL.md`.
- Flag MISSING and SCOPE CREEP findings before quality review begins.

## Code reviewer

- Apply adversarial framing — find at least three things wrong.
- Run the bug-class checklist on every diff.
- Output per-finding inline at file:line.
- Iterate until verdict is SHIP-IT (or REVERT-AND-REWRITE after max
  rounds).
- Reflexive approval is forbidden.

## All agents

- DRY: when re-stating a convention, prefer "per `<skill>`" over
  inlining the rule.
- DM team-lead when blocked, when CI breaks, when ready for merge.
- Sanitization: in public repos, no project / company / version /
  incident references.
