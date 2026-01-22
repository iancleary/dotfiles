# .bashrc

# Path to your oh-my-bash installation.
export OSH="$HOME/.oh-my-bash"

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-bash is loaded.
OSH_THEME="font"

# Uncommon the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncommon the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

if [[ -f "$OSH/oh-my-bash.sh" ]]; then
  source "$OSH/oh-my-bash.sh"
else
  echo "oh-my-bash not found at $OSH. Please install it."
fi

# User configuration
# export MANPATH="/usr/local/man:$MANPATH"

# Set personal aliases
[[ ! -f ~/.common/aliases.sh ]] || source ~/.common/aliases.sh
[[ ! -f ~/.common/agents-git-trees.sh ]] || source ~/.common/agents-git-trees.sh


# load rustup and cargo
[[ ! -f ~/.cargo/env ]] || source "$HOME/.cargo/env" 1>/dev/null
[[ ! -f ~/.cargo/bin/just ]] || alias j=just 1>/dev/null
[[ ! -f ~/.cargo/bin/bat ]] || alias cat=bat 1>/dev/null
[[ ! -f ~/.cargo/bin/rg ]] || alias grep=rg 1>/dev/null
[[ ! -f ~/.cargo/bin/zoxide ]] || eval "$(zoxide init zsh)" 1>/dev/null

# https://github.com/dandavison/delta?tab=readme-ov-file#get-started
[[ ! -f ~/.cargo/bin/delta ]] || git config --global core.pager delta 1>/dev/null
[[ ! -f ~/.cargo/bin/delta ]] || git config --global interactive.diffFilter 'delta --color-only' 1>/dev/null
[[ ! -f ~/.cargo/bin/delta ]] || git config --global delta.navigate true 1>/dev/null
[[ ! -f ~/.cargo/bin/delta ]] || git config --global merge.conflictStyle zdiff3 1>/dev/null
[[ ! -f ~/.cargo/bin/delta ]] || export DELTA_FEATURES=+side-by-side 1>/dev/null # activate 


# load uv (python)
[[ ! -f ~/.local/bin/env ]] || source "$HOME/.local/bin/env" 1>/dev/null

# Add go bin to path (if ~/go/bin directory exists)
[[ -d ~/go/bin ]] && export PATH="$HOME/go/bin:${PATH}" 1>/dev/null
alias lg='lazygit'


# Load ssh keys (ssh-agent needs to silence stdout 1; ssh-add needs to silence stderr 2)
[[ ! -f ~/.ssh/github_id_ed25519 ]] || eval "$(ssh-agent -s)" 1>/dev/null && ssh-add ~/.ssh/github_id_ed25519 2>/dev/null 

# Load NVM (Windows)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# add .terraform to path
export PATH=$PATH:"$HOME/.terraform"