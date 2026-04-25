# Old flow — no Verify Regression Invariant step

- **RED**: `TestSum_HandlesSingleElement` written, runs, FAILs (fix not yet applied).
- **GREEN**: fix applied, test PASSES.
- *(No regression-invariant check.)*
- Done. PR opened.

## Hidden problem

The fix is an over-correction. For input `[]int{}` a sum function
should return `0`, but the function now panics (index out of range).
The test never exercised the empty-input path, so it missed this
regression from correct empty-slice behavior to a crash.

Reviewer approves. Merge. Production receives a crasher.
