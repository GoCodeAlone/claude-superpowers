#!/usr/bin/env bash
# tests/skill-content-grep.sh
# Fails if forbidden host-specific tokens appear in skill text outside an
# allowed context (<host: claude-code> block, model-tiers table, or an
# explicitly allowed file).
#
# Usage:
#   ./tests/skill-content-grep.sh          # scan all files, exit 1 on violations
#   ./tests/skill-content-grep.sh 2>&1 | grep some-skill   # scoped check

set -u

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# Tokens that must not appear in host-neutral skill text.
# These are Claude-Code-specific tool names or model-brand names that make
# skills non-portable to other hosts.
TOKENS=(
  TodoWrite TaskCreate TaskUpdate TaskList TaskGet
  TeamCreate TeamDelete SendMessage EnterPlanMode
  Sonnet Opus Haiku
)

# Files where these tokens are explicitly permitted.
ALLOWED_FILES=(
  "agents/model-tiers.md"
  "tests/skill-content-grep.sh"
)

fail=0
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

# Find all markdown files under skills/ and agents/.
find skills agents -type f -name '*.md' -print0 \
  | while IFS= read -r -d '' file; do
      # Skip explicitly allowed files.
      for allowed in "${ALLOWED_FILES[@]}"; do
        if [ "$file" = "$allowed" ]; then
          continue 2
        fi
      done

      # Single-pass AWK:
      #   - Tracks original line numbers so error output cites source locations.
      #   - Skips <host: ...> blocks where "claude-code" appears anywhere in the
      #     (possibly comma-separated) host list, e.g.:
      #       <host: claude-code>          → skip
      #       <host: codex, claude-code>   → skip
      #       <host: codex, opencode>      → do NOT skip
      #   - Emits "LINENO:content" for every non-skipped line.
      annotated="$(awk '
        BEGIN { skip = 0; ln = 0 }
        {
          ln++
          if (/^[[:space:]]*<host:/) {
            if (/claude-code/) { skip = 1; next }
          }
          if (/^[[:space:]]*<\/host>/) { skip = 0; next }
          if (!skip) { print ln ":" $0 }
        }
      ' "$file")"

      for token in "${TOKENS[@]}"; do
        # Whole-word grep. || true prevents non-zero exit on no matches from
        # propagating as a script failure.
        matches="$(printf '%s\n' "$annotated" | grep -w "$token" || true)"
        if [ -n "$matches" ]; then
          printf '%s\n' "$matches" | sed "s|^|$file:|" >> "$tmp"
          fail=1
        fi
      done
    done

if [ -s "$tmp" ]; then
  echo "FAIL: host-specific tokens found outside <host: claude-code> blocks:"
  cat "$tmp"
  exit 1
fi

echo "PASS: skill content is host-neutral or properly conditioned."
exit 0
