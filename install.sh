#!/usr/bin/env bash
# install.sh — Cross-platform tool installer for iancleary/dotfiles
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/iancleary/dotfiles/main/install.sh | bash
#
#   Or clone and run:
#   ./install.sh
#
# Options:
#   --dry-run    Show what would be installed without installing
#   --skip-rust  Skip Rust toolchain + cargo tools
#   --skip-node  Skip Node.js/nvm installation
#   --skip-sync  Skip dotfiles clone and sync

set -euo pipefail

# ─── Options ───────────────────────────────────────────────────────────────────

DRY_RUN=false
SKIP_RUST=false
SKIP_NODE=false
SKIP_SYNC=false

for arg in "$@"; do
  case "$arg" in
    --dry-run)    DRY_RUN=true ;;
    --skip-rust)  SKIP_RUST=true ;;
    --skip-node)  SKIP_NODE=true ;;
    --skip-sync)  SKIP_SYNC=true ;;
    --help|-h)
      sed -n '2,/^$/p' "$0" 2>/dev/null | sed 's/^# \?//'
      exit 0
      ;;
    *) echo "Unknown option: $arg"; exit 1 ;;
  esac
done

# ─── Colors & Output ──────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

COUNT_INSTALLED=0
COUNT_PRESENT=0
COUNT_SKIPPED=0
COUNT_FAILED=0

log_ok()      { echo -e "  ${GREEN}✓${RESET} $1"; }
log_skip()    { echo -e "  ${YELLOW}–${RESET} $1 ${DIM}(skipped)${RESET}"; }
log_install() { echo -ne "  ${BLUE}→${RESET} installing ${BOLD}$1${RESET}..."; }
log_done()    { echo -e "done"; }
log_fail()    { echo -e "${RED}failed${RESET}"; }
log_section() { echo -e "\n${BOLD}$1${RESET}\n"; }

record_present()   { log_ok "$1 ${DIM}(already installed)${RESET}"; (( COUNT_PRESENT++ )) || true; }
record_installed() { log_done; (( COUNT_INSTALLED++ )) || true; }
record_skipped()   { log_skip "$1"; (( COUNT_SKIPPED++ )) || true; }
record_failed()    { log_fail; echo -e "  ${RED}✗${RESET} $1 — $2"; (( COUNT_FAILED++ )) || true; }

run_or_dry() {
  if $DRY_RUN; then
    echo -e "  ${DIM}(dry-run) would run: $*${RESET}"
    return 0
  fi
  "$@"
}

# ─── Platform Detection ───────────────────────────────────────────────────────

detect_platform() {
  OS="unknown"
  ARCH="$(uname -m)"

  case "$(uname -s)" in
    Darwin)               OS="macos" ;;
    Linux)                OS="linux" ;;
    MINGW*|MSYS*|CYGWIN*) OS="windows" ;;
  esac

  case "$ARCH" in
    x86_64|amd64) ARCH="x86_64" ;;
    arm64|aarch64) ARCH="arm64" ;;
  esac
}

# ─── Helpers ──────────────────────────────────────────────────────────────────

has() { command -v "$1" &>/dev/null; }

# Install a single tool via the platform package manager
pkg_install() {
  local name="$1"
  local cmd="${2:-$1}"  # command to check (defaults to package name)

  if has "$cmd"; then
    record_present "$name"
    return 0
  fi

  log_install "$name"
  if $DRY_RUN; then
    echo -e " ${DIM}(dry-run)${RESET}"
    (( COUNT_SKIPPED++ )) || true
    return 0
  fi

  case "$OS" in
    macos)   brew install "$name" &>/dev/null && record_installed || record_failed "$name" "brew install failed" ;;
    linux)   sudo apt-get install -y "$name" &>/dev/null && record_installed || record_failed "$name" "apt install failed" ;;
    windows) scoop install "$name" &>/dev/null && record_installed || record_failed "$name" "scoop install failed" ;;
  esac
}

# Read a declarative tool list file, skipping comments and blanks
read_tool_list() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo -e "  ${YELLOW}⚠${RESET} $file not found, skipping"
    return
  fi
  grep -v '^\s*#' "$file" | grep -v '^\s*$'
}

