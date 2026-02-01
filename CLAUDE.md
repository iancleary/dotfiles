# Claude Code Reference

This document provides context for Claude Code when working with this dotfiles repository.

## Repository Purpose

This is a personal dotfiles repository that manages shell configurations across multiple operating systems:
- **Windows/Git Bash**: Uses bash with oh-my-bash
- **macOS/Linux**: Uses zsh with Powerlevel10k

## Key Components

### 1. Sync Utility (`sync-dotfiles.sh`)

The core synchronization script that manages bidirectional file syncing:

**File path**: `/sync-dotfiles.sh` (428 lines)

**Key functions**:
- `cmd_pull()`: Copies files from `$HOME` to repository (backup)
- `cmd_push()`: Copies files from repository to `$HOME` (restore)
- `cmd_status()`: Shows diff status between home and repo
- `build_file_list()`: Builds list of files to sync based on OS

**File tracking arrays**:
- `DOTFILES[]`: Required files that must exist (OS-specific)
- `OPTIONAL_DOTFILES[]`: Files synced only if they exist

**OS Detection**: Uses `$OSTYPE` to determine platform and select appropriate files.

### 2. Shell Configurations

#### Bash Configuration

**Files**: `.bashrc` (74 lines), `.bash_profile`

**Key features**:
- oh-my-bash framework with "font" theme (line 8)
- Sources shared utilities from `.common/` (lines 38-39)
- Cargo/Rust tools: just, bat, rg, zoxide, delta (lines 42-54)
- SSH key auto-loading (line 66)
- NVM integration (lines 69-71)
- Terraform path setup (line 74)

#### Zsh Configuration

**Files**: `.zshrc` (17 lines), `.zshenv`, `.zprofile`, `.p10k.zsh`

**Key features**:
- Powerlevel10k instant prompt (lines 4-9)
- Minimal configuration delegates to other files
- P10k theme customization loaded from `.p10k.zsh`

### 3. Shared Utilities (`.common/`)

#### Aliases (`aliases.sh`)

**File path**: `/.common/aliases.sh` (55 lines)

**Categories**:
- File browsing: eza aliases (lines 4-8)
- History search: `hg` for history grep (line 11)
- Git helpers: `cg` to go to git root (line 15)
- Editor: `n` for nvim (line 18)
- Package managers: pnpm and bun shortcuts (lines 19-36)
- Docker: `d`, `dc`, `di` shortcuts (lines 39-45)
- Rust/Just: `c`, `j` aliases (lines 48-49)
- Git: Common operations (lines 51-55)

#### Git Worktree Helpers (`agents-git-trees.sh`)

**File path**: `/.common/agents-git-trees.sh` (45 lines)

**Functions**:

1. **`ga [branch-name]`** (lines 3-22):
   - Creates new branch and worktree
   - Naming pattern: `../{branch}--{base-repo-name}`
   - Automatically changes to new worktree directory
   - Returns 1 (triggers cd in shell)

2. **`gd`** (lines 24-44):
   - Deletes current worktree and branch
   - Uses `gum confirm` for safety
   - Parses worktree name to extract branch and root
   - Protects against deleting non-worktree directories

### 4. Task Automation

#### Justfile

**File path**: `/justfile` (19 lines)

**Recipes**:
- `just help`: Show available commands
- `just pull`: Wrapper for `./sync-dotfiles.sh pull`
- `just push`: Wrapper for `./sync-dotfiles.sh push`
- `just status`: Wrapper for `./sync-dotfiles.sh status`

### 5. Claude Code Integration

**Directory**: `/.claude/skills/interview/`

Contains custom Claude skill for in-depth interviewing to create detailed specs.

**Synced on**: macOS/Linux only (see `sync-dotfiles.sh` line 52)

## File Modification Guidelines

### When modifying sync-dotfiles.sh

**Important sections**:
- Lines 27-55: File lists (`DOTFILES[]`, `OPTIONAL_DOTFILES[]`)
- Lines 36-55: OS detection and file selection
- Maintain both Windows and Unix file lists separately

