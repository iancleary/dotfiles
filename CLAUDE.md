# Claude Code Reference

Context for Claude Code when working with this dotfiles repository.

## Repository Purpose

Personal dotfiles managing shell configs across platforms:
- **Windows/Git Bash**: bash with oh-my-bash
- **macOS/Linux**: zsh with Powerlevel10k

## Quick Commands

```bash
./sync-dotfiles.sh status   # Check sync status
./sync-dotfiles.sh list     # See tracked files
./sync-dotfiles.sh pull     # Backup from $HOME into repo
./sync-dotfiles.sh push     # Restore from repo to $HOME
just help                   # Task runner recipes
```

## Key Components

| Component | Location | Details |
|-----------|----------|---------|
| Sync utility | `sync-dotfiles.sh` | [docs/sync-utility.md](docs/sync-utility.md) |
| Shell configs | `.bashrc`, `.zshrc`, `.common/` | [docs/shell-configs.md](docs/shell-configs.md) |
| Claude Code | `.claude/` | [docs/agent-integration.md](docs/agent-integration.md) |
| Codex CLI | `.codex/` | [docs/agent-integration.md](docs/agent-integration.md) |
| Shared skills | `.agents/` | [docs/agent-integration.md](docs/agent-integration.md) |
| Identity files | `.claude/*.md`, `.codex/*.md` | [docs/agent-integration.md](docs/agent-integration.md) |
| Task runner | `justfile` | [docs/sync-utility.md](docs/sync-utility.md) |

## Common Tasks

```bash
# Add a new single dotfile
# Edit sync-dotfiles.sh → add to COMMON_DOTFILES[] or DOTFILES[]

# Add a multi-file skill directory
# Edit sync-dotfiles.sh → add to SYNCED_SKILL_DIRS[]

# Add a new skill
# See docs/agent-integration.md → "Adding a New Skill"
```

## Git Context

**Default branch**: `main`

**Recent PRs (merged)**:
- #10: Dynamic skill dir syncing for slidev
- #9: Add slidev to sync
- #8: Implement OpenClaw improvement suggestions
- #7: Add Slidev skill
- #6: Add Playwright MCP to Claude Code and Codex
- #5: OpenClaw improvements
- #4: Update README.md and CLAUDE.md
- #3: git-push-pr skill + COMMON_DOTFILES
- #2: Interview skill

## Where to Look

- `docs/` — Deep dives on sync utility, shell configs, agent integration
- `.common/` — Shared shell aliases and utilities
- `.claude/skills/` — Claude Code skill definitions
- `.agents/skills/` — Cross-tool shared skills
- `.codex/` — Codex CLI config and policies
- `justfile` — Task runner recipes
