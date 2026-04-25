---
name: subagent-driven-development
description: Use when executing implementation plans with independent tasks in the current session
---

# Subagent-Driven Development

Execute a plan using either a role-based subagent team or sequential subagents, with two-stage review: spec compliance first, then code quality.

**Core principle:** Structured roles + two-stage review (spec then quality) = high-quality, parallel execution.

## Execution Mode

<host: claude-code>

**Default: Agent Teams** — when the TeamCreate tool is available and
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is set, use persistent parallel agents with a shared
task list. Each agent claims work independently; the team-lead orchestrates only.

**Fallback: Sequential Subagents** — when Agent Teams is not available, dispatch one subagent
per task. See the [Sequential Mode](#sequential-mode) section below.

```
# Runtime check
# If TeamCreate tool exists in your tool list → use Agent Teams
# Otherwise → use Sequential Mode
```

</host>

<host: codex>

**Sequential Subagents** — Codex does not provide a shared task list or persistent team
chat. Spawn one subagent per task using Codex's native subagent tool, passing the full plan
task text in the prompt. Use git branch names and PR diffs as the coordination surface
instead of a task queue. See [Sequential Mode](#sequential-mode).

</host>

---

<host: claude-code>

## Agent Teams Mode

### Team Structure

```dot
digraph team {
    rankdir=LR;
    Lead [label="team-lead (frontier)\nOrchestration only" shape=box style=filled fillcolor=lightyellow];
    I1 [label="implementer-1\n(balanced)" shape=box];
    I2 [label="implementer-2\n(balanced)" shape=box];
    SR [label="spec-reviewer\n(balanced)" shape=box];
    CR [label="code-reviewer\n(balanced)" shape=box];

    Lead -> I1 [label="assign tasks"];
    Lead -> I2 [label="assign tasks"];
    I1 -> SR [label="DM: ready"];
    I2 -> SR [label="DM: ready"];
    SR -> CR [label="DM: spec OK"];
    SR -> I1 [label="DM: issues" style=dashed];
    SR -> I2 [label="DM: issues" style=dashed];
    CR -> I1 [label="DM: quality issues" style=dashed];
    CR -> I2 [label="DM: quality issues" style=dashed];
}
```

### Team Sizing

| Plan Tasks | Implementers |
|-----------|-------------|
| 1-5       | 1           |
| 6-15      | 2           |
| 16+       | 3           |

### Step-by-Step Process

**1. Read plan and create team:**

```
TeamCreate({ team_name: "<project-name>", description: "<goal>" })
```

Read the plan file, extract all tasks with full text.

**2. Create tasks in shared task list:**

For each plan task, create a TaskCreate with:
- `subject`: "Implement: <task name>"
- `description`: Full task text from plan + design doc reference + context
- `activeForm`: "Implementing <task name>"

Then create corresponding review tasks:
- "Review spec: <task name>" (blockedBy: implement task)
- "Review quality: <task name>" (blockedBy: spec review task)

**3. Spawn teammates:**

Spawn each teammate with the Agent tool using `team_name` and `name` parameters:

**Implementers** (use `./implementer-prompt.md` as base):
```
Agent tool:
  team_name: "<project-name>"
  name: "implementer-1"
  subagent_type: "general-purpose"
  model: "balanced"
  prompt: |
    You are implementer-1 on team <project-name>.

    ## Your Role
    Claim implementation tasks from the task list, implement them using TDD,
    commit your work, then DM spec-reviewer when ready for review.

    ## Workflow
    1. Check TaskList for available unblocked tasks with "Implement:" prefix
    2. Claim one with TaskUpdate (set owner to your name, status to in_progress)
    3. Implement the task following TDD (see task description for full spec)
    4. Self-review per `agents/team-conventions.md`
    5. Commit your work
    6. DM spec-reviewer: "Task N ready for review" with summary of what you built
    7. Wait for reviewer feedback — fix issues if any
    8. After code-reviewer approves, check TaskList for next task
    9. When no tasks remain, report to team-lead

    ## Design Document
    Reference: <design-doc-path>

    ## Team Conventions
    Follow `agents/team-conventions.md` for all implementer discipline rules.
    For version-skew audit requirements, also follow
    `skills/finishing-a-development-branch/SKILL.md` Step 1c.

    ## Important
    - Work in the project directory: <working-dir>
    - Use `isolation: "worktree"` is NOT needed — you're already in an isolated context
    - Always commit your work before requesting review
    - If you have questions, DM the team-lead — don't guess
```

**Spec Reviewer** (use `./spec-reviewer-prompt.md` as base):
```
Agent tool:
  team_name: "<project-name>"
  name: "spec-reviewer"
  subagent_type: "general-purpose"
  model: "balanced"
  prompt: |
    You are spec-reviewer on team <project-name>.

    ## Your Role
    When implementers DM you that a task is ready, verify the implementation
    matches the spec exactly — nothing missing, nothing extra.

    ## Workflow
    1. Wait for DMs from implementers
    2. When you receive "Task N ready for review":
       a. Read the task description from TaskGet
       b. Read the actual code the implementer wrote
       c. Compare implementation to spec line by line
       d. Check: missing requirements? Extra features? Misunderstandings?
    3. If issues found:
       - DM implementer with specific issues (file:line references)
       - Wait for them to fix and re-notify you
       - Re-review
    4. If spec compliant:
       - DM code-reviewer: "Task N spec-approved, ready for quality review"
       - Mark the "Review spec:" task as completed via TaskUpdate

    ## Design Document
    Reference: <design-doc-path>

    ## Team Conventions
    See `agents/team-conventions.md` for scope-vs-dispatch compliance gate
    and review discipline every spec-reviewer applies.
```

**Code Reviewer** (use `./code-quality-reviewer-prompt.md` as base):
```
Agent tool:
  team_name: "<project-name>"
  name: "code-reviewer"
  subagent_type: "general-purpose"
  model: "balanced"
  prompt: |
    You are code-reviewer on team <project-name>.

    ## Your Role
    When spec-reviewer DMs you that a task is spec-approved, review code quality.

    ## Workflow
    1. Wait for DMs from spec-reviewer
    2. When you receive "Task N spec-approved":
       a. Read the implementation code
       b. Review: naming, structure, tests, error handling, patterns
       c. Categorize issues: Critical / Important / Minor
    3. If Critical or Important issues:
       - DM the implementer who built it with specific issues
       - Wait for fix and re-review
    4. If approved:
       - Mark the "Review quality:" task as completed via TaskUpdate
       - DM team-lead: "Task N fully approved"

    ## Team Conventions
    See `agents/team-conventions.md` for adversarial framing and the
    per-finding inline output format. For the bug-class checklist and
    verdict vocabulary, see `skills/requesting-code-review/SKILL.md`.
```

**4. Monitor and steer:**

As team-lead, your job is now orchestration:
- Monitor task completions via TaskList
- Reassign work if an implementer is stuck (DM them)
- Answer implementer questions (they'll DM you)
- Track overall progress
- When all tasks complete → proceed to finishing

**5. Shutdown and finish:**

When all tasks are complete:
```
SendMessage({ type: "shutdown_request", recipient: "implementer-1", content: "All tasks done" })
SendMessage({ type: "shutdown_request", recipient: "implementer-2", content: "All tasks done" })
SendMessage({ type: "shutdown_request", recipient: "spec-reviewer", content: "All tasks done" })
SendMessage({ type: "shutdown_request", recipient: "code-reviewer", content: "All tasks done" })
```

Wait for all shutdown approvals, then:
```
TeamDelete()
```

Invoke `superpowers:finishing-a-development-branch`.

</host>

---

## Sequential Mode

Use when Agent Teams is not available, or on any host that does not provide persistent
parallel agents. One subagent handles one task at a time; reviews happen between tasks.

### Process

For each task in the plan:

1. **Dispatch implementer subagent** — provide the full task text, the design doc path, and
   the working directory in the prompt. Use `./implementer-prompt.md` as the base template.
2. **Answer questions** if the implementer surfaces blockers.
3. Implementer implements, tests, commits, and self-reviews per `agents/team-conventions.md`.
4. **Dispatch spec reviewer** — provide the task text and the implementer's commit SHA.
   Use `./spec-reviewer-prompt.md` as the base template.
5. If spec issues found → implementer fixes → re-review until spec-approved.
6. **Dispatch code quality reviewer** — use `./code-quality-reviewer-prompt.md`.
7. If quality issues found → implementer fixes → re-review until approved.
8. Mark task complete and move to the next.

After all tasks: invoke `superpowers:finishing-a-development-branch`.

<host: codex>

### Codex Coordination Notes

Codex subagents do not share a task list. Use these conventions instead:

- **Task identity**: pass `task_id: N` and the full task text in the prompt so each subagent
  knows exactly what it owns. Do not rely on a shared queue.
- **Handoff surface**: use git branch names (`task-N-<slug>`) and PR diffs as the review
  surface. The spec-reviewer and code-reviewer read the PR diff, not a task record.
- **Progress tracking**: after each task completes, record completion in the orchestrating
  agent's own context (e.g., a local list) rather than a shared task table.
- **No DM channel**: pass reviewer output back to the orchestrator as a return value; the
  orchestrator decides whether to re-dispatch the implementer.

</host>

---

## Red Flags

**Never:**
- Start implementation on main/master without explicit user consent
- Skip reviews (spec compliance OR code quality)
- Proceed with unfixed issues
- Make subagents/teammates read plan files — provide full text in the prompt instead
- Skip scene-setting context in any subagent prompt
- Start code quality review before spec compliance passes
- Move to next task while either review has open issues

<host: claude-code>
- In Agent Teams mode: let the team-lead implement (orchestration only)
</host>

**If reviewer finds issues:**
- Implementer fixes them
- Reviewer reviews again
- Repeat until approved
- Don't skip the re-review

---

## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** - REQUIRED: Set up isolated workspace before starting
- **superpowers:writing-plans** - Creates the plan this skill executes
- **superpowers:alignment-check** - Verifies plan matches design (autonomous mode)
- **superpowers:finishing-a-development-branch** - Complete development after all tasks

**Subagents/teammates should use:**
- **superpowers:test-driven-development** - Follow TDD for each task

**Alternative workflow:**
- **superpowers:executing-plans** - Use for parallel session instead of same-session execution
