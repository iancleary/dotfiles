# agents-git-trees.sh

function ga() {
  if [[ -z "$1" ]]; then
    echo ""
    echo "Usage: ga [branch-name]"
    echo ""
    printf "\033[31merror:    [branch-name] is missing\033[0m\n"
    echo ""
    echo "Please try again with a branch name"
    echo ""
    return 0
  fi

  # Ensure we're in the main worktree, not a child
  local main_worktree
  main_worktree="$(git worktree list --porcelain | head -1 | sed 's/^worktree //')"
  if [[ "$PWD" != "$main_worktree" ]]; then
    echo "Error: run 'ga' from the main worktree, not a child worktree."
    echo "Main worktree: $main_worktree"
    return 1
  fi

  local branch="$1"
  local base="$(basename "$PWD")"
  local worktree_path="../$branch--$base"

  git worktree add -b "$branch" "$worktree_path"
  cd "$worktree_path"
  return 0
}

function gd() {
  if gum confirm "Remove worktree and branch?"; then
    local cwd base branch root

    cwd="$PWD"
    worktree="$(basename "$cwd")"

    # split on first '--'
    branch="${worktree%%--*}" # part before --
    root="${worktree#*--}" # part after --

    echo "Removing worktree '$worktree' and branch '$branch'..."

    # protect against accidentally deleting a non-worktree directory
    if [[ "$root" != "$branch" ]]; then
      cd "../$root"
      git worktree remove "$worktree" --force
      git branch -D "$branch"
    else
      echo "Error: current directory '$worktree' doesn't match worktree naming convention (branch--repo)"
      echo "Navigate to a worktree created with 'ga' first."
    fi
  fi
}
