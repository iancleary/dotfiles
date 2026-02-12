#!/usr/bin/env bash
# sync-dotfiles.sh - Synchronize dotfiles between home directory and this repository
#
# Usage:
#   ./sync-dotfiles.sh pull    # Pull files from home to repo (backup/save)
#   ./sync-dotfiles.sh push    # Push files from repo to home (restore/install)
#   ./sync-dotfiles.sh status  # Show diff between home and repo
#   ./sync-dotfiles.sh         # Interactive menu

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located (the dotfiles repo)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source and destination directories
HOME_DIR="$HOME"
REPO_DIR="$SCRIPT_DIR"

# files to sync based on OS
DOTFILES=()
COMMON_DOTFILES=()
# OPTIONAL_DOTFILES=()

# Common dotfiles (all platforms)
COMMON_DOTFILES+=(
        ".common/agents-git-trees.sh"
        ".common/aliases.sh"
        ".claude/settings.json"
        ".claude/skills/interview/SKILL.md"
        ".claude/skills/git-push-pr/SKILL.md"
        ".claude/skills/grill/SKILL.md"
        ".claude/skills/cargo-just/SKILL.md"
        ".claude/skills/code-review/SKILL.md"
        ".claude/skills/test-writer/SKILL.md"
        ".codex/rules/user-policy.rules"
        ".agents/skills/grill/SKILL.md"
    )

# Skill directories with many files (synced dynamically)
# Adding/removing files in these dirs automatically updates the sync list
SYNCED_SKILL_DIRS=(
    ".agents/skills/slidev"
    ".claude/skills/slidev"
)

for skill_dir in "${SYNCED_SKILL_DIRS[@]}"; do
    while IFS= read -r -d '' file; do
        COMMON_DOTFILES+=("${file#$REPO_DIR/}")
    done < <(find -L "$REPO_DIR/$skill_dir" -type f -print0 2>/dev/null | sort -z)
done

# Optional dotfiles (synced only if they exist)
# OPTIONAL_DOTFILES+=(
#     )

# Detect OS
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    # Windows
    DOTFILES+=(
        ".bashrc"
        ".bash_profile"
    )
    # No optional files for Windows yet, or maybe aliases?
    # Keeping it simple as per request
else
    # macOS / Linux (assume Zsh)
    DOTFILES+=(
        ".zshrc"
        ".zshenv"
        ".zprofile"
        ".p10k.zsh"
    )
    
fi

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}         ${GREEN}Dotfiles Synchronization Script${NC}                    ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

info() {
    echo -e "${BLUE}ℹ${NC}  $1"
}

success() {
    echo -e "${GREEN}✓${NC}  $1"
}

warn() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

error() {
    echo -e "${RED}✗${NC}  $1"
}

# Check if a file exists at source
file_exists() {
    local path="$1"
    [[ -f "$path" ]]
}

# Create parent directories if needed
ensure_parent_dir() {
    local path="$1"
    local parent_dir
    parent_dir="$(dirname "$path")"
    if [[ ! -d "$parent_dir" ]]; then
        mkdir -p "$parent_dir"
        info "Created directory: $parent_dir"
    fi
}

# Show diff between two files
show_diff() {
    local file1="$1"
    local file2="$2"
    
    if command -v delta &> /dev/null; then
        delta "$file1" "$file2" 2>/dev/null || true
    elif command -v diff &> /dev/null; then
        diff --color=auto -u "$file1" "$file2" 2>/dev/null || true
    else
        echo "No diff tool available"
    fi
}

# Ensure parent directories exist in repo for all tracked files
ensure_repo_dirs() {
    # for file in "${COMMON_DOTFILES[@]}" "${DOTFILES[@]}" "${OPTIONAL_DOTFILES[@]}"; do
    for file in "${COMMON_DOTFILES[@]}" "${DOTFILES[@]}"; do

        ensure_parent_dir "$REPO_DIR/$file"
    done
}

