# DRY conventions before/after

## Before (inlined)

Each implementer dispatch ~80 lines, repeating:
- TDD discipline reminder
- Self-review checklist
- Code-review request protocol
- Merge approval rules
- Sanitization rules

Each dispatch must restate these. Drift across dispatches.

## After (referenced)

Each implementer dispatch ~12 lines:
- Identity + team
- "See agents/team-conventions.md for discipline rules"
- Task description
- Specific success criteria
- Closing instructions

Conventions live in one place. Edits propagate without re-emitting.
~85% reduction in dispatch boilerplate; orchestrator can focus
prompts on task-specific content.

## Invariants — "after" state must hold

The following must be true of every prompt template after extraction.
Violation = the DRY refactor has drifted back toward inline.

1. No prompt file contains a `## Before Reporting Back` or `## Self-Review`
   section with bullet-point content (the checklist lives in
   `agents/team-conventions.md` only).
2. No prompt file says "checklist below", "see below", or "inlined here"
   in reference to conventions content.
3. Every reference to "version-skew audit" is accompanied by a pointer to
   `skills/finishing-a-development-branch/SKILL.md` Step 1c.
4. Every reference to "bug-class checklist" or "verdict vocabulary" is
   accompanied by a pointer to `skills/requesting-code-review/SKILL.md`.
5. The adversarial-framing exception clause ("if fewer than three issues
   found, document every bug-class check run") is preserved verbatim in
   `agents/team-conventions.md` — not silently dropped.

Verify stale-inline language:
`grep -rEn 'checklist below|see below|inlined here|Self-Review([[:space:][:punct:]]|$)' skills/subagent-driven-development/ --include="*.md" --exclude-dir=test-fixtures`
Expected: 0 matches.

Verify all skill file references resolve (no dead paths):
`grep -rEoh 'skills/[A-Za-z0-9._/-]+\.md' skills/subagent-driven-development/ agents/team-conventions.md --include="*.md" | sort -u | while read f; do [ -f "$f" ] || echo "MISSING: $f"; done`
Expected: no MISSING lines.

Verify no bare (prefix-less) requesting-code-review refs:
`grep -rEn '[^/]requesting-code-review/' skills/subagent-driven-development/ agents/team-conventions.md --include="*.md" --exclude-dir=test-fixtures`
Expected: 0 matches.
