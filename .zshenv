# -------------------------------------------------------------------------------------------------------------------------------
# .zshenv
# is sourced for every shell, including login shells, and is source first.
# -------------------------------------------------------------------------------------------------------------------------------
# Key characteristics:
# ┌─────────────────┬────────────────────────────────────┐
# │ Aspect          │ .zshenv                            │
# ├─────────────────┼────────────────────────────────────┤
# │ When            │ Every shell (login and subshells)  │
# │ Purpose         │ Environment setup                  │
# │ Bash equivalent │ None                               │
# └─────────────────┴────────────────────────────────────┘
#
# Typical uses:
#
# * 
#
# Why use .zprofile instead of .zshenv?
#
# If a command:
# * Should run for every shell → .zshenv
# * Should run only once at login → .zprofile
#
# For example, starting ssh-agent in .zprofile prevents spawning multiple agents when you open subshells or run scripts.
# -------------------------------------------------------------------------------------------------------------------------------

# Load git shortcuts, 1> file redirects stdout to file
[[ ! -f ~/.common/agents-git-trees.sh ]] || source ~/.common/agents-git-trees.sh 1>/dev/null 
[[ ! -f ~/.common/aliases.sh ]] || source ~/.common/aliases.sh 1>/dev/null 

# load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# load rustup and cargo
[[ ! -f ~/.cargo/env ]] || source "$HOME/.cargo/env" 1>/dev/null
[[ ! -f ~/.cargo/bin/just ]] || alias j=just 1>/dev/null
[[ ! -f ~/.cargo/bin/bat ]] || alias cat=bat 1>/dev/null
[[ ! -f ~/.cargo/bin/rg ]] || alias grep=rg 1>/dev/null
[[ ! -f ~/.cargo/bin/zoxide ]] || eval "$(zoxide init zsh)" 1>/dev/null

# https://github.com/dandavison/delta?tab=readme-ov-file#get-started
# [[ ! -f ~/.cargo/bin/delta ]] || git config --global core.pager delta 1>/dev/null
# [[ ! -f ~/.cargo/bin/delta ]] || git config --global interactive.diffFilter 'delta --color-only' 1>/dev/null
# [[ ! -f ~/.cargo/bin/delta ]] || git config --global delta.navigate true 1>/dev/null
# [[ ! -f ~/.cargo/bin/delta ]] || git config --global merge.conflictStyle zdiff3 1>/dev/null
[[ ! -f ~/.cargo/bin/delta ]] || export DELTA_FEATURES=+side-by-side 1>/dev/null # activate 


# load uv (python)
[[ ! -f ~/.local/bin/env ]] || source "$HOME/.local/bin/env" 1>/dev/null

# Add go bin to path (if ~/go/bin directory exists)
[[ -d ~/go/bin ]] && export PATH="$HOME/go/bin:${PATH}" 1>/dev/null
alias lg='lazygit'

# Set up fzf key bindings and fuzzy completion
## Website recommendation: source <(fzf --zsh)
## MacPorts install recommendation
[[ ! -f /opt/local/share/fzf/shell/completion.zsh ]] || source /opt/local/share/fzf/shell/completion.zsh 1>/dev/null
[[ ! -f /opt/local/share/fzf/shell/key-bindings.zsh ]] || source /opt/local/share/fzf/shell/key-bindings.zsh 1>/dev/null
## aliases, functions, etc.
### like: https://github.com/junegunn/fzf/wiki/examples#general
[[ ! -f ~/.zsh/fzf.zsh ]] || source ~/.zsh/fzf.zsh 1>/dev/null 

# load python (for pre-commit)
[[ ! -f /Library/Frameworks/Python.framework/Versions/Current/Bin ]] || PATH="/Library/Frameworks/Python.framework/Versions/Current/Bin:${PATH}" 1>/dev/null
alias pip=pip3
alias python=python3

# Load ssh keys (ssh-agent needs to silence stdout 1; ssh-add needs to silence stderr 2)
[[ ! -f ~/.ssh/github_id_ed25519 ]] || eval "$(ssh-agent -s)" 1>/dev/null && ssh-add ~/.ssh/github_id_ed25519 2>/dev/null 

# Added by Antigravity (edited by me to handle folder not existing)
[[ -d "$HOME/.antigravity/antigravity/bin" ]] && export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Add code function, allowing arguments to be passed to it
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

# pnpm
export PNPM_HOME="/Users/iancleary/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