# ─── Banner ───────────────────────────────────────────────────────────────────

print_banner() {
  echo ""
  echo -e "${BLUE}╔══════════════════════════════════════════════════════╗${RESET}"
  echo -e "${BLUE}║${RESET}     ${BOLD}iancleary/dotfiles — Tool Installer${RESET}              ${BLUE}║${RESET}"
  echo -e "${BLUE}╚══════════════════════════════════════════════════════╝${RESET}"
  echo ""
  echo -e "  Detected: ${BOLD}${OS}${RESET} (${ARCH})"
  $DRY_RUN && echo -e "  Mode:     ${YELLOW}dry-run${RESET} (no changes will be made)"
  echo ""
}

# ─── Phase 1: Package Manager ─────────────────────────────────────────────────

install_package_manager() {
  log_section "Phase 1: Package Manager"

  case "$OS" in
    macos)
      if has brew; then
        record_present "Homebrew"
      else
        log_install "Homebrew"
        run_or_dry /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && record_installed || record_failed "Homebrew" "install failed"
      fi
      ;;
    windows)
      if has scoop; then
        record_present "Scoop"
      else
        log_install "Scoop"
        run_or_dry powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser; iex (irm get.scoop.sh)" && record_installed || record_failed "Scoop" "install failed"
      fi
      ;;
    linux)
      record_present "apt (system)"
      ;;
  esac
}

# ─── Phase 2: System Tools (Brewfile / Scoopfile) ─────────────────────────────

install_system_tools() {
  log_section "Phase 2: System Tools (platform package manager)"

  # Resolve paths — if running from curl pipe, download the files
  local brewfile scoopfile
  if [[ -f "${SCRIPT_DIR:-}/Brewfile" ]]; then
    brewfile="${SCRIPT_DIR}/Brewfile"
    scoopfile="${SCRIPT_DIR}/Scoopfile.json"
  else
    # Running from curl pipe — download declarative lists to temp
    local tmpdir
    tmpdir="$(mktemp -d)"
    curl -fsSL "https://raw.githubusercontent.com/iancleary/dotfiles/main/Brewfile" -o "$tmpdir/Brewfile"
    curl -fsSL "https://raw.githubusercontent.com/iancleary/dotfiles/main/Scoopfile.json" -o "$tmpdir/Scoopfile.json"
    curl -fsSL "https://raw.githubusercontent.com/iancleary/dotfiles/main/cargo-tools.txt" -o "$tmpdir/cargo-tools.txt"
    brewfile="$tmpdir/Brewfile"
    scoopfile="$tmpdir/Scoopfile.json"
    CARGO_TOOLS_FILE="$tmpdir/cargo-tools.txt"
  fi

  case "$OS" in
    macos)
      echo -e "  ${DIM}Using Brewfile: $brewfile${RESET}"
      if $DRY_RUN; then
        echo -e "  ${DIM}(dry-run) would run: brew bundle --file=$brewfile${RESET}"
        local count
        count=$(grep -c '^brew ' "$brewfile" 2>/dev/null || echo 0)
        echo -e "  ${DIM}($count packages in Brewfile)${RESET}"
      else
        if brew bundle --file="$brewfile" 2>/dev/null; then
          local count
          count=$(grep -c '^brew ' "$brewfile" 2>/dev/null || echo 0)
          log_ok "Brewfile applied ($count packages)"
          (( COUNT_INSTALLED += count )) || true
        else
          record_failed "brew bundle" "some packages may have failed"
        fi
      fi
      ;;
    windows)
      echo -e "  ${DIM}Using Scoopfile: $scoopfile${RESET}"
      if $DRY_RUN; then
        echo -e "  ${DIM}(dry-run) would run: scoop import $scoopfile${RESET}"
      else
        if scoop import "$scoopfile" &>/dev/null; then
          log_ok "Scoopfile imported"
          (( COUNT_INSTALLED++ )) || true
        else
          record_failed "scoop import" "some packages may have failed"
        fi
      fi
      ;;
    linux)
      # On Linux, install the Brewfile equivalents via apt
      for tool in jq gh gum lazygit neovim shellcheck; do
        pkg_install "$tool"
      done
      ;;
  esac
}