# Build the list of all files to sync
build_file_list() {
    ensure_repo_dirs
    ALL_FILES=()
    
    # Add common files (all platforms)
    for file in "${COMMON_DOTFILES[@]}"; do
        ALL_FILES+=("$file")
    done

    # Add OS-specific required files
    for file in "${DOTFILES[@]}"; do
        ALL_FILES+=("$file")
    done
    
    # Add optional files that exist in home or repo
    # for file in "${OPTIONAL_DOTFILES[@]}"; do
    #     if file_exists "$HOME_DIR/$file" || file_exists "$REPO_DIR/$file"; then
    #         ALL_FILES+=("$file")
    #     fi
    # done
}

# Pull files from home to repo (backup)
cmd_pull() {
    echo ""
    info "Pulling dotfiles from ${YELLOW}$HOME_DIR${NC} to ${GREEN}$REPO_DIR${NC}"
    echo ""
    
    build_file_list
    
    local copied=0
    local skipped=0
    
    for file in "${ALL_FILES[@]}"; do
        local src="$HOME_DIR/$file"
        local dst="$REPO_DIR/$file"
        
        if file_exists "$src"; then
            ensure_parent_dir "$dst"
            
            if file_exists "$dst"; then
                # Check if files are identical
                if cmp -s "$src" "$dst"; then
                    info "Unchanged: $file"
                    ((skipped++)) || true
                    continue
                fi
            fi
            
            cp "$src" "$dst"
            success "Copied: $file"
            ((copied++)) || true
        else
            warn "Not found in home: $file"
        fi
    done
    
    echo ""
    success "Pull complete: $copied copied, $skipped unchanged"
}

# Push files from repo to home (restore)
cmd_push() {
    echo ""
    info "Pushing dotfiles from ${GREEN}$REPO_DIR${NC} to ${YELLOW}$HOME_DIR${NC}"
    echo ""
    
    build_file_list
    
    local copied=0
    local skipped=0
    local backed_up=0
    
    for file in "${ALL_FILES[@]}"; do
        local src="$REPO_DIR/$file"
        local dst="$HOME_DIR/$file"
        
        if file_exists "$src"; then
            ensure_parent_dir "$dst"
            
            if file_exists "$dst"; then
                # Check if files are identical
                if cmp -s "$src" "$dst"; then
                    info "Unchanged: $file"
                    ((skipped++)) || true
                    continue
                fi
                
                # Backup existing file
                local backup="${dst}.backup.$(date +%Y%m%d_%H%M%S)"
                cp "$dst" "$backup"
                warn "Backed up: $file → ${backup##*/}"
                ((backed_up++)) || true
            fi
            
            cp "$src" "$dst"
            success "Installed: $file"
            ((copied++)) || true
        else
            warn "Not in repo: $file"
        fi
    done
    
    echo ""
    success "Push complete: $copied installed, $skipped unchanged, $backed_up backed up"
}

# Show status/diff between home and repo
cmd_status() {
    echo ""
    info "Comparing dotfiles between ${YELLOW}$HOME_DIR${NC} and ${GREEN}$REPO_DIR${NC}"
    echo ""
    
    build_file_list
    
    local in_sync=0
    local different=0
    local missing_repo=0
    local missing_home=0
    
    for file in "${ALL_FILES[@]}"; do
        local home_file="$HOME_DIR/$file"
        local repo_file="$REPO_DIR/$file"
        
        if file_exists "$home_file" && file_exists "$repo_file"; then
            if cmp -s "$home_file" "$repo_file"; then
                success "In sync: $file"
                ((in_sync++)) || true
            else
                warn "Different: $file"
                ((different++)) || true
                
                # Show brief diff summary
                local home_lines repo_lines
                home_lines=$(wc -l < "$home_file")
                repo_lines=$(wc -l < "$repo_file")
                echo "     Home: $home_lines lines | Repo: $repo_lines lines"
            fi
        elif file_exists "$home_file"; then
            error "Missing in repo: $file"
            ((missing_repo++)) || true
        elif file_exists "$repo_file"; then
            error "Missing in home: $file"
            ((missing_home++)) || true
        else
            warn "Missing everywhere: $file"
        fi
    done
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}In sync:${NC} $in_sync | ${YELLOW}Different:${NC} $different | ${RED}Missing repo:${NC} $missing_repo | ${RED}Missing home:${NC} $missing_home"
}

