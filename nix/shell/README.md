# Public Home Manager shell drafts

These files are exported by the checkout's flake. The fleet does not yet import
or activate them; the consuming profile decides which modules to use.

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
`publicShell.wslVsCodePath` let consumers supply local values. The fleet can
set `publicShell.zoxideHook = false` and keep its current Codex-specific hook
in its private overlay. The `codex()` wrapper and `CODEX_MINIMAL_SHELL` policy
are deliberately absent pending a separate decision. The worktree helper is a
reviewed variant of the fleet script. `gd` confirms the exact branch and
worktree, and Git refuses to remove a dirty worktree.

Promotion requires review of the flake export, the fleet's pinned dotfiles
input, and native builds for affected Home Manager profiles. These drafts do not
change the owner of generated shell files: Home Manager remains that writer.
