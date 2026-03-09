#!/bin/bash
# tmux-project.sh - Generic tmux session setup for development projects
#
# Usage: tmux_project <project_name> <repo_path> [window_name:setup_command] [...]
#
# Examples:
#   tmux_project rfengine ~/Development/rfengine \
#     "api:cargo run" \
#     "ui:cd frontend && bun install && bun run dev"
#
#   tmux_project rfsystems ~/Development/rfsystems \
#     "dev:just run"

tmux_project() {
  local project_name="$1"
  local repo_path="$2"
  shift 2
  local window_commands=("$@")

  # Validate inputs
  if [[ -z "$project_name" ]] || [[ -z "$repo_path" ]]; then
    echo "Usage: tmux_project <project_name> <repo_path> [window_name:setup_command] [...]"
    return 1
  fi

  # Clone repo if it doesn't exist
  if ! [[ -d "$repo_path" ]]; then
    local git_url="git@github.com:iancleary/${project_name}.git"
    echo "📁 Cloning $git_url to $repo_path..."
    git clone "$git_url" "$repo_path" || {
      echo "❌ Failed to clone $git_url"
      return 1
    }
  fi

  # Navigate to project directory
  cd "$repo_path" || {
    echo "❌ Failed to cd into $repo_path"
    return 1
  }

  # Kill existing session if it exists
  tmux kill-session -t "$project_name" 2>/dev/null

  # Create new tmux session (start with a "git" window)
  tmux new-session -s "$project_name" -n "git" -d
  echo "✅ Created tmux session: $project_name"

  # Add windows and execute setup commands
  local window_index=0
  for window_spec in "${window_commands[@]}"; do
    IFS=':' read -r window_name command <<<"$window_spec"
    
    if [[ -z "$window_name" ]] || [[ -z "$command" ]]; then
      echo "⚠️  Skipping invalid window spec: $window_spec"
      continue
    fi

    # Create window (or use first if index 0)
    if [[ $window_index -eq 0 ]]; then
      tmux rename-window -t "$project_name:0" "$window_name"
    else
      tmux new-window -t "$project_name" -n "$window_name"
    fi

    # Send the command
    tmux send-keys -t "$project_name:$window_index" "$command" Enter
    echo "📝 Window '$window_name': $command"
    
    ((window_index++))
  done

  # Attach to the session
  tmux select-window -t "$project_name:0"
  tmux -2 attach-session -t "$project_name"
}

# Export for use as a shell function
export -f tmux_project
