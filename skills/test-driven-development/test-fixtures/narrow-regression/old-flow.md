# Old flow — no Verify Regression Invariant step

- **RED**: `TestSum_HandlesSingleElement` written, runs, FAILs (fix not yet applied).
- **GREEN**: fix applied, test PASSES.
- *(No regression-invariant check.)*
- Done. PR opened.

## Hidden problem

The fix is an over-correction. For input `[]int{}` the function now
panics (index out of range). The test never exercised the empty-input
path. The original "returns 0 for empty" symptom is now WORSE (panic
vs. silent wrong answer), but the new test doesn't catch it.

Reviewer approves. Merge. Production receives a crasher.
