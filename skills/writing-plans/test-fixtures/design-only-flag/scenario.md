# Design-only mode propagation

The orchestrator runs:

```
brainstorming --design-only --topic "feature X"
```

Expected behavior:
- brainstorming runs full design flow (context → questions → approaches → design doc → commit).
- brainstorming hands off to writing-plans WITH `--design-only` set.
- writing-plans runs the full plan flow (writes plan, commits).
- writing-plans invokes alignment-check.
- alignment-check returns PASS.
- writing-plans STOPS — does NOT invoke subagent-driven-development.

Verification:
- `docs/plans/...-design.md` and `...-plan.md` both committed.
- No subagent-driven-development invocation in the session log.
- Orchestrator can later resume by passing the plan path to
  subagent-driven-development directly when ready.

## Without --design-only (default path)

```
brainstorming --topic "feature X"
```

- brainstorming runs full design flow.
- brainstorming hands off to writing-plans (no flag).
- writing-plans runs, invokes alignment-check, PASS.
- writing-plans invokes subagent-driven-development → execution begins.

## Verify Regression Invariant

**With `--design-only` removed from writing-plans** (revert test):
- Revert: writing-plans "Design-only mode" section removed.
- Run: orchestrator passes `--design-only` to writing-plans after alignment PASS.
- Expected: writing-plans proceeds to invoke subagent-driven-development.
- Result: FAIL — execution fires when it should not.
- Confirms the section is load-bearing.

**With `--design-only` restored** (restore test):
- Restore: writing-plans "Design-only mode" section present.
- Run: orchestrator passes `--design-only`.
- Expected: writing-plans halts at alignment PASS.
- Result: PASS — no execution dispatched.

**With `--design-only` removed from brainstorming** (revert test):
- Revert: brainstorming "Design-only mode" section removed.
- Run: user passes `--design-only` to brainstorming.
- Expected: flag is silently dropped; writing-plans gets no flag.
- Result: FAIL — execution fires when it should not.
- Confirms brainstorming's propagation section is load-bearing.

**With brainstorming flag restored** (restore test):
- Restore: brainstorming "Design-only mode" section present.
- Run: user passes `--design-only` to brainstorming.
- Expected: flag propagates → writing-plans halts at alignment PASS.
- Result: PASS — no execution dispatched.
