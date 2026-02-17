# Sync Utility — `sync-dotfiles.sh`

Bidirectional file syncing between `$HOME` and this repo.

## Commands

`pull` (backup), `push` (restore), `status`, `diff <file>`, `list`, `add`, `help`

## File Tracking

- `COMMON_DOTFILES[]`: All platforms (shared utilities, Claude/Codex configs, agent skills)
- `DOTFILES[]`: OS-specific (bash on Windows, zsh on macOS/Linux)
- `SYNCED_SKILL_DIRS[]`: Dynamically discovered skill directories (files auto-tracked)

## OS Detection

`$OSTYPE` → selects platform-specific files.

## Safety

Timestamped backups before overwrite, `cmp -s` skip for identical files.

## Modification Guidelines

- File lists: `COMMON_DOTFILES[]`, `DOTFILES[]`, `SYNCED_SKILL_DIRS[]`
- For new skills with multiple files, add the dir to `SYNCED_SKILL_DIRS[]` for auto-discovery
- For single files, add directly to `COMMON_DOTFILES[]`
- Don't modify core sync logic (cmd_pull/cmd_push) without care

## Task Runner (justfile)

Recipes: `help`, `pull`, `push`, `status` — wrappers for `sync-dotfiles.sh`
