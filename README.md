# Dotfiles

Personal configuration that can change without a Nix or Home Manager build.
Mise applies the selected files or marked blocks. This public repository holds
no credentials, private keys, sessions, caches, or machine-specific trust state.

## First managed setting

`mise.toml` owns only the queued-question keybindings in `~/.codex/config.toml`.
The marked block keeps Codex's other settings writable. Shift+Left opens a
queued question inside Herdr; Shift+Right moves back. Herdr keeps Alt+arrow
for its workspace and tab navigation.

From this checkout:

```sh
mise bootstrap dotfiles apply --dry-run
mise bootstrap dotfiles apply
mise bootstrap dotfiles status
```

Commit intended changes here. On another enrolled host, run `git pull --ff-only`
in this checkout, then `mise bootstrap dotfiles apply --dry-run` and
`mise bootstrap dotfiles apply`. Verify the target application afterward.
The first block was applied on Homelab and the Mac mini on 2026-09-20.
OpenClaw has no Codex executable in its current shell, so it is not enrolled
for this setting. `npx skills add` remains the skill installer.
Nix/Home Manager continues to own stable packages and generated shell and SSH
configuration until an individual path is migrated with one explicit owner.
