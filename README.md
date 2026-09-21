# Dotfiles

Personal configuration that can change without a Nix or Home Manager build.
Mise applies the selected files or marked blocks. This public repository holds
no credentials, private keys, sessions, caches, or machine-specific trust state.

## First managed setting

`mise.toml` owns the shared fast-moving CLI selections, plus the
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
The keybinding block was applied on all four enrolled hosts on 2026-09-20.
Apply it to new hosts after verifying Codex installation. `npx skills add` remains the skill installer.
Nix/Home Manager continues to own stable packages and generated shell and SSH
configuration until an individual path is migrated with one explicit owner.

## Mise tool ownership

Homelab leads the shared tool selection. `mise/hosts/homelab.toml` holds
only its upgrade policy and can carry temporary candidate overrides. The
shared selection includes Codex, Herdr, Node/npm, pnpm, Rust, Python, uv, Go,
GitHub CLI, ast-grep, Neovim, Basecamp CLI, Stripe CLI, Typst, and yt-dlp.
Home Manager should not install the same binaries on enrolled hosts.

Herdr is the only exact shared pin. Node follows major 26 and pnpm major 12;
Go follows 1.27 and Python 3.14. Codex, GitHub CLI, ast-grep, Basecamp,
Neovim, Rust, uv, and Typst request `latest`. Those requests advance only
when a host runs an explicit mise upgrade or fresh resolution; `git pull`
alone does not update an installed executable. Node 26 is the current major
as of this selection, not the active LTS line.

`mise.lock` records exact Linux x64 and macOS arm64 resolutions for fleet
rollout. Prepare a candidate on Homelab with:

```sh
MISE_SAFE=1 mise lock --global --bump \
  --platform linux-x64,macos-arm64 --json
mise install --locked
```

Review and commit the lockfile before follower rollout. Herdr's exact request
must remain `0.9.1`. Prior tool installations are retained to support recovery.

As of 2026-09-20, Homelab, MacBook, Mac mini, and OpenClaw link this repo's
`mise.toml` to
`~/.config/mise/config.toml`. Homelab also links
`mise/hosts/homelab.toml` to `~/.config/mise/conf.d/homelab.toml`. Run
`mise config ls`, `mise ls --current`, and `mise install` to inspect and apply
selection. Check each application after an upgrade. `latest` is a moving request;
`mise ls --current` records the resolved version at inspection time.
A project `mise.toml` can override these global defaults.

Codex authentication, sessions, project trust, and other live settings remain
local. Only the selected keybinding block
is shared here. The `npx skills add` workflow remains independent.

On OpenClaw, use a login shell (`bash -lc`) when invoking mise over Tailscale
SSH; its non-login SSH shell does not load mise onto `PATH`.

When advancing a rolling tool, run `mise upgrade TOOL` on Homelab, check the
selected version and an application smoke test, then run the same upgrade on
other hosts. For a major or minor line change, edit the shared request, commit
and push, then pull and run `mise install` on each host. The public manifest contains
no credentials; GitHub CLI auth stays in each user's local state.

## Work-machine profile

This repository also provides an opt-in workstation path for a machine outside
my personal fleet. It has two independent parts:

- `mise/workstation/mise.toml` selects portable, fast-moving CLIs. It excludes
  Herdr, Basecamp, HEY, Stripe, and the fleet's Codex keybindings. It uses the
  shared `mise.lock` for exact Linux x64 and macOS arm64 downloads.
- `homeManagerModules.workstation` installs stable user CLIs from the public
  `flake.nix`. It does not declare a username, Git identity, SSH keys, secrets,
  shell startup, services, or private flake inputs. A local consuming
  flake provides the machine identity and any work-specific settings.

Check the machine's software policy before installing Nix or mise. The work
profile is optional; a project `mise.toml` can still select different versions.
On a new machine, clone this repository, install mise through an approved
machine-local method, and link the work profile explicitly:

```sh
mkdir -p ~/.config/mise
ln -s "$PWD/mise/workstation/mise.toml" ~/.config/mise/config.toml
ln -s "$PWD/mise.lock" ~/.config/mise/mise.lock
cd ~
mise install --locked
mise ls --current
```

Run the link commands from the dotfiles checkout. They fail if those destinations
already exist, so inspect existing configuration before replacing anything.
Run `mise install --locked` outside the checkout: the repository root's personal
`mise.toml` is deliberately a different selection. On a work machine, pull
the repository's reviewed main branch and rerun the install; the links
continue to point at the updated files. Do not use the personal fleet's
Ansible rollout on work machines.

For the stable CLI layer, use an approved Determinate Nix installation and
Home Manager. Create a local flake from the public template:

```sh
mkdir -p ~/Work/workstation-home
cd ~/Work/workstation-home
nix flake init -t github:iancleary/dotfiles#workstation
```

Set `system`, `home.username`, and `home.homeDirectory` in the generated files.
Use `aarch64-darwin` and `/Users/<name>` for Apple Silicon macOS, or
`x86_64-linux` and `/home/<name>` for Linux. Keep work-specific Git, SSH,
secrets, and shell settings in that local flake. Then build and inspect before
activation:

```sh
nix build .#homeConfigurations.work.activationPackage
nix run .#home-manager -- switch --flake .#work
```

The consuming flake records exact Nix inputs in its own `flake.lock`. Review
its first lock and subsequent updates under the work machine's own policy.
The shared module can be updated independently of Nix by changing the public
dotfiles revision in that lock. The personal `nix-fleet` repository remains the
owner of personal machine profiles and is not a work-machine dependency.