**Safe to modify**:
- Adding files to `DOTFILES[]` or `OPTIONAL_DOTFILES[]`
- Adjusting color codes (lines 12-17)
- Adding new commands in main() switch (lines 373-424)

**Dangerous to modify**:
- Core sync logic in `cmd_pull()` and `cmd_push()`
- File comparison logic (uses `cmp -s`)
- Backup naming pattern (line 195)

### When modifying shell configs

**Bash (.bashrc)**:
- Keep oh-my-bash setup at top (lines 3-32)
- Source shared utilities before tools (lines 38-39)
- Tool initialization order matters for aliases
- Silent output with `1>/dev/null` or `2>/dev/null`

**Zsh (.zshrc)**:
- Powerlevel10k instant prompt MUST be near top
- Don't add anything after line 13 comment
- Actual config goes in `.zshenv` or `.zprofile`

### When modifying shared utilities

**aliases.sh**:
- Keep categorized with comments
- Order doesn't matter (all aliases)
- Safe to add new aliases anywhere

**agents-git-trees.sh**:
- `ga` function returns 1 to trigger cd in calling shell
- `gd` requires `gum` to be installed
- Worktree naming convention: `{branch}--{repo-name}`

## Common Tasks

### Adding a new dotfile to sync

1. Edit `sync-dotfiles.sh`
2. Add to `DOTFILES[]` (required) or `OPTIONAL_DOTFILES[]` (optional)
3. Choose correct section based on OS (lines 37-55)
4. Test with `./sync-dotfiles.sh list`

### Testing sync without side effects

```bash
# Check status without modifying anything
./sync-dotfiles.sh status

# See what would be synced
./sync-dotfiles.sh list

# See detailed diff for specific file
./sync-dotfiles.sh diff .zshrc
```

### Debugging shell config issues

**Bash**:
- Check if oh-my-bash is installed: `ls -la ~/.oh-my-bash`
- Verify cargo tools: `ls -la ~/.cargo/bin/`
- Test shared utils: `source ~/.common/aliases.sh`

**Zsh**:
- Check P10k: `ls -la ~/powerlevel10k`
- Verify instant prompt cache: `ls -la ~/.cache/p10k-*`

## Git Context

**Current branch**: `main` (also the main/default branch)

**Recent activity**:
- PR #2 merged: Added Claude interview skill
- Updates for bash compatibility with zoxide
- Renamed `.aliases.sh` → `aliases.sh`
- Made compatible with both Git Bash (Windows) and Zsh (macOS)

## Dependencies

### Required for full functionality
- eza, bat, delta, zoxide, just, rg (installed via cargo)
- gum (for interactive git worktree deletion)
- oh-my-bash (Windows/Git Bash)
- Powerlevel10k (macOS/Linux with zsh)

### Optional
- lazygit (aliased as `lg`)
- nvim (aliased as `n`)
- delta (enhanced git diffs)

## Architecture Notes

### Cross-platform strategy
- Separate file lists for Windows vs Unix
- Shared utilities in `.common/` work across platforms
- Conditional sourcing with `[[ ! -f ... ]] || source ...`

### Sync safety features
1. **Backup before overwrite**: Timestamped `.backup.{date}` files
2. **Diff detection**: Uses `cmp -s` to skip identical files
3. **Directory creation**: Auto-creates parent directories
4. **Reporting**: Clear success/skip/error counts

### Modern CLI replacements
- `cat` → `bat` (syntax highlighting)
- `ls` → `eza` (icons, colors)
- `cd` → `zoxide` (smart jumping)
- `grep` → `rg` (ripgrep, faster)
- git pager → `delta` (better diffs)
- task runner → `just` (make alternative)

## When to Update This File

Update CLAUDE.md when:
- Adding new dotfiles to sync
- Adding new scripts or utilities
- Changing sync behavior or patterns
- Adding new dependencies or tools
- Modifying shell configuration structure
- Adding new Claude skills
