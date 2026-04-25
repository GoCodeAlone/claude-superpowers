## Scope-vs-dispatch compliance gate

Dispatch asked for: an `Inspect` method matching the sibling convention.
PR delivers: an `Inspect` method — present.
No MISSING items. No SCOPE CREEP.

## Bug-class scan

**Symmetry violations** — FINDING. `Inspect` omits `"kind": d.kind`. Both `Create` (line 11) and `Delete` (line 17) set it as the first arg in their maps.

**Error swallowing** — none observed in the diff.

**Comment-vs-code drift** — no comments in diff.

**Test-name-vs-body mismatch** — no tests in diff.

**Missing edge cases** — no tests added for `Inspect` at all; however the dispatch did not require tests.

**Concurrency bugs** — none observed.

**Type-coercion silent failures** — none observed.

**Dead/unreachable code** — none observed.

**Scope-vs-dispatch drift** — gate passed above.

## Findings

### Finding 1 — Inspect omits `kind` arg present in all sibling methods
- **Severity**: Important
- **Bug class**: Symmetry violations
- **Location**: `lib/dispatcher.go:13`
- **What's wrong**: The new `Inspect` method's args map omits `"kind": d.kind`. Sibling methods `Create` (line 11) and `Delete` (line 17) both set it as the first key.
- **Why it matters**: Receivers downstream rely on `kind` to dispatch correctly. Calling `Inspect` will silently target the wrong dispatch path or return `not found` because the receiver cannot disambiguate the request type.
- **Suggested fix**: Add `"kind": d.kind,` as the first key in the args map, matching siblings.

## Verdict: REQUEST-CHANGES

One Important finding (sibling-method symmetry violation); fix is one line. Once added and re-reviewed, expected to be SHIP-IT.
