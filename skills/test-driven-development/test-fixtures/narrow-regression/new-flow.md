# New flow — with Verify Regression Invariant step

- **RED**: `TestSum_HandlesSingleElement` written, runs, FAILs.
- **GREEN**: fix applied, test PASSES.
- **Verify Regression Invariant**:
  - Revert fix. Run `TestSum_HandlesSingleElement`. Must FAIL. [confirmed: FAILS]
  - Restore fix. Must PASS. [confirmed: PASSES]
  - Proof pasted in PR body:
    ```
    With fix reverted:
    $ go test -run TestSum_HandlesSingleElement
      FAIL — got 0, want 1

    With fix restored:
    $ go test -run TestSum_HandlesSingleElement
      PASS
    ```
- **Class invariant heuristic check**:
  - Is `Sum` part of a sibling-method group? (Yes: math ops on slices —
    `Sum`, `Mean`, `Max`, `Min`.)
  - Does the bug stem from one method drifting from a group convention?
    (No — the bug is Sum-internal, not a shared-arg omission.)
  - Heuristic does NOT apply here; narrow test is appropriate for this
    specific fix. But the edge-case class should still be swept:
- **Edge-case sweep** (per "Missing edge cases" in code-review checklist):
  - Empty slice: run `Sum([]int{})`. **PANICS** — index out of range!
  - Implementer realizes the fix is wrong. Refactors. While sweeping edge cases:
    - Empty slice → confirmed panics, added `TestSum_HandlesEmpty`.
    - Negative ints → verified they accumulate correctly (no bug found),
      added `TestSum_HandlesNegative` prophylactically as a boundary check.
    - Single element → original failing case, kept `TestSum_HandlesSingleElement`.
  - Runs Verify Regression Invariant on each new test.
  - All three pass the revert-and-restore proof.
- Done. PR opened with proof transcript + edge-case sweep.

## Outcome

The hidden crasher (empty-slice panic) is caught before merge. Three
tests now gate the function against regression. Total extra time: ~10
minutes. Total time saved: hours of production triage.