# Show detailed diff for a specific file
cmd_diff() {
    local file="${1:-}"
    
    if [[ -z "$file" ]]; then
        error "Usage: $0 diff <filename>"
        echo "Available files:"
        for f in "${DOTFILES[@]}"; do
            echo "  $f"
        done
        exit 1
    fi
    
    local home_file="$HOME_DIR/$file"
    local repo_file="$REPO_DIR/$file"
    
    echo ""
    info "Diff for: $file"
    echo "Home: $home_file"
    echo "Repo: $repo_file"
    echo ""
    
    if file_exists "$home_file" && file_exists "$repo_file"; then
        show_diff "$home_file" "$repo_file"
    else
        error "One or both files do not exist"
    fi
}

# Interactive menu
interactive_menu() {
    print_header
    
    echo "Select an action:"
    echo ""
    echo -e "  ${GREEN}1)${NC} pull   - Copy dotfiles from home to this repo (backup)"
    echo -e "  ${GREEN}2)${NC} push   - Copy dotfiles from repo to home (restore)"
    echo -e "  ${GREEN}3)${NC} status - Show differences between home and repo"
    echo -e "  ${GREEN}4)${NC} exit   - Exit"
    echo ""
    
    read -rp "Enter choice [1-4]: " choice
    
    case $choice in
        1|pull)
            cmd_pull
            ;;
        2|push)
            cmd_push
            ;;
        3|status)
            cmd_status
            ;;
        4|exit|q)
            echo "Bye!"
            exit 0
            ;;
        *)
            error "Invalid choice"
            exit 1
            ;;
    esac
}

# Add a file to the sync list
cmd_add() {
    local file="${1:-}"
    
    if [[ -z "$file" ]]; then
        error "Usage: $0 add <filepath-relative-to-home>"
        exit 1
    fi
    
    local home_file="$HOME_DIR/$file"
    
    if ! file_exists "$home_file"; then
        error "File does not exist: $home_file"
        exit 1
    fi
    
    info "To add '$file' to sync, edit this script and add to DOTFILES array:"
    echo ""
    echo "    \"$file\""
    echo ""
}

# List all tracked files
cmd_list() {
    echo ""
    info "Tracked dotfiles:"
    echo ""
    
    echo "Common files (all platforms):"
    for file in "${COMMON_DOTFILES[@]}"; do
        echo "  • $file"
    done

    echo ""
    echo "OS-specific required files:"
    for file in "${DOTFILES[@]}"; do
        echo "  • $file"
    done

    # echo ""
    # echo "Optional files (synced if they exist):"
    # for file in "${OPTIONAL_DOTFILES[@]}"; do
    #     if file_exists "$HOME_DIR/$file"; then
    #         echo -e "  ${GREEN}•${NC} $file (exists)"
    #     else
    #         echo -e "  ${YELLOW}•${NC} $file (not found)"
    #     fi
    # done
}

# Main entry point
main() {
    local cmd="${1:-}"
    shift || true
    
    case "$cmd" in
        pull)
            print_header
            cmd_pull
            ;;
        push)
            print_header
            cmd_push
            ;;
        status)
            print_header
            cmd_status
            ;;
        diff)
            print_header
            cmd_diff "$@"
            ;;
        list)
            print_header
            cmd_list
            ;;
        add)
            print_header
            cmd_add "$@"
            ;;
        help|-h|--help)
            print_header
            echo "Usage: $0 <command>"
            echo ""
            echo "Commands:"
            echo "  pull    Copy dotfiles from home directory to repo (backup)"
            echo "  push    Copy dotfiles from repo to home directory (restore)"
            echo "  status  Show differences between home and repo"
            echo "  diff    Show detailed diff for a file: $0 diff <file>"
            echo "  list    List all tracked dotfiles"
            echo "  add     Show how to add a file to sync list"
            echo "  help    Show this help message"
            echo ""
            echo "Files synced:"
            for file in "${COMMON_DOTFILES[@]}" "${DOTFILES[@]}"; do
                echo "  • $file"
            done
            ;;
        "")
            interactive_menu
            ;;
        *)
            error "Unknown command: $cmd"
            echo "Run '$0 help' for usage information."
            exit 1
            ;;
    esac
}

main "$@"
