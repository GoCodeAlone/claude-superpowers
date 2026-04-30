# Roadmap

Items considered during the v5.4.0 holistic evaluation of the superpowers plugin that are not landing immediately. Each entry has a one-paragraph rationale, a trigger condition (when it becomes worth doing), and a sketch of the shape of the change.

This file is maintained so good ideas surfaced during evaluation are not lost.

## Decision log / ADR step

**Status:** considered, not landed.

**Why not yet:** designs in `docs/plans/` capture *what* we chose, not *why we rejected alternatives* in a durable way. New contributors re-litigate decisions. However, the v5.4.0 `adversarial-design-review` skill now produces a report that includes "Options the author may not have considered" and a verdict reasoning paragraph, both committed alongside the design. That report functions as an organic decision log without inventing a new artifact. Adding ADRs on top would be process tax for a problem the new reviewer largely solves.

**Trigger to land:** if adversarial-review reports prove insufficient as a decision log in practice (e.g., contributors keep re-asking why a path was rejected, or the reports are too narrow), introduce a lightweight `decisions/` directory with one ADR per significant choice. Use Michael Nygard's template (Context / Decision / Consequences). Wire into `writing-plans` so plans that diverge from a previously-recorded decision are flagged.

## Post-merge retrospective skill

**Status:** considered, not landed.

**Why not yet:** `pr-monitoring` ends the pipeline. There's no closing-the-loop step that asks "what would we change about this skill set based on what happened?" Worth doing eventually, but needs its own design — adversarial review, skill activation effectiveness, post-incident learnings all blur together and should be untangled before a skill is written.

**Trigger to land:** when a meaningful number of merged PRs have used the v5.4.0 pipeline end-to-end (target: ≥10 distinct features). At that point there's enough signal to design a retrospective skill against real evidence rather than speculation.

**Sketch:** a `post-merge-retrospective` skill invoked after `pr-monitoring` reports the PR is merged and CI green. Reads the design, plan, adversarial-review reports, code-review threads, and CI history; produces a short report on (a) which adversarial findings were prescient, (b) which gates produced false positives, (c) skill activations that didn't fire when they should have. Output feeds into a `docs/retros/` directory.

## Skill-usage telemetry / self-audit

**Status:** considered, not landed.

**Why not yet:** v5.3.0 introduced `.claude/superpowers-state/in-progress.jsonl` — an append-only activity log written by a `PostToolUse` hook. That log is currently used only for compaction recovery, but it is the natural substrate for skill-activation telemetry. Wiring it up requires a non-trivial design: privacy considerations (don't ship anything off-machine), aggregation cadence, surfacing format, and how to handle hosts without hooks. Out of scope for v5.4.0.

**Trigger to land:** when there is a reported case of a skill failing to activate when it should have, and we want a deterministic post-hoc check rather than a guess.

**Sketch:** add a `tests/skill-activation-audit.sh` script that reads the state JSONL and reports counts per skill over a window, plus a `lib/skills-core.js` helper to surface "expected but not invoked" patterns in a session. Strictly local; never transmitted.

## Brainstorming cost-control gate

**Status:** considered, not landed.

**Why not yet:** `brainstorming` can theoretically spiral when the user keeps answering questions. In practice this is rarely cited as a problem — adaptive batching plus the new self-challenge round in v5.4.0 already cap most runaway sessions. Adding a hard upper bound on rounds would impose process tax on a problem we have not actually observed.

**Trigger to land:** if a user reports a brainstorm that exceeded N round-trips without converging, OR if metrics from the telemetry roadmap entry above show an outlier distribution.

**Sketch:** soft cap at 5 question-batches; on exceeding, agent forcibly proposes the best-current-approximation design and asks the user to either approve, refine, or explicitly extend the budget. Lives as a single section in `brainstorming/SKILL.md`, not a new skill.

## Cross-skill consistency invariants (test extension)

**Status:** considered, not landed in v5.4.0.

**Why not yet:** several skills now reference each other's filenames and steps (`finishing-a-development-branch` Step 1c is cited from at least three places; `runtime-launch-validation` triggers are referenced from `writing-plans` and `adversarial-design-review`; `requesting-code-review`'s bug-class checklist is cited from `team-conventions.md`). A rename or step-renumbering breaks silently. Not worth blocking v5.4.0 for, but worth a small follow-up because the surface area for silent breakage just grew.

**Trigger to land:** next time a cross-skill reference breaks in review, OR the next skill PR after v5.4.0.

**Sketch:** extend `tests/skill-content-grep.sh` (or add a sibling `tests/skill-cross-refs.sh`) that:

1. Greps every `Step \d[a-z]?` and `# .*` heading reference across `skills/*.md` and `agents/*.md`.
2. For each `<skill>/SKILL.md` Step-N reference, verifies the target heading exists in the cited skill.
3. Emits actionable failures with both citing and target file paths.

Cheap, deterministic, removes a class of silent-rot bugs. The grep guard infrastructure already in place is the right place to add it.

## Out of scope (not adopted)

These were considered and explicitly rejected during the v5.4.0 evaluation:

- **Heavy adversarial debate during brainstorming** — risks turning the user's design conversation into a multi-agent debate they didn't ask for. The v5.4.0 lightweight self-challenge is the lighter alternative we picked instead.
- **Hostile / steelman-the-rejection reviewer framing** — theatrical, low signal. The "find ≥3 things wrong" framing from `requesting-code-review` is sharp enough.
- **Separate `pre-mortem` skill** — folded into `adversarial-design-review`'s "Missing failure modes" bug class instead of being a standalone skill. One artifact, one pass, less skill sprawl.
