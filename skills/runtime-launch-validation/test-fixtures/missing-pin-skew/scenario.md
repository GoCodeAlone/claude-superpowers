# Missing-pin runtime skew

A repository pins `tooling` at v1.2 in build pipeline yaml. The
runtime depends on `engine`, which is at v1.6 elsewhere in the repo.

`tooling@v1.2` and `engine@v1.6` use incompatible plugin discovery
layouts: v1.6 expects plugins at `data/plugins/<name>/<name>`,
v1.2 expects them at `plugins/<name>` (legacy).

A change bumps `engine` to v1.7. All unit tests pass — they don't
exercise plugin discovery paths because they mock those out.

## Without runtime-launch-validation

PR opens. Reviewer approves. Merge. Deploy. **Production fails at
startup**: engine looks for plugins at the new path, doesn't find
them (build pipeline put them at the old path), falls back to
fetching from a network registry that doesn't resolve, panics.

Total time to fix: hours of triage + emergency hotfix.

## With runtime-launch-validation

PR's "finishing-a-development-branch Step 1b" triggers because the
change touched a version pin. The implementer:

- Builds the runtime artifact locally.
- Launches it (`docker run`).
- Observes startup logs.
- Failure-signature scrape catches "fetch from remote: lookup ...
  no such host".
- Verdict: FAIL.
- Implementer investigates: realizes tooling@v1.2 needs to bump too.
- Bumps both pins, re-launches, scrape clean.
- PR opens with transcript already pasted.

Total time to fix: <10 minutes.
