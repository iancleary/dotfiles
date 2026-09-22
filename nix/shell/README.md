# Public Home Manager shell modules

These files are exported by the checkout's flake. A consuming Home Manager
configuration pins a release and selects the modules it needs.

Each `.nix` file is a separate Home Manager module that a consumer may import.
`core.nix` supplies Zsh, fzf, zoxide, aliases, Delta presentation, and the Home
Manager profile PATH. Optional modules provide npm prefix, user tool paths,
Homebrew paths, mise activation, macOS VS Code, Herdr completion, Git worktree
helpers, and WSL VS Code. The macOS and WSL `code` functions are alternatives;
do not import both into one profile.

The core shell module includes an optional Powerlevel10k feature. Set
`publicShell.powerlevel10k.enable = true` to install the prompt and seed the
included `p10k.zsh` only when `~/.p10k.zsh` is absent. The user file stays
writable for `p10k configure`; disabling the flag leaves it untouched. The
module includes no font files. Choose a compatible terminal font separately.

`publicShell.npmPrefix`, `publicShell.miseCandidates`, and
`publicShell.wslVsCodePath` let consumers supply local values. A consumer can
set `publicShell.zoxideHook = false` and supply a gated hook in its own
configuration. The `codex()` wrapper and `CODEX_MINIMAL_SHELL` policy are
deliberately absent pending a separate decision. The worktree helper requires
confirmation before deletion. `gd` confirms the exact branch and worktree, and
Git refuses to remove a dirty worktree.

A change to these modules needs review of the flake export, an updated consumer
pin, and native builds for affected Home Manager profiles. This repository's
`mise.toml` and `mise.lock` are a separate host-side tool selection; changing a
consumer flake pin does not update installed mise tools. Home Manager remains
the writer of generated shell files.
