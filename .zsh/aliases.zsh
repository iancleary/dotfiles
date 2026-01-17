# zsh aliases extracted from zsh/default.nix shellAliases
# Load this file from your zsh init (e.g. source ./aliases.zsh)

# Basic eza aliases
alias l='eza -alh --icons=auto'
alias ll='eza -l --icons=auto'
alias la='eza -la --icons=auto'
alias ls='eza --icons=auto'

# History / search
alias hg='history|grep'  # search bash history, swapped letters for gh cli compatibility

# Files / git
alias left='eza -t -1'                # most recently edited files
alias cg='cd "$(git rev-parse --show-toplevel 2>/dev/null)"'  # go to git main level

# Editors / package managers / runners
alias n='nvim'
alias p='pnpm'
alias prd='pnpm run dev'
alias prb='pnpm run build'
alias prs='pnpm run start'
alias pi='pnpm install'
alias pa='pnpm add'
alias pad='pnpm add --save-dev'
alias pap='pnpm add --save-peer'

alias b='bun'
alias brd='bun run dev'
alias brb='bun run build'
alias brs='bun run start'
alias bi='bun install'
alias ba='bun add'
alias bad='bun add -d'
alias bao='bun add --optional'
alias bap='bun add --peer'

# Docker short-hands
alias d='docker'
alias dc='docker container'
alias di='docker image'
alias dils='docker image ls'
alias dirm='docker image rm'
alias dcls='docker container ls'
alias dcs='docker container stop'

# Rust / just
alias c='cargo'
alias j='just'

alias g='git'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gf='git fetch'