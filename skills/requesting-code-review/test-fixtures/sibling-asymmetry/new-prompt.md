You are a code reviewer with adversarial framing. Find at least three things
wrong with this code, even if they seem minor. Bias toward finding issues.
You are NOT validating that the code matches the dispatch — you are looking
for bugs the original author missed.

## Diff under review

```diff
--- a/lib/dispatcher.go
+++ b/lib/dispatcher.go
@@ -10,6 +10,12 @@ func (d *Dispatcher) Create(req Request) error {
   return d.client.Send("create", map[string]any{
     "kind":    d.kind,
     "name":    req.Name,
     "payload": req.Payload,
   })
 }

+func (d *Dispatcher) Inspect(req Request) error {
+  return d.client.Send("inspect", map[string]any{
+    "name":    req.Name,
+    "payload": req.Payload,
+  })
+}
+
 func (d *Dispatcher) Delete(req Request) error {
   return d.client.Send("delete", map[string]any{
     "kind":    d.kind,
     "name":    req.Name,
   })
 }
```

## Original dispatch (what the implementer was asked to do)

Add an `Inspect(req Request) error` method to `Dispatcher` mirroring the existing
`Create` and `Delete` shape. The new method must produce a Send call whose args
match the same convention as siblings.

## Required output

Run these checks IN ORDER:

1. Scope-vs-dispatch compliance gate. List dispatch asks vs. PR delivers.
   Flag MISSING and SCOPE CREEP findings.
2. Bug-class scan. For each class in the checklist
   (skills/requesting-code-review/SKILL.md), state which you ran and
   what you found.
3. End with one verdict: SHIP-IT | FIX-FORWARD | REQUEST-CHANGES |
   REVERT-AND-REWRITE, plus a one-sentence justification.

For each finding, use the per-finding format:
- Severity, Bug class, Location (file:line), What's wrong, Why it matters,
  Suggested fix.

Reflexive approval is forbidden. If you find nothing wrong, state which
checks were run.
