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

## gstack

**gstack** is Garry Tan's (YC President & CEO) open-source software factory.

13 specialist skills that work as a complete autonomous team: CEO, Eng Manager, Designer, Staff Engineer, QA Lead, Release Engineer, and more.

Use `/browse` from gstack for all web browsing. Never use `mcp__claude-in-chrome__*` tools.

**Available skills**:
- `/plan-ceo-review` — Rethink the product, find 10-star features
- `/plan-eng-review` — Lock architecture, draw data flows
- `/plan-design-review` — 80-item design audit + AI slop detection
- `/design-consultation` — Build complete design systems
- `/design-review` — Audit + fix design issues with atomic commits
- `/review` — Find production bugs, auto-fix obvious issues
- `/browse` — Agent with real eyes (Chromium browser)
- `/qa` — End-to-end testing in real browser, find & fix bugs
- `/qa-only` — Pure bug report without code changes
- `/setup-browser-cookies` — Import cookies for authenticated testing
- `/ship` — Atomic releases (sync, test, push, open PR)
- `/document-release` — Keep all docs in sync with code
- `/retro` — Weekly metrics, shipping streaks, test health
- `/gstack-upgrade` — Self-upgrade to latest version

**Deep dive**: [docs/gstack-integration.md](docs/gstack-integration.md)

For skill registration issues: `cd .claude/skills/gstack && ./setup`

---

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

- `docs/` — Deep dives on sync utility, shell configs, agent integration, gstack
- `docs/gstack-integration.md` — How gstack fits with your existing skills
- `.common/` — Shared shell aliases and utilities
- `.claude/skills/` — Claude Code skill definitions + gstack
- `.agents/skills/` — Codex CLI skills
- `.codex/` — Codex CLI config and policies
- `justfile` — Task runner recipes
