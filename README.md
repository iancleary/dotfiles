# Dotfiles

Personal configuration that can change without a Nix or Home Manager build.
Mise applies the selected files or marked blocks. This public repository holds
no credentials, private keys, sessions, caches, or machine-specific trust state.

## First managed setting

`mise.toml` owns the shared Herdr, Rust, Python, and uv selections, plus the
queued-question keybindings in `~/.codex/config.toml`.
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
OpenClaw has no Codex executable in its current shell, so the Codex
keybinding block has not been applied there. `npx skills add` remains the skill installer.
Nix/Home Manager continues to own stable packages and generated shell and SSH
configuration until an individual path is migrated with one explicit owner.

## Mise tool ownership

Homelab leads the shared tool selection. Its extra Codex and Node requests live
in `mise/hosts/homelab.toml`. Mac mini keeps Codex from npm and Node from Nix;
OpenClaw keeps Node from Nix and has no Codex command in its current shell.
Do not add tools to the shared list merely because they appear on Homelab.

As of 2026-09-20, Homelab, Mac mini, and OpenClaw link this repo's
`mise.toml` to
`~/.config/mise/config.toml`. Homelab also links
`mise/hosts/homelab.toml` to `~/.config/mise/conf.d/homelab.toml`. Run
`mise config ls`, `mise ls --current`, and `mise install` to inspect and apply
selection. Check each application after an upgrade. `latest` is a moving request;
`mise ls --current` records the resolved version at inspection time.
A project `mise.toml` can override these global defaults.

The Codex binary is mise-owned on Homelab, but its auth, sessions, project
trust, and other live settings remain local. Only the selected keybinding block
is shared here. The `npx skills add` workflow remains independent.

On OpenClaw, use a login shell (`bash -lc`) when invoking mise over Tailscale
SSH; its non-login SSH shell does not load mise onto `PATH`.
