# Shell Configurations

## Bash (.bashrc, .bash_profile)

- oh-my-bash with "font" theme
- Sources `.common/` utilities
- Cargo tools: just, bat, rg, zoxide, delta
- SSH key auto-loading, NVM, Terraform, Go, Python/uv

## Zsh (.zshrc, .zshenv, .zprofile, .p10k.zsh)

- Powerlevel10k instant prompt (MUST stay near top of .zshrc)
- Delegates config to `.zshenv`/`.zprofile`

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
