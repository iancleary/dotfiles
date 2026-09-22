# Example Home Manager consumer

This flake shows how another repository can compose the public modules while
owning its Nixpkgs and Home Manager pins, user identity, and local policy. It is
an example, not an activated profile or a fleet target.

Nixpkgs comes from FlakeHub's `0.2605.*` release range, matching the fleet's
current package series. The consumer's `flake.lock` fixes the exact resolution;
review and build before updating it. The public dotfiles flake itself has no
Nixpkgs input because its modules accept the consumer's `pkgs`.

The `dotfiles` input points to this public repository. Review the resulting
lock file when copying this example into another repository, and replace the
example username and home directory in `home.nix` and system in `flake.nix`.
Set the Home Manager state version appropriate to the new profile. Add private
Git, SSH, secrets, and host integrations only in that consumer's `home.nix`.

The imported modules install the stable workstation CLI set, enable the shared
shell, activate mise when installed, and load the Git worktree functions.
`just` comes from the consuming machine's mise selection. The public
`mise/workstation/mise.toml` profile includes it; this Home Manager example
does not install mise tools or select that profile.
Optional npm, Homebrew, Herdr, macOS VS Code, and WSL VS Code modules are left
out until the consumer needs them. The WSL VS Code module requires a
machine-local `publicShell.wslVsCodePath`.
Powerlevel10k is also off by default. Set
`publicShell.powerlevel10k.enable = true` in `home.nix` to use the public prompt
seed; its font remains a separate machine choice.
The `examplePowerlevel10k` output enables that flag for a build-only check.

The workstation module also leaves forge CLIs off by default. Set either flag
in `home.nix` when that machine uses the forge:

```nix
publicWorkstation.gitLabCli = true; # Installs glab.
publicWorkstation.giteaCli = true;  # Installs tea.
```

The module installs binaries only; authentication remains machine-local. See
the [GitLab CLI documentation](https://docs.gitlab.com/cli/) for `glab` usage.

After replacing the example identity, a consumer can build without activation:

```sh
nix build .#homeConfigurations.example.activationPackage
```

To test local module edits before publishing them, override the public input:

```sh
nix build .#homeConfigurations.example.activationPackage \
  --override-input dotfiles path:../.. --no-write-lock-file --no-link
```
