# Canonical Interface Boundary Classes

An **interface boundary** is any point where two independent components exchange data or control. The canonical boundary classes are:

| Pair | Examples |
|---|---|
| **producer→consumer** | event emitter → subscriber, message publisher → queue reader, log writer → log aggregator |
| **caller→callee** | client → server RPC, function caller → library function, test harness → system under test |
| **plugin→host** | plugin emitting a lifecycle event → host receiving it, host invoking a plugin hook |
| **sender→handler** | HTTP request sender → route handler, message sender → message handler, webhook emitter → webhook receiver |

## Why this matters

When a change touches one side of a boundary, the other side must also be updated, tested, and (for runtime artifacts) launched. Omitting any side is **one-sided boundary wiring** (P12): the change appears complete locally but fails at the crossing.

## References

- `skills/requesting-code-review/SKILL.md` — P12 bug-class checklist entry (One-sided boundary wiring)
- `skills/test-driven-development/SKILL.md` — "When the Change Crosses an Interface Boundary" section
- `skills/runtime-launch-validation/SKILL.md` — Interface boundary change row in per-change-class table
