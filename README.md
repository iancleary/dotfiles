# Dotfiles

Public mise configuration and reusable Home Manager modules. Mise applies its
selected files or marked blocks without a Home Manager build; the Nix modules
are applied only when a consuming profile is built and activated. This
repository holds no credentials, private keys, sessions, caches, or
machine-specific trust state.

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
shared selection includes Codex, Oh My Pi, Herdr, Node/npm, pnpm, Rust, Python,
uv, Go, `just`, GitHub CLI, HTTPie, ast-grep, Neovim, Basecamp CLI, Stripe
CLI, Typst, and yt-dlp.
Home Manager should not install the same binaries on enrolled hosts.

Herdr is the only exact shared pin. Node follows major 26 and pnpm major 12;
Go follows 1.27 and Python 3.14. Codex, Oh My Pi, GitHub CLI, ast-grep,
Basecamp, Neovim, Rust, uv, HTTPie, `just`, and Typst request `latest`.
Those requests advance only when a host runs an explicit mise upgrade or fresh resolution; `git pull`
alone does not update an installed executable. Node 26 is the current major
as of this selection, not the active LTS line.

`mise.lock` records exact Linux x64 and macOS arm64 resolutions for
repeatable rollout. Prepare a candidate on Homelab with:

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

## Oh My Pi harness

Mise installs the locked `omp` executable on Linux x64 and macOS arm64. Oh My
Pi keeps settings, provider authentication, sessions, and other writable state
under its machine-local agent directory; none of that state belongs in this
public repository. It can discover existing Codex skills and repository
`AGENTS.md` instructions without copying them.

See [the Oh My Pi harness guide](docs/oh-my-pi.md) for installation, initial
`always-ask` approval policy, secret obfuscation, isolated profile testing,
provider login, rollout checks, and updates. Home Manager consumers can import
`homeManagerModules.ompCompletion` for Zsh completion.

## Public Home Manager modules

The top-level `flake.nix` exports reusable modules through
`homeManagerModules`. See [`nix/shell/README.md`](nix/shell/README.md) for the
module inventory, options, and review boundaries. These modules are available
for a consuming Home Manager flake to import; this checkout does not install or
activate them. Home Manager remains the owner of generated shell files.

The public [`nix/workstation.nix`](nix/workstation.nix) module is also exported
as `homeManagerModules.workstation`.
It installs stable user CLIs without declaring a username, Git identity, SSH,
shell startup, or services. The consumer supplies those settings and pins this
repository in its own flake lock. The bootstrap script below uses the personal
root `mise.toml`; it does not select a work-machine mise profile or activate
this Home Manager module.

`just` is selected by mise in the root manifest and the optional
[`mise/workstation/mise.toml`](mise/workstation/mise.toml) work-machine profile;
the workstation Home Manager module does not install it. The bootstrap script
below applies the personal root manifest, so a work machine selects its own
mise profile explicitly.

[GitLab CLI (`glab`)](https://docs.gitlab.com/cli/) and Gitea CLI (`tea`) are optional via
`publicWorkstation.gitLabCli` and `publicWorkstation.giteaCli`; both default to
false.

A consumer can select individual modules in its own Home Manager configuration:

```nix
modules = [
  dotfiles.homeManagerModules.shell
  dotfiles.homeManagerModules.miseActivation
  dotfiles.homeManagerModules.gitWorktrees
];
```

For WSL, `dotfiles.homeManagerModules.wslVsCode` needs a machine-local
`publicShell.wslVsCodePath` pointing to the Windows user's VS Code launcher.
The macOS and WSL VS Code modules should not be imported together. Personal
Git identity, SSH credentials, any Codex session wrapper, and activation
policy remain with the consuming configuration.

Powerlevel10k is available in the public shell module behind
`publicShell.powerlevel10k.enable = true`. It seeds a writable prompt config
only when one is absent; the consuming machine supplies its font separately.

## Bootstrap a new macOS or Linux user

Download the published `bootstrap.sh` from `main` and run it:

```sh
curl --proto '=https' --tlsv1.2 -fsSL \
  https://raw.githubusercontent.com/iancleary/dotfiles/main/bootstrap.sh \
  -o /tmp/dotfiles-bootstrap.sh
bash /tmp/dotfiles-bootstrap.sh --dry-run
bash /tmp/dotfiles-bootstrap.sh
```

The script requires `git` and `curl`. It clones this repository to
`~/Work/dotfiles` unless that checkout already exists (`DOTFILES_DIR` can
change the location). It installs mise with the official mise installer and
Determinate Nix with its official installer only when each command is absent.
An existing Nix installation is left alone. It then links this repository's
`mise.toml` and `mise.lock` as the global mise configuration, runs
`mise install --locked`, previews the mise-managed dotfiles, and applies them.
It never pulls or resets an existing checkout and refuses to replace an
existing different mise configuration. The Determinate installer may request
administrator authorization. This bootstrap does not activate Home Manager;
import the public modules from a separate, pinned consuming flake. Until a
consumer configures shell activation, run mise by its installed path or use
`mise exec` explicitly.

See [`examples/home-manager/`](examples/home-manager/) for a small consumer
flake that composes the public workstation and shell modules without supplying
personal machine settings.

## Releases

Releases are GitHub tags using `YYYY.MM.DD.XX`, starting at `.00` each day.
See [`docs/release.md`](docs/release.md) for the release runner, dry run,
validation, and recovery procedure.
