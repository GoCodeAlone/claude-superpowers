# requesting-code-review test fixtures

Each fixture demonstrates a class of bug the **old** reviewer brief
let pass and the **new** brief catches. Used to validate the skill's
effectiveness and to prevent regression.

## sibling-asymmetry

Diff with one new method that omits an arg every sibling method sets.
- `diff.patch` — the change under review
- `dispatch.md` — what the implementer was asked to do
- `old-prompt.md` — pre-rewrite reviewer brief (validation framing)
- `expected-old-result.md` — what the old prompt typically returns: approval
- `new-prompt.md` — post-rewrite reviewer brief (adversarial framing + checklist)
- `expected-new-result.md` — what the new prompt returns: Important finding flagged

## How to add a new fixture

1. Write a generic diff that demonstrates a bug class from the checklist.
2. Capture the dispatch text the implementer would have received.
3. For `expected-old-result.md` and `expected-new-result.md`: prefer real
   transcripts captured from live subagent runs under each prompt. When a
   live run hasn't been captured yet (e.g., for initial demonstrations),
   author-written results are acceptable — but MUST be clearly labeled with
   `<!-- synthesized -->` as the first line so readers know the output is
   illustrative, not a recorded run. Replace synthesized results with live
   transcripts as capacity allows.
4. The new prompt MUST flag where the old approved.
