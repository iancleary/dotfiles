#!/usr/bin/env bash
# install-cargo-tools.sh — Install cargo-based development tools
#
# These are separated from install.sh because they compile from source
# and can take several minutes.
#
# Usage:
#   ./install-cargo-tools.sh
#   ./install-cargo-tools.sh --dry-run

set -euo pipefail

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

if ! command -v cargo &>/dev/null; then
  echo -e "${RED}Error:${RESET} cargo not found. Run install.sh first to install Rust."
  exit 1
fi

TOOLS=(
  "cargo-watch"
  "cargo-mutants"
  "cargo-semver-checks"
  "cargo-edit"
)

echo -e "\n${BOLD}Installing cargo tools${RESET} ${DIM}(this may take a few minutes)${RESET}\n"

installed=0
present=0
failed=0

for tool in "${TOOLS[@]}"; do
  bin="${tool}"
  if cargo install --list 2>/dev/null | grep -q "^${tool} "; then
    echo -e "  ${GREEN}✓${RESET} ${tool} (already installed)"
    (( present++ )) || true
  else
    echo -ne "  ${BLUE}→${RESET} installing ${BOLD}${tool}${RESET}..."
    if $DRY_RUN; then
      echo -e " ${DIM}(dry-run)${RESET}"
      (( installed++ )) || true
    elif cargo install "$tool" 2>/dev/null; then
      echo -e "done"
      (( installed++ )) || true
    else
      echo -e "${RED}failed${RESET}"
      (( failed++ )) || true
    fi
  fi
done

echo -e "\n${BOLD}Summary:${RESET} ${GREEN}${installed} installed${RESET}, ${BLUE}${present} present${RESET}, ${RED}${failed} failed${RESET}\n"
