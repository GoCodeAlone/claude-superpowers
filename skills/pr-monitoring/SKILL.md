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

Run a `balanced`-tier agent that monitors the PR in a loop until all CI checks pass and no unresolved reviews remain.

<host: claude-code>
Use the Agent tool to run the monitor in the background:

````
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

    Repeat the Monitor Loop until exit conditions are met:

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

    Use GraphQL to fetch review threads — this gives both the thread IDs needed
    for resolution and the author login needed to detect bots:

    ```bash
    gh api graphql -f query='
      query($owner: String!, $repo: String!, $number: Int!) {
        repository(owner: $owner, name: $repo) {
          pullRequest(number: $number) {
            reviewThreads(first: 100) {
              nodes {
                id
                isResolved
                isOutdated
                comments(first: 1) {
                  nodes { author { login } body }
                }
              }
            }
          }
        }
      }
    ' -f owner=<owner> -f repo=<repo> -F number=<number>
    ```

    Also fetch any "CHANGES_REQUESTED" reviews:

    ```bash
    gh api repos/<owner>/<repo>/pulls/<number>/reviews \
      --jq '.[] | select(.state == "CHANGES_REQUESTED") | {id, body, user: .user.login}'
    ```

    **Bot detection:** treat a commenter as a bot if their login ends in `[bot]`
    or matches a known review bot (e.g. `copilot`, `github-advanced-security`,
    `datadog`, `codeclimate`, `sonarcloud`). Apply the same address-then-resolve
    flow to bot comments as to human comments.

    **If new unresolved, non-outdated threads are found:**
    a. Read the comment carefully
    b. Implement the requested change
    c. Run tests to verify
    d. Commit and push
    e. Reply to the comment: "Addressed in <commit-sha>"
    f. **Resolve the thread** (required for all comments, especially bot comments):
       ```bash
       gh api graphql -f query='
         mutation($threadId: ID!) {
           resolveReviewThread(input: {threadId: $threadId}) {
             thread { isResolved }
           }
         }
       ' -f threadId="<thread-id>"
       ```

    **Safety:** Max 3 revision rounds per review comment. After 3, reply:
    "I've attempted to address this feedback but may need clarification. Flagging for manual review."
    Then resolve the thread so it does not block the exit condition.

    ### 3. Check Exit Conditions

    Exit when ALL of:
    - All CI checks passing (green)
    - No unresolved review comments
    - No pending "changes requested" reviews

    On exit:
    - If the PR is merged AND base-branch CI is green for the merge commit AND a design + plan exist in `docs/plans/` for this branch, invoke `superpowers:post-merge-retrospective` to produce a retro in `docs/retros/`. This is the autonomous closing-the-loop step.
    - If the PR is closed without merge, skip the retrospective and exit cleanly.
    - Report final status either way.

    ### 4. Wait Between Checks

    Sleep 60 seconds between check cycles. Do not poll more frequently.
````
</host>

<host: codex, opencode, cursor>

Use your host's equivalent mechanism to periodically poll the following in a loop:
- `gh pr checks <number>` — fix any failing CI checks
- GraphQL `reviewThreads` query — fetch unresolved, non-outdated threads; address each one, reply "Addressed in <commit-sha>", then resolve the thread via the `resolveReviewThread` GraphQL mutation. Apply this to bot comments (any login ending in `[bot]`, or known bots such as `copilot`, `github-advanced-security`, `datadog`) the same as human comments.
- `gh api repos/<owner>/<repo>/pulls/<number>/reviews` — handle any "CHANGES_REQUESTED" reviews

Continue until all checks pass, no unresolved inline threads remain, and no "changes requested" reviews are pending.

When the PR has merged with green base-branch CI and a design + plan exist in `docs/plans/` for this branch, invoke `superpowers:post-merge-retrospective` to write a retro in `docs/retros/`. If the PR was closed without merge, skip the retro and exit cleanly.

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

**Calls:**
- `superpowers:post-merge-retrospective` — on its own clean exit when the PR has merged with green base-branch CI

**Uses:**
- `gh` CLI for all GitHub operations
- `superpowers:systematic-debugging` principles for CI failure analysis
