help:
    @echo "Usage: just <command>\n"
    @echo "Commands:\n"
    @echo "  pull    Pull files from home to repo (backup/save)\n"
    @echo "  push    Push files from repo to home (restore/install)\n"
    @echo "  status  Show diff between home and repo\n"
    @echo "  help    Show this help message\n"

# Pull files from home to repo (backup/save)
pull:
    ./sync-dotfiles.sh pull

# Push files from repo to home (restore/install)
push:
    ./sync-dotfiles.sh push

# Show diff between home and repo
status:
    ./sync-dotfiles.sh status

# Install all tools (core + dev)
install *ARGS:
    ./install.sh {{ARGS}}

# Install cargo-based tools (slower, optional)
install-cargo *ARGS:
    ./install-cargo-tools.sh {{ARGS}}

# Install everything (tools + cargo extras)
install-all *ARGS:
    ./install.sh {{ARGS}}
    ./install-cargo-tools.sh {{ARGS}}

# ============================================================================
# PUBLIC PROJECT RECIPES
# ============================================================================
# These recipes set up tmux sessions for public projects.
# For private projects, use scripts/local.justfile instead.

# touchstone - RF Data Processing
touchstone: _ensure-dotfiles-sourced
    @if ! [ -d ~/Development/touchstone/ ]; then git clone git@github.com:iancleary/touchstone.git ~/Development/touchstone/; fi
    @code ~/Development/touchstone/
    @source {{justfile_dir()}}/shell/functions/tmux-project.sh && tmux_project touchstone ~/Development/touchstone "dev:just run"

# gainlineup - Gain Calculation Tool
gainlineup: _ensure-dotfiles-sourced
    @if ! [ -d ~/Development/gainlineup/ ]; then git clone git@github.com:iancleary/gainlineup.git ~/Development/gainlineup/; fi
    @code ~/Development/gainlineup/
    @source {{justfile_dir()}}/shell/functions/tmux-project.sh && tmux_project gainlineup ~/Development/gainlineup "dev:cargo run test"

# linkbudget - Link Budget Calculator
linkbudget: _ensure-dotfiles-sourced
    @if ! [ -d ~/Development/linkbudget/ ]; then git clone git@github.com:iancleary/linkbudget.git ~/Development/linkbudget/; fi
    @code ~/Development/linkbudget/
    @source {{justfile_dir()}}/shell/functions/tmux-project.sh && tmux_project linkbudget ~/Development/linkbudget "dev:just run"

# Internal helper: ensure shell functions are sourced
_ensure-dotfiles-sourced:
    @true