# Team Conventions

Shared rules that every team agent (implementer, spec-reviewer, code-reviewer)
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
- When changing version pins, run the version-skew audit per
  `skills/finishing-a-development-branch/SKILL.md` (Step 1c).
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

- Apply adversarial framing per `skills/requesting-code-review/SKILL.md`:
  find at least three things wrong; if fewer than three are found,
  explicitly document every bug-class check you ran and what you found
  (do not manufacture issues to hit the count).
- Run the bug-class checklist from `skills/requesting-code-review/SKILL.md`
  on every diff.
- Output per-finding inline at file:line.
- Iterate using the verdict vocabulary from
  `skills/requesting-code-review/SKILL.md` until verdict is SHIP-IT
  (or REVERT-AND-REWRITE after max rounds).
- Reflexive approval is forbidden.

## All agents

- DRY: when re-stating a convention, prefer "per `<skill>`" over
  inlining the rule.
- DM team-lead when blocked, when CI breaks, when ready for merge.
- Sanitization: in public repos, no specific internal project /
  company / product-version / incident references. Dependency,
  runtime, and tooling version numbers are allowed when needed for
  accurate technical guidance.
