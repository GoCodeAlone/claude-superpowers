---
name: pr-monitoring
description: Use after creating a PR to automatically monitor CI checks and review comments, fixing issues and pushing updates autonomously
---

# PR Monitoring

## Overview

Monitor a pull request for CI failures and review comments, automatically fixing issues and pushing updates. Runs as a background agent after autonomous PR creation.

**Core principle:** The PR is the final quality gate. Monitor it, fix what breaks, respond to feedback — all without human intervention.

## When to Use

Invoked automatically by `finishing-a-development-branch` in autonomous mode after creating a PR. Can also be invoked manually for any open PR.

## The Process

Spawn a background `balanced`-tier agent that monitors the PR in a loop.

<host: claude-code>
```
Agent tool (general-purpose, model: balanced, run_in_background: true):
  description: "Monitor PR #N for CI and reviews"
  prompt: |
    You are monitoring PR #<number> on <repo> and automatically fixing issues.

    ## Setup

    PR URL: <url>
    Branch: <branch>
    Base: <base-branch>
    Design doc: <path>
    Plan doc: <path>

    ## Monitor Loop

    Repeat until exit conditions met:

    ### 1. Check CI Status

    ```bash
    gh pr checks <number> --json name,state,conclusion
    ```

    **If any check fails:**
    a. Read the failure logs: `gh run view <run-id> --log-failed`
    b. Identify the root cause
    c. Fix the issue in the codebase
    d. Run the relevant tests locally to verify
    e. Commit and push:
       ```bash
       git add <specific-files>
       git commit -m "fix: address CI failure in <check-name>"
       git push
       ```
    f. Wait 60s, re-check

    **Safety:** Max 5 fix attempts per unique CI failure. After 5, comment on the PR:
    "Unable to automatically resolve CI failure in <check-name> after 5 attempts. Manual intervention needed."

    ### 2. Check Review Comments

    ```bash
    gh api repos/<owner>/<repo>/pulls/<number>/comments --jq '.[] | select(.position != null) | {id, body, path, line: .original_line, user: .user.login}'
    gh api repos/<owner>/<repo>/pulls/<number>/reviews --jq '.[] | select(.state == "CHANGES_REQUESTED") | {id, body, user: .user.login}'
    ```

    **If new unresolved comments found:**
    a. Read the comment carefully
    b. Implement the requested change
    c. Run tests to verify
    d. Commit and push
    e. Reply to the comment: "Addressed in <commit-sha>"

    **Safety:** Max 3 revision rounds per review comment. After 3, reply:
    "I've attempted to address this feedback but may need clarification. Flagging for manual review."

    ### 3. Check Exit Conditions

    Exit when ALL of:
    - All CI checks passing (green)
    - No unresolved review comments
    - No pending "changes requested" reviews

    On exit, report final status.

    ### 4. Wait Between Checks

    Sleep 60 seconds between check cycles. Do not poll more frequently.
```
</host>

## Safety Limits

| Limit | Value | On Exceed |
|-------|-------|-----------|
| CI fix attempts per failure | 5 | Comment on PR, stop fixing that check |
| Revision rounds per comment | 3 | Reply with escalation, stop revising |
| Total monitoring duration | 30 min | Exit with status report |
| Push frequency | Max 1 per 60s | Queue fixes, batch push |

## Integration

**Called by:**
- `finishing-a-development-branch` (autonomous mode) — after PR creation

**Uses:**
- `gh` CLI for all GitHub operations
- `superpowers:systematic-debugging` principles for CI failure analysis
