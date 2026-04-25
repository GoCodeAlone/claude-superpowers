# Cross-LLM Capability Coverage

Host-by-host capability matrix for the Superpowers skills system.

`✅` = fully supported  `⚠️` = partial / workaround required  `❌` = not supported

| Capability | Claude Code | Codex CLI | OpenCode | Cursor |
|---|---|---|---|---|
| SKILL.md import | ✅ native | ✅ native | ✅ native | ✅ plugin manifest defines skills/agents/commands/hooks; install via `/plugin-add superpowers` |
| Sub-agent dispatch | ✅ `Agent` tool | ✅ natural language | ⚠️ `@mention` to peer sessions | ❌ not documented |
| Agent Teams (persistent multi-agent DM) | ✅ experimental flag | ❌ | ❌ | ❌ |
| Background agents | ✅ `run_in_background` | ⚠️ thread-based; no explicit background flag | ❌ not documented | ❌ not documented |
| MCP servers | ✅ | ✅ `config.toml` | ✅ | ⚠️ partial |
| Slash commands | ✅ | ✅ 30+ built-ins incl. `/plan`, `/agent`, `/review` | ✅ | ✅ |
| Plan mode | ✅ `EnterPlanMode` + Shift-Tab | ✅ `/plan` slash | ⚠️ not documented; use prose planning | ⚠️ built-in Composer; not slash-invokable |
| Task list / TodoWrite | ✅ built-in | ❌ no documented equivalent | ⚠️ `update_plan` mapping (see `.opencode/INSTALL.md`) | ⚠️ unknown |
| AGENTS.md / project context | CLAUDE.md | AGENTS.md (+ `.override.md`) | AGENTS.md | n/a |
| Host declaration for skill conditionals | `Host: claude-code` in CLAUDE.md | `Host: codex` in `~/.codex/AGENTS.md` | `Host: opencode` in `~/.config/opencode/AGENTS.md` | n/a |
| Skill discovery path (user scope) | `~/.claude/skills/` | `~/.agents/skills/` | `~/.config/opencode/skills/` | via plugin (no manual symlink) |
| Model tier vocabulary | role names → `haiku`/`sonnet`/`opus` (see `agents/model-tiers.md`) | role names → `gpt-5.4-mini`/`gpt-5.4`/`gpt-5.5` | role names → host-pass-through | role names → host-pass-through |

## Notes

**Sub-agent dispatch (Codex):** Codex uses natural-language spawn ("spawn one agent per X") rather than an explicit `Agent` tool call. The `<host: codex>` blocks in skills provide the correct phrasing.

**Agent Teams:** The `TeamCreate` / `SendMessage` persistent-chat pattern is exclusive to Claude Code (experimental flag). Skills fall back to **Sequential Mode** (one sub-agent at a time) on all other hosts — see `skills/subagent-driven-development/SKILL.md`.

**Task list (Codex):** No built-in task-tracking tool is documented in Codex CLI. Skills that reference `TodoWrite` wrap those references in `<host: claude-code>` blocks; the host-neutral path uses prose checklists.

**Cursor:** The `.cursor-plugin/plugin.json` manifest defines `skills`, `agents`, `commands`, and `hooks`. Installation is via `/plugin-add superpowers` in the Cursor agent chat (same marketplace mechanism as Claude Code). Skill discovery path (user scope) is managed through the plugin; no manual symlink required.

## Related files

- `tests/cross-llm-coverage.md` — per-skill host-conditional vs host-neutral audit
- `tests/skill-content-grep.sh` — CI guard: fails if forbidden tokens appear outside `<host: claude-code>` blocks
- `.codex/INSTALL.md` — Codex setup instructions
- `.opencode/INSTALL.md` — OpenCode setup instructions
- `agents/model-tiers.md` — role-to-model-name resolution table (fast / balanced / frontier / coding-specialist)
