#!/usr/bin/env bash
# tests/skill-content-grep.sh
# Fails if forbidden host-specific tokens appear in skill text outside an
# allowed context (<host: claude-code> block, fenced code block,
# model-tiers table, or an explicitly allowed file).
#
# Usage:
#   ./tests/skill-content-grep.sh          # scan all files, exit 1 on violations
#   ./tests/skill-content-grep.sh 2>&1 | grep some-skill   # scoped check

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# Tokens that must not appear in host-neutral skill text.
# These are Claude-Code-specific tool names or model-brand names that make
# skills non-portable to other hosts.
# Model-brand names are listed in both title-case and lowercase forms because
# skills may reference them in prose ("Use Sonnet") or YAML ("model: sonnet").
TOKENS=(
  TodoWrite TaskCreate TaskUpdate TaskList TaskGet
  TeamCreate TeamDelete SendMessage EnterPlanMode
  Sonnet Opus Haiku
  sonnet opus haiku
)

# Files where these tokens are explicitly permitted.
# Note: tests/ is not scanned by the find command below, so only add paths
# under skills/ or agents/ here.
ALLOWED_FILES=(
  "agents/model-tiers.md"
  # Claude-specific reference docs under writing-skills/: these discuss
  # Anthropic model names and Claude-only tools as subject matter and are
  # not portable skill bodies.
  "skills/writing-skills/anthropic-best-practices.md"
  "skills/writing-skills/persuasion-principles.md"
)

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
      #   - Skips ONLY exclusive <host: claude-code> blocks (no other hosts).
      #     A block like <host: codex, claude-code> is NOT skipped because its
      #     content is also shown to codex users who must not see Claude-only tokens.
      #       <host: claude-code>          → skip
      #       <host: codex, claude-code>   → do NOT skip
      #       <host: codex, opencode>      → do NOT skip
      #   - Skips fenced code blocks.  A fence delimiter is any line whose
      #     non-whitespace content is 3+ backticks followed by an optional
      #     info-string (alphanumeric / _+-) and optional trailing whitespace.
      #     Opening and closing fences must use the same backtick width, so
      #     nested fences (4-backtick outer / 3-backtick inner example) are
      #     handled correctly without desynchronising the toggle.
      #   - Markers must occupy the whole line (only optional whitespace
      #     around the tag). A marker with trailing text is NOT recognised.
      #   - Emits "LINENO:content" for every non-skipped line.
      annotated="$(awk '
        BEGIN { skip = 0; fence_width = 0; ln = 0 }
        {
          ln++
          # Detect fence delimiter: strip leading whitespace, count backticks,
          # check remainder is a valid info-string + optional trailing space.
          stripped = $0
          sub(/^[[:space:]]*/, "", stripped)
          if (stripped ~ /^```/) {
            n = 0
            s = stripped
            while (length(s) > 0 && substr(s, 1, 1) == "`") { n++; s = substr(s, 2) }
            if (s ~ /^[a-zA-Z0-9_+-]*[[:space:]]*$/) {
              if (fence_width == 0) { fence_width = n; next }
              if (n == fence_width)  { fence_width = 0; next }
              # Different width inside a fence — treat as content.
            }
          }
          if (fence_width > 0) { next }
          if (/^[[:space:]]*<host:[[:space:]]*claude-code[[:space:]]*>[[:space:]]*$/) { skip = 1; next }
          if (/^[[:space:]]*<\/host>[[:space:]]*$/) { skip = 0; next }
          if (!skip) { print ln ":" $0 }
        }
      ' "$file")"

      for token in "${TOKENS[@]}"; do
        # Whole-word grep. || true prevents non-zero exit on no matches from
        # propagating as a script failure.
        matches="$(printf '%s\n' "$annotated" | grep -w "$token" || true)"
        if [ -n "$matches" ]; then
          printf '%s\n' "$matches" | sed "s|^|$file:|" >> "$tmp"
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