# ─── Phase 3: Rust + Cargo Tools ──────────────────────────────────────────────

install_rust() {
  log_section "Phase 3: Rust Toolchain + Cargo Tools"

  if $SKIP_RUST; then
    record_skipped "Rust (--skip-rust)"
    return
  fi

  # rustup
  if has rustc; then
    record_present "Rust $(rustc --version 2>/dev/null | awk '{print $2}')"
  else
    log_install "Rust (via rustup)"
    run_or_dry bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y" && record_installed || record_failed "rustup" "install failed"
    # Source cargo env for this session
    [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
  fi

  # Cargo tools from declarative list
  local cargo_file="${CARGO_TOOLS_FILE:-${SCRIPT_DIR:-}/cargo-tools.txt}"
  if [[ ! -f "$cargo_file" ]]; then
    echo -e "  ${YELLOW}⚠${RESET} cargo-tools.txt not found, skipping cargo tools"
    return
  fi

  echo -e "  ${DIM}Using cargo-tools.txt: $cargo_file${RESET}"

  while IFS= read -r tool; do
    # Map package name to binary name for checking
    local cmd="$tool"
    case "$tool" in
      git-delta)          cmd="delta" ;;
      fd-find)            cmd="fd" ;;
      ripgrep)            cmd="rg" ;;
      cargo-watch)        cmd="cargo-watch" ;;
      cargo-mutants)      cmd="cargo-mutants" ;;
      cargo-semver-checks) cmd="cargo-semver-checks" ;;
      cargo-nextest)      cmd="cargo-nextest" ;;
      cargo-edit)         cmd="cargo-add" ;;  # cargo-edit provides cargo-add
    esac

    if has "$cmd"; then
      record_present "$tool"
    else
      log_install "$tool"
      if $DRY_RUN; then
        echo -e " ${DIM}(dry-run)${RESET}"
        (( COUNT_SKIPPED++ )) || true
      else
        cargo install "$tool" &>/dev/null && record_installed || record_failed "$tool" "cargo install failed"
      fi
    fi
  done < <(read_tool_list "$cargo_file")
}

# ─── Phase 4: Node.js ─────────────────────────────────────────────────────────

install_node() {
  log_section "Phase 4: Node.js (via nvm)"

  if $SKIP_NODE; then
    record_skipped "Node.js (--skip-node)"
    return
  fi

  if has node; then
    record_present "Node.js $(node --version 2>/dev/null)"
  else
    # Install nvm first
    if [[ ! -d "$HOME/.nvm" ]]; then
      log_install "nvm"
      run_or_dry bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash' && record_installed || record_failed "nvm" "install failed"
    else
      record_present "nvm"
    fi

    # Install latest LTS
    if ! $DRY_RUN && [[ -s "$HOME/.nvm/nvm.sh" ]]; then
      source "$HOME/.nvm/nvm.sh"
      log_install "Node.js LTS"
      nvm install --lts &>/dev/null && record_installed || record_failed "Node.js" "nvm install failed"
    fi
  fi
}

# ─── Phase 5: Python (uv) ─────────────────────────────────────────────────────

install_python() {
  log_section "Phase 5: Python (via uv)"

  if has uv; then
    record_present "uv $(uv --version 2>/dev/null | awk '{print $2}')"
  else
    log_install "uv"
    run_or_dry bash -c "curl -LsSf https://astral.sh/uv/install.sh | sh" && record_installed || record_failed "uv" "install failed"
  fi
}

# ─── Phase 6: Shell Enhancements ──────────────────────────────────────────────

