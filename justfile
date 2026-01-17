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