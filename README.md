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
mise dot apply --dry-run
mise dot apply
mise dot status
```

Commit intended changes here. Apply a reviewed commit on each selected host,
then verify the target application. `npx skills add` remains the skill installer.
Nix/Home Manager continues to own stable packages and generated shell and SSH
configuration until an individual path is migrated with one explicit owner.
