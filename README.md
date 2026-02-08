# dotfiles

Cross-platform shell configuration files for bash (Windows/Git Bash) and zsh (macOS/Linux).

## Overview

This repository manages dotfiles for multiple operating systems with a sync utility that handles bidirectional synchronization between your home directory and this repository.

## Features

- **Cross-platform support**: Bash configuration for Windows/Git Bash, Zsh for macOS/Linux
- **Bidirectional sync**: Pull from home to backup, push from repo to restore
- **Shell enhancements**: Modern CLI tools (eza, bat, delta, zoxide, just)
- **Git worktree helpers**: Functions for managing git worktrees efficiently
- **Claude Code integration**: Custom skills for enhanced development workflow
- **Safe operations**: Automatic backups before overwriting files

## Quick Start

### Installation

Clone this repository:

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
```

### Restore dotfiles to your system

```bash
# Interactive menu
./sync-dotfiles.sh

# Or directly push to home directory
./sync-dotfiles.sh push

# Using just
just push
```

### Backup current dotfiles

```bash
./sync-dotfiles.sh pull

# Using just
just pull
```

### Check sync status

```bash
./sync-dotfiles.sh status

# Using just
just status
```

## Repository Structure

```
.
├── .bash_profile        # Bash profile (Windows/Git Bash)
├── .bashrc              # Bash configuration with oh-my-bash
├── .zshrc               # Zsh configuration with Powerlevel10k
├── .zshenv              # Zsh environment variables
├── .zprofile            # Zsh profile
├── .p10k.zsh            # Powerlevel10k theme configuration
├── .common/             # Shared shell utilities
│   ├── aliases.sh       # Shell aliases (eza, docker, git, etc.)
│   └── agents-git-trees.sh  # Git worktree helper functions
├── .claude/             # Claude Code configuration
│   ├── settings.json    # Claude Code permissions and plugins
│   └── skills/          # Custom Claude skills
│       ├── interview/   # Interview skill for spec creation
│       └── git-push-pr/ # Git workflow automation skill
├── .codex/              # Codex CLI configuration
│   └── rules/
│       └── user-policy.rules  # Command execution approval rules
├── sync-dotfiles.sh     # Dotfile synchronization utility
├── justfile             # Task runner recipes
└── README.md            # This file
```

## Shell Configuration

### Bash (.bashrc)

For Windows/Git Bash environments:

- **oh-my-bash**: Terminal enhancement framework with "font" theme
- **Tool aliases**: bat, just, rg, delta, zoxide
- **Rust/Cargo**: Automatic environment setup
- **Python/uv**: Local bin path management
- **Go**: bin directory in PATH
- **SSH**: Auto-load GitHub SSH keys
- **NVM**: Node version manager support
- **Terraform**: bin directory in PATH

### Zsh (.zshrc, .zshenv, .zprofile)

For macOS/Linux environments:

- **Powerlevel10k**: Feature-rich prompt theme
- **Tool integration**: Modern CLI replacements loaded from cargo
- Similar tool support as bash configuration

## Shared Utilities

### Aliases (.common/aliases.sh)

Modern CLI replacements and shortcuts:

- **eza**: Better ls (`l`, `ll`, `la`, `ls`, `left`)
- **git**: Common operations (`g`, `gc`, `gf`, `gpoc`)
- **pnpm/bun**: Package manager shortcuts
- **docker**: Container management (`d`, `dc`, `di`)
- **editors**: `n` for nvim
- **just/cargo**: `j` for just, `c` for cargo

### Git Worktree Helpers (.common/agents-git-trees.sh)

Functions for managing git worktrees:

- **`ga [branch-name]`**: Create and switch to a new worktree
  - Creates worktree at `../{branch-name}--{repo-name}`
  - Automatically creates new branch and changes to worktree directory

- **`gd`**: Delete current worktree and branch
  - Interactive confirmation with gum
  - Safely removes worktree and associated branch

## Sync Tool Usage

### Commands

```bash
./sync-dotfiles.sh <command>
```

Available commands:

- **pull**: Copy dotfiles from home to repo (backup/save)
- **push**: Copy dotfiles from repo to home (restore/install)
- **status**: Show differences between home and repo
- **diff**: Show detailed diff for a specific file
- **list**: List all tracked dotfiles
- **add**: Show how to add a file to sync list
- **help**: Display help message

### What Gets Synced

**Common (all platforms):**
- `.common/agents-git-trees.sh`
- `.common/aliases.sh`
- `.claude/settings.json`
- `.codex/rules/user-policy.rules`
- `.claude/skills/interview/SKILL.md`
- `.claude/skills/git-push-pr/SKILL.md`

**Windows/Git Bash:**
- `.bashrc`
- `.bash_profile`

**macOS/Linux (Zsh):**
- `.zshrc`
- `.zshenv`
- `.zprofile`
- `.p10k.zsh`

### Safety Features

- Automatic backup before overwriting files (timestamped `.backup.*` files)
- Diff checking before operations
- Color-coded status output
- Delta or diff for comparing files

## Claude Code Integration

This repository includes custom Claude skills:

- **interview**: In-depth interviewing to create detailed specifications
- **git-push-pr**: Automated git workflow (stage, commit, push, PR create/update)

Claude Code settings (`.claude/settings.json`) configure permissions and plugins across projects.

## Codex CLI Integration

Codex rules (`.codex/rules/user-policy.rules`) define command execution approval policies:
- **allow**: Read-only commands (ls, cat, rg, git status/diff/log)
- **prompt**: Mutating operations (git add/commit/push, package installs, shell wrappers)
- **forbidden**: Dangerous commands (sudo, rm -rf /, mkfs, shutdown)

## Dependencies

### Required

- bash or zsh shell
- git

### Optional (for enhanced features)

- [eza](https://github.com/eza-community/eza) - Modern ls replacement
- [bat](https://github.com/sharkdp/bat) - Cat with syntax highlighting
- [delta](https://github.com/dandavison/delta) - Better git diffs
- [zoxide](https://github.com/ajeetdsouza/zoxide) - Smarter cd
- [just](https://github.com/casey/just) - Command runner
- [rg](https://github.com/BurntSushi/ripgrep) - Fast grep
- [lazygit](https://github.com/jesseduffield/lazygit) - Terminal git UI
- [gum](https://github.com/charmbracelet/gum) - Glamorous shell scripts
- [nvim](https://neovim.io/) - Hyperextensible Vim-based text editor
- [oh-my-bash](https://ohmybash.nntoan.com/) - Bash framework
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Zsh theme

## Contributing

### Adding Files to Sync

Edit `sync-dotfiles.sh` and add the file path to the appropriate array:

```bash
# For common files (all platforms)
COMMON_DOTFILES+=(
    "path/to/your/file"
)

# For OS-specific files
DOTFILES+=(
    "path/to/your/file"
)
```

### Workflow

1. Make changes to dotfiles in your home directory
2. Run `./sync-dotfiles.sh pull` to backup to repo
3. Commit and push changes
4. On another machine, run `./sync-dotfiles.sh push` to restore

## License

Personal dotfiles - use at your own discretion.
