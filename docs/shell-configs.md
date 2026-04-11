# Shell Configurations

## Bash (.bashrc, .bash_profile)

- oh-my-bash with "font" theme
- Sources `.common/` utilities
- Cargo tools: just, bat, rg, zoxide, delta
- SSH key auto-loading, NVM, Terraform, Go, Python/uv

## Zsh (.zshrc, .zshenv, .zprofile, .p10k.zsh)

- Powerlevel10k instant prompt (MUST stay near top of .zshrc)
- Delegates config to `.zshenv`/`.zprofile`

### SSH Auth For GitHub And Codex

On macOS, do not rely on `~/.zshrc` for GitHub SSH auth that needs to work for Codex or other non-interactive shell commands.

- `~/.zshrc` is for interactive shell behavior such as prompt setup and completions
- `~/.zprofile` is the right place for login-shell bootstrap if a shell-based fallback is needed
- prefer `~/.ssh/config` plus macOS keychain over `eval \"$(ssh-agent ...)\"` in shell startup files

Preferred GitHub SSH config:

```sshconfig
Host github.com
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/github_id_ed25519
```

One-time keychain load:

```sh
ssh-add --apple-use-keychain ~/.ssh/github_id_ed25519
```

Verification:

```sh
ssh -T git@github.com
```

If shell bootstrap is still needed, keep it in `~/.zprofile`, not `~/.zshrc`, and guard it so it only starts an agent when one is missing.

## Git (.gitconfig)

- delta as pager, zdiff3 merge conflict style
- User: iancleary / iancleary@hey.com

## Shared Utilities (.common/)

**aliases.sh**: eza (l/ll/la/ls/left), git (g/gc/gf/gpoc/cg), editors (n=nvim), pnpm/bun shortcuts, docker (d/dc/di), cargo/just (c/j), history grep (hg)

**agents-git-trees.sh**:
- `ga [branch]`: Creates worktree at `../{branch}--{repo-name}`, switches to it, returns 1 to trigger cd
- `gd`: Deletes current worktree + branch, uses `gum confirm` for safety

## Modification Guidelines

- **Bash**: Keep oh-my-bash setup at top, source `.common/` before tools
- **Zsh**: Powerlevel10k instant prompt MUST stay near top of `.zshrc`; actual config goes in `.zshenv`/`.zprofile`
- **SSH on macOS**: Prefer `~/.ssh/config` + keychain; use `.zprofile` only for guarded login-shell fallback, never `.zshrc`
