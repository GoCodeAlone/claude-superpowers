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
