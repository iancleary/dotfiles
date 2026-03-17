#!/bin/bash
# ralph-codex.sh
# 
# Autonomous feature development loop using Codex CLI
# Spawns fresh Codex sessions iteratively until feature converges
# 
# Usage: ./ralph-codex.sh <prd-file> [max-iterations]
# Example: ./ralph-codex.sh prd.json 10

set -euo pipefail

# Configuration
PRD_FILE="${1:-.}"
MAX_ITERATIONS="${2:-10}"
PROJECT_ROOT="$(pwd)"
ITERATIONS_DIR=".ralph-codex/iterations"
PROGRESS_FILE=".ralph-codex/progress.txt"
STATE_FILE=".ralph-codex/state.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
  echo -e "${BLUE}[ralph-codex]${NC} $1"
}

log_success() {
  echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
  echo -e "${RED}✗${NC} $1"
}

# Initialize directories and state
init() {
  log_info "Initializing ralph-codex..."
  
  # Create iteration tracking directory
  mkdir -p "$ITERATIONS_DIR"
  
  # Verify PRD exists
  if [ ! -f "$PRD_FILE" ]; then
    log_error "PRD file not found: $PRD_FILE"
    exit 1
  fi
  
  # Initialize git if needed
  if [ ! -d .git ]; then
    log_warn "Not a git repository. Initializing git..."
    git init
    git config user.email "ralph-codex@local"
    git config user.name "Ralph Codex"
  fi
  
  # Create initial state
  if [ ! -f "$STATE_FILE" ]; then
    cat > "$STATE_FILE" << 'EOF'
{
  "iteration": 0,
  "status": "initialized",
  "prd_hash": "",
  "convergence_detected": false,
  "converged_at_iteration": null
}
EOF
  fi
  
  log_success "Initialized in $PROJECT_ROOT"
}

# Get PRD content
get_prd() {
  cat "$PRD_FILE"
}

# Get accumulated progress from previous iterations
get_progress_context() {
  if [ -f "$PROGRESS_FILE" ]; then
    cat "$PROGRESS_FILE"
  else
    echo "(No prior progress)"
  fi
}

# Spawn Codex session for this iteration
spawn_codex_iteration() {
  local iteration=$1
  local prd=$(get_prd)
  local progress=$(get_progress_context)
  
  log_info "Spawning Codex session for iteration $iteration..."
  
  # Build the prompt for Codex
  local prompt="You are implementing a feature based on this PRD.

=== FEATURE REQUIREMENTS ===
$prd

=== PREVIOUS PROGRESS ===
$progress

=== YOUR TASK ===
1. Review the requirements above
2. Continue implementation based on previous progress (if any)
3. Implement the next piece of functionality
4. Mark items as complete with checkboxes
5. When ALL items are implemented, output: [CONVERGENCE: COMPLETE]

Start implementing now:"
  
  # Spawn Codex sub-agent with the prompt
  # This uses OpenClaw's sessions_spawn mechanism
  local iteration_output="$ITERATIONS_DIR/iteration-${iteration}.md"
  
  # For prototyping, we'll write the prompt to a file and have Codex read it
  echo "$prompt" > "$ITERATIONS_DIR/iteration-${iteration}-prompt.txt"
  
  log_info "Prompt saved to: $ITERATIONS_DIR/iteration-${iteration}-prompt.txt"
  log_warn "Next: Run 'codex < $ITERATIONS_DIR/iteration-${iteration}-prompt.txt > $iteration_output'"
  
  # Return the iteration output path for tracking
  echo "$iteration_output"
}

# Detect if convergence is complete
detect_convergence() {
  local iteration_output=$1
  
  if [ ! -f "$iteration_output" ]; then
    log_warn "Output file not found: $iteration_output (Codex session not yet complete)"
    return 1
  fi
  
  # Check for convergence markers
  if grep -q "\[CONVERGENCE: COMPLETE\]\|✓ ALL ITEMS COMPLETE\|READY TO MERGE" "$iteration_output"; then
    return 0
  fi
  
  return 1
}

# Update progress for next iteration
update_progress() {
  local iteration_output=$1
  
  # Extract summary from iteration output
  if [ -f "$iteration_output" ]; then
    # Keep only the last ~50 lines to avoid context explosion
    tail -n 50 "$iteration_output" > "$PROGRESS_FILE"
  fi
}

# Commit iteration to git
commit_iteration() {
  local iteration=$1
  
  git add "$ITERATIONS_DIR" "$PROGRESS_FILE" "$STATE_FILE" 2>/dev/null || true
  git commit -m "ralph-codex: iteration $iteration" 2>/dev/null || true
}

# Main loop
run() {
  init
  
  log_info "Starting ralph-codex loop (max $MAX_ITERATIONS iterations)"
  log_info "PRD: $PRD_FILE"
  echo ""
  
  local iteration=1
  local converged=false
  
  while [ $iteration -le "$MAX_ITERATIONS" ]; do
    log_info "=== ITERATION $iteration / $MAX_ITERATIONS ==="
    
    # Spawn Codex session
    local iteration_output
    iteration_output=$(spawn_codex_iteration "$iteration")
    
    log_info "Waiting for Codex session to complete..."
    log_info "Once complete, the output will be in: $iteration_output"
    
    # In production, this would wait for the Codex session
    # For now, we'll show the prompt and exit (user runs Codex separately)
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Codex Prompt for Iteration $iteration:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "$ITERATIONS_DIR/iteration-${iteration}-prompt.txt"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # For prototyping, return here and let user run Codex
    log_warn "PROTOTYPE MODE: Run your Codex session now"
    log_info "Then save output to: $iteration_output"
    log_info "Then run: ./ralph-codex.sh --resume-iteration $iteration"
    
    return 0  # Exit after first iteration for prototyping
    
    # TODO: In production, integrate with OpenClaw's sessions_spawn
    # to actually run Codex and wait for completion
    
    # Check for convergence
    if detect_convergence "$iteration_output"; then
      log_success "Convergence detected at iteration $iteration!"
      converged=true
      break
    else
      log_warn "Not converged yet, continuing..."
    fi
    
    # Update progress for next iteration
    update_progress "$iteration_output"
    
    # Commit to git
    commit_iteration "$iteration"
    
    iteration=$((iteration + 1))
  done
  
  echo ""
  if [ "$converged" = true ]; then
    log_success "Feature implementation complete!"
    log_info "Final output: $ITERATIONS_DIR/iteration-${iteration}.md"
  else
    log_warn "Reached max iterations ($MAX_ITERATIONS) without convergence"
    log_info "Review progress in: $PROGRESS_FILE"
  fi
}

# Main entry point
run