install_shell() {
  log_section "Phase 6: Shell Enhancements"

  case "$OS" in
    macos|linux)
      # oh-my-zsh
      if [[ -d "$HOME/.oh-my-zsh" ]]; then
        record_present "oh-my-zsh"
      else
        log_install "oh-my-zsh"
        run_or_dry bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended' && record_installed || record_failed "oh-my-zsh" "install failed"
      fi

      # Powerlevel10k
      local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
      if [[ -d "$p10k_dir" ]]; then
        record_present "Powerlevel10k"
      else
        log_install "Powerlevel10k"
        run_or_dry git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir" && record_installed || record_failed "Powerlevel10k" "git clone failed"
      fi
      ;;
    windows)
      # oh-my-bash
      if [[ -d "$HOME/.oh-my-bash" ]]; then
        record_present "oh-my-bash"
      else
        log_install "oh-my-bash"
        run_or_dry bash -c 'bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended' && record_installed || record_failed "oh-my-bash" "install failed"
      fi
      ;;
  esac
}

# ─── Phase 7: Dotfiles Clone & Sync ───────────────────────────────────────────

install_dotfiles() {
  log_section "Phase 7: Dotfiles Clone & Sync"

  if $SKIP_SYNC; then
    record_skipped "Dotfiles sync (--skip-sync)"
    return
  fi

  local dotfiles_dir="$HOME/Development/dotfiles"

  # Clone if not present
  if [[ -d "$dotfiles_dir/.git" ]]; then
    record_present "dotfiles repo ($dotfiles_dir)"
    # Pull latest
    log_install "dotfiles (pull latest)"
    if $DRY_RUN; then
      echo -e " ${DIM}(dry-run)${RESET}"
    else
      git -C "$dotfiles_dir" pull --ff-only &>/dev/null && record_installed || record_failed "dotfiles pull" "git pull failed"
    fi
  else
    log_install "dotfiles repo → $dotfiles_dir"
    if $DRY_RUN; then
      echo -e " ${DIM}(dry-run)${RESET}"
    else
      mkdir -p "$(dirname "$dotfiles_dir")"
      git clone https://github.com/iancleary/dotfiles.git "$dotfiles_dir" && record_installed || record_failed "dotfiles clone" "git clone failed"
    fi
  fi

  # Run sync script
  local sync_script="$dotfiles_dir/sync-dotfiles.sh"
  if [[ -x "$sync_script" ]]; then
    echo ""
    log_install "dotfiles sync (push to \$HOME)"
    if $DRY_RUN; then
      echo -e " ${DIM}(dry-run) would run: $sync_script push${RESET}"
    else
      "$sync_script" push && record_installed || record_failed "dotfiles sync" "sync push failed"
    fi
  else
    echo -e "  ${YELLOW}⚠${RESET} sync-dotfiles.sh not found or not executable"
  fi
}

# ─── Summary ──────────────────────────────────────────────────────────────────

print_summary() {
  echo ""
  echo -e "${BLUE}──────────────────────────────────────────────────────${RESET}"
  echo -e "${BOLD}Summary${RESET}"
  echo ""
  echo -e "  ${GREEN}Installed:${RESET}       $COUNT_INSTALLED"
  echo -e "  Already present: $COUNT_PRESENT"
  echo -e "  Skipped:         $COUNT_SKIPPED"
  [[ $COUNT_FAILED -gt 0 ]] && echo -e "  ${RED}Failed:          $COUNT_FAILED${RESET}"
  echo ""

  if [[ $COUNT_FAILED -eq 0 ]]; then
    echo -e "  ${GREEN}${BOLD}All done!${RESET} 🎉"
  else
    echo -e "  ${YELLOW}Done with $COUNT_FAILED failure(s).${RESET} Check output above."
  fi

  echo ""
  echo -e "  ${DIM}Next steps:${RESET}"
  echo -e "  ${DIM}  1. Restart your shell to pick up new tools${RESET}"
  echo -e "  ${DIM}  2. Run 'just status' in ~/Development/dotfiles to verify${RESET}"
  echo ""
}

# ─── Main ─────────────────────────────────────────────────────────────────────

# Resolve script dir (empty if running from curl pipe)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" 2>/dev/null)" 2>/dev/null && pwd)" || SCRIPT_DIR=""
CARGO_TOOLS_FILE=""

detect_platform
print_banner
install_package_manager
install_system_tools
install_rust
install_node
install_python
install_shell
install_dotfiles
print_summary
