# dotfiles

Cross-platform shell configuration files for bash (Windows/Git Bash) and zsh (macOS/Linux).

## Overview

This repository manages dotfiles for multiple operating systems with a sync utility that handles bidirectional synchronization between your home directory and this repository.

## Features

- **Cross-platform support**: Bash configuration for Windows/Git Bash, Zsh for macOS/Linux
- **Bidirectional sync**: Pull from home to backup, push from repo to restore
- **Shell enhancements**: Modern CLI tools (eza, bat, delta, zoxide, just)
- **Git worktree helpers**: Functions for managing git worktrees efficiently
- **Claude Code integration**: Custom skills and Playwright MCP for enhanced development workflow
- **Codex CLI integration**: Command approval policies and MCP servers
- **Safe operations**: Automatic backups before overwriting files

## Quick Start

### Installation

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
```

### Restore dotfiles to your system

```bash
./sync-dotfiles.sh push    # or: just push
```

### Backup current dotfiles

```bash
./sync-dotfiles.sh pull    # or: just pull
```

### Check sync status

```bash
./sync-dotfiles.sh status  # or: just status
```

## Repository Structure

```
.
├── .bash_profile           # Bash profile (Windows/Git Bash)
├── .bashrc                 # Bash configuration with oh-my-bash
├── .zshrc                  # Zsh configuration with Powerlevel10k
├── .zshenv                 # Zsh environment variables
├── .zprofile               # Zsh profile
├── .p10k.zsh               # Powerlevel10k theme configuration
├── .gitconfig               # Global git configuration (delta pager, zdiff3)
├── .common/                # Shared shell utilities
│   ├── aliases.sh          # Shell aliases (eza, docker, git, etc.)
│   └── agents-git-trees.sh # Git worktree helper functions (ga/gd)
├── .claude/                # Claude Code configuration
│   ├── settings.json       # Permissions, plugins, MCP servers
│   └── skills/             # Custom Claude skills
│       ├── cargo-just/     # Smart Rust/just task runner
│       ├── code-review/    # Code review for quality, bugs, style
│       ├── git-push-pr/    # Git workflow automation
│       ├── grill/          # Relentless idea interrogation
│       ├── interview/      # In-depth spec creation
│       ├── slidev/         # Web-based slide creation (symlink → .agents)
│       └── test-writer/    # Test generation for existing code
├── .agents/                # Shared agent skills (cross-tool)
│   └── skills/
│       ├── grill/          # Shared grill skill
│       └── slidev/         # Shared Slidev skill
├── .codex/                 # Codex CLI configuration
│   ├── config.toml         # MCP servers (Playwright)
│   └── rules/
│       └── user-policy.rules  # Command execution approval rules
├── sync-dotfiles.sh        # Dotfile synchronization utility
├── justfile                # Task runner recipes
└── README.md
```

## Shell Configuration

### Bash (.bashrc)

For Windows/Git Bash:
- oh-my-bash framework with "font" theme
- Shared utilities from `.common/`
- Cargo/Rust tools: just, bat, rg, zoxide, delta
- SSH key auto-loading, NVM, Terraform, Go, Python/uv

### Zsh (.zshrc, .zshenv, .zprofile)

For macOS/Linux:
- Powerlevel10k prompt theme with instant prompt
- Shared utilities from `.common/`
- Same modern CLI tools as bash

### Git (.gitconfig)

Global git configuration:
- **delta** as pager for diffs
- **zdiff3** merge conflict style
- User: iancleary / iancleary@hey.com

## Shared Utilities

### Aliases (.common/aliases.sh)

Modern CLI replacements and shortcuts:

| Category | Aliases |
|----------|---------|
| Files | `l`, `ll`, `la`, `ls` (eza), `left` (recent files) |
| Git | `g`, `gc`, `gc!`, `gf`, `gpoc`, `cg` (cd to root) |
| Editors | `n` (nvim) |
| pnpm | `p`, `prd`, `prb`, `prs`, `pi`, `pa`, `pad`, `pap` |
| bun | `b`, `brd`, `brb`, `brs`, `bi`, `ba`, `bad`, `bao`, `bap` |
| Docker | `d`, `dc`, `di`, `dils`, `dirm`, `dcls`, `dcs` |
| Rust/Just | `c` (cargo), `j` (just) |
| Search | `hg` (history grep) |

### Git Worktree Helpers (.common/agents-git-trees.sh)

- **`ga [branch-name]`**: Create worktree at `../{branch}--{repo-name}`, switch to it
- **`gd`**: Delete current worktree and branch (interactive confirmation via gum)

## AI Agent Integration

### Claude Code (.claude/)

**Skills** (invoke with `/skill-name`):

| Skill | Description |
|-------|-------------|
| `cargo-just` | Smart task runner for Rust projects using cargo and just |
| `code-review` | Review code changes for quality, bugs, and style |
| `git-push-pr` | Automated git workflow: stage, commit, push, create/update PR |
| `grill` | Relentlessly interrogate an idea before proposing a plan |
| `interview` | In-depth interviewing to create detailed specifications |
| `slidev` | Create web-based developer presentations with Markdown/Vue |
| `test-writer` | Generate tests for existing code |

**MCP Servers**: Playwright (browser automation via `npx @playwright/mcp@latest`)

**Plugins**: rust-analyzer-lsp

### Codex CLI (.codex/)

**MCP Servers**: Playwright (same as Claude Code)

**Command policies** (`user-policy.rules`):
- **allow**: Read-only commands (ls, cat, rg, find, git status/diff/log, cargo check/clippy, eza, bat, etc.)
- **prompt**: Mutating operations (git add/commit/push, cargo build/test, npm/pnpm install, docker compose up, tailscale serve, etc.)
- **forbidden**: Dangerous commands (sudo, rm -rf /, cargo publish, mkfs, shutdown, reboot)

### Shared Agent Skills (.agents/)

Skills in `.agents/skills/` are shared across tools. Claude Code's `slidev` skill symlinks to `.agents/skills/slidev`.

## Sync Tool

### What Gets Synced

**Common (all platforms):**
- `.common/aliases.sh`, `.common/agents-git-trees.sh`
- `.claude/settings.json`, all Claude skills
- `.codex/rules/user-policy.rules`
- `.agents/skills/grill/`, `.agents/skills/slidev/` (dynamic discovery)

**Windows/Git Bash:** `.bashrc`, `.bash_profile`

**macOS/Linux (Zsh):** `.zshrc`, `.zshenv`, `.zprofile`, `.p10k.zsh`

### Dynamic Skill Syncing

Skill directories listed in `SYNCED_SKILL_DIRS` are automatically discovered — adding/removing files in those directories updates the sync list without editing the script.

### Safety

- Automatic timestamped backups before overwriting
- `cmp -s` diff detection to skip identical files
- Auto-creates parent directories
- Clear success/skip/error counts

## Dependencies

### Required
- bash or zsh, git

### Optional (for enhanced features)
- [eza](https://github.com/eza-community/eza), [bat](https://github.com/sharkdp/bat), [delta](https://github.com/dandavison/delta), [zoxide](https://github.com/ajeetdsouza/zoxide), [just](https://github.com/casey/just), [rg](https://github.com/BurntSushi/ripgrep), [lazygit](https://github.com/jesseduffield/lazygit), [gum](https://github.com/charmbracelet/gum), [nvim](https://neovim.io/), [oh-my-bash](https://ohmybash.nntoan.com/), [Powerlevel10k](https://github.com/romkatv/powerlevel10k)

## License

Personal dotfiles — use at your own discretion.
