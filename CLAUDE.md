# Claude Code Reference

Context for Claude Code when working with this dotfiles repository.

## Repository Purpose

Personal dotfiles managing shell configs across platforms:
- **Windows/Git Bash**: bash with oh-my-bash
- **macOS/Linux**: zsh with Powerlevel10k

## Key Components

### 1. Sync Utility (`sync-dotfiles.sh`)

Bidirectional file syncing between `$HOME` and this repo.

**Commands**: `pull` (backup), `push` (restore), `status`, `diff <file>`, `list`, `add`, `help`

**File tracking**:
- `COMMON_DOTFILES[]`: All platforms (shared utilities, Claude/Codex configs, agent skills)
- `DOTFILES[]`: OS-specific (bash on Windows, zsh on macOS/Linux)
- `SYNCED_SKILL_DIRS[]`: Dynamically discovered skill directories (files auto-tracked)

**OS detection**: `$OSTYPE` → selects platform-specific files.

**Safety**: Timestamped backups before overwrite, `cmp -s` skip for identical files.

### 2. Shell Configurations

#### Bash (.bashrc, .bash_profile)
- oh-my-bash with "font" theme
- Sources `.common/` utilities
- Cargo tools: just, bat, rg, zoxide, delta
- SSH key auto-loading, NVM, Terraform, Go, Python/uv

#### Zsh (.zshrc, .zshenv, .zprofile, .p10k.zsh)
- Powerlevel10k instant prompt (MUST stay near top of .zshrc)
- Delegates config to `.zshenv`/`.zprofile`

#### Git (.gitconfig)
- delta as pager, zdiff3 merge conflict style
- User: iancleary / iancleary@hey.com

### 3. Shared Utilities (.common/)

**aliases.sh**: eza (l/ll/la/ls/left), git (g/gc/gf/gpoc/cg), editors (n=nvim), pnpm/bun shortcuts, docker (d/dc/di), cargo/just (c/j), history grep (hg)

**agents-git-trees.sh**:
- `ga [branch]`: Creates worktree at `../{branch}--{repo-name}`, switches to it, returns 1 to trigger cd
- `gd`: Deletes current worktree + branch, uses `gum confirm` for safety

### 4. Claude Code (.claude/)

**settings.json**: Permissions (allow git/cargo/gh/file ops, deny cargo publish), rust-analyzer-lsp plugin, Playwright MCP server

**Skills** (7 total):
| Skill | Description | Tools |
|-------|-------------|-------|
| cargo-just | Rust/just task runner | Bash, Read, Glob |
| code-review | Code review for quality/bugs/style | Bash, Read, Glob, Grep |
| git-push-pr | Git add → commit → push → PR create/update | Bash, Read, Glob, Grep |
| grill | Interrogate idea before planning | AskUserQuestion, Write |
| interview | In-depth spec creation | AskUserQuestion, Write |
| slidev | Developer slide presentations (symlink → .agents) | — |
| test-writer | Generate tests for existing code | Bash, Read, Write, Glob, Grep |

### 5. Shared Agent Skills (.agents/)

Cross-tool skills shared between Claude Code, Codex, and other agents:
- `.agents/skills/grill/` — shared grill skill
- `.agents/skills/slidev/` — Slidev presentation skill (Claude Code symlinks to this)

### 6. Codex CLI (.codex/)

**config.toml**: Playwright MCP server (`npx @playwright/mcp@latest`)

**user-policy.rules**: Tiered command approval:
- **allow**: Read-only (ls, cat, rg, git status/diff/log, cargo check/clippy/fmt --check, eza, bat, etc.)
- **prompt**: Mutating (git add/commit/push, cargo build/test/run, npm/pnpm install, docker compose up/down, tailscale serve, curl/wget, just tasks)
- **forbidden**: Dangerous (sudo, rm -rf /, cargo publish, mkfs, shutdown, reboot)

### 7. Task Runner (justfile)

Recipes: `help`, `pull`, `push`, `status` — wrappers for `sync-dotfiles.sh`

## File Modification Guidelines

### sync-dotfiles.sh
- File lists: `COMMON_DOTFILES[]`, `DOTFILES[]`, `SYNCED_SKILL_DIRS[]`
- For new skills with multiple files, add the dir to `SYNCED_SKILL_DIRS[]` for auto-discovery
- For single files, add directly to `COMMON_DOTFILES[]`
- Don't modify core sync logic (cmd_pull/cmd_push) without care

### Shell configs
- **Bash**: Keep oh-my-bash setup at top, source `.common/` before tools
- **Zsh**: Powerlevel10k instant prompt MUST stay near top of `.zshrc`; actual config goes in `.zshenv`/`.zprofile`

### Adding a new skill
1. Create `.claude/skills/<name>/SKILL.md` (or `.agents/skills/<name>/` if shared)
2. Add to `COMMON_DOTFILES[]` or `SYNCED_SKILL_DIRS[]` in sync-dotfiles.sh
3. If shared, symlink from `.claude/skills/<name>` → `../../.agents/skills/<name>`

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

## Common Tasks

```bash
# Check sync status
./sync-dotfiles.sh status

# Add a new single dotfile
# Edit sync-dotfiles.sh → add to COMMON_DOTFILES[] or DOTFILES[]

# Add a multi-file skill directory
# Edit sync-dotfiles.sh → add to SYNCED_SKILL_DIRS[]

# Test what would sync
./sync-dotfiles.sh list
```
