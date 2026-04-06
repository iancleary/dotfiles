# Agent Integration

## Identity Files (.claude/ and .codex/)

Both tool directories contain three identity files:
- **agents.md**: Operating manual — autonomy levels, git conventions, toolchains, safety
- **principles.md**: Decision-making heuristics — build vs. plan, friction as signal, correctness over convenience
- **soul.md**: Voice and character — direct, casual, competent, opinionated

Claude Code versions are more detailed; Codex versions are condensed for that tool's context.

## Claude Code (.claude/)

**settings.json**: Permissions (allow git/cargo/gh/file ops, deny cargo publish) and enabled plugins

**Skills** (7 total):

| Skill | Description | Tools |
|-------|-------------|-------|
| cargo-just | Rust/just task runner | Bash, Read, Glob |
| code-review | Code review for quality/bugs/style | Bash, Read, Glob, Grep |
| git-push-pr | Git add → commit → push → PR create/update | Bash, Read, Glob, Grep |
| grill | Interrogate idea before planning | AskUserQuestion, Write |
| interview | In-depth spec creation | AskUserQuestion, Write |
| slidev | Developer slide presentations | — |
| test-writer | Generate tests for existing code | Bash, Read, Write, Glob, Grep |

## Codex Agent Skills (.agents/)

Skills used by Codex CLI and other non-Claude agents:
- `.agents/skills/git-push-pr/` — git workflow automation
- `.agents/skills/grill/` — interrogate ideas before planning
- `.agents/skills/slidev/` — Slidev presentation skill

## Codex CLI (.codex/)

**config.toml**: Codex CLI config. No MCP servers are configured by default.

**user-policy.rules**: Tiered command approval:
- **allow**: Read-only (ls, cat, rg, git status/diff/log, cargo check/clippy/fmt --check, eza, bat, etc.)
- **prompt**: Mutating (git add/commit/push, cargo build/test/run, npm/pnpm install, docker compose up/down, tailscale serve, curl/wget, just tasks)
- **forbidden**: Dangerous (sudo, rm -rf /, cargo publish, mkfs, shutdown, reboot)

## Adding a New Skill

1. Create `.claude/skills/<name>/SKILL.md` for Claude Code, or `.agents/skills/<name>/SKILL.md` for Codex
2. Both directories are in `SYNCED_SKILL_DIRS[]` in sync-dotfiles.sh, so new files are auto-discovered
