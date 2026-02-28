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
#   --minimal    Install only core CLI tools (skip dev tools)
#   --skip-rust  Skip Rust toolchain installation
#   --skip-node  Skip Node.js/nvm installation

set -euo pipefail

# ─── Options ───────────────────────────────────────────────────────────────────

DRY_RUN=false
MINIMAL=false
SKIP_RUST=false
SKIP_NODE=false

for arg in "$@"; do
  case "$arg" in
    --dry-run)    DRY_RUN=true ;;
    --minimal)    MINIMAL=true ;;
    --skip-rust)  SKIP_RUST=true ;;
    --skip-node)  SKIP_NODE=true ;;
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

record_present() { log_ok "$1"; (( COUNT_PRESENT++ )) || true; }
record_installed() { (( COUNT_INSTALLED++ )) || true; }
record_skipped() { log_skip "$1"; (( COUNT_SKIPPED++ )) || true; }
record_failed() { log_fail; echo -e "  ${RED}✗${RESET} $1 — $2"; (( COUNT_FAILED++ )) || true; }

# ─── Platform Detection ───────────────────────────────────────────────────────

detect_platform() {
  OS="unknown"
  ARCH="$(uname -m)"

  case "$(uname -s)" in
    Darwin)  OS="macos" ;;
    Linux)   OS="linux" ;;
    MINGW*|MSYS*|CYGWIN*) OS="windows" ;;
  esac

  # Normalize arch
  case "$ARCH" in
    aarch64|arm64) ARCH="arm64" ;;
    x86_64|amd64)  ARCH="x86_64" ;;
  esac
}

# ─── Connectivity Check ───────────────────────────────────────────────────────

check_internet() {
  if ! curl -fsSL --connect-timeout 5 https://github.com > /dev/null 2>&1; then
    echo -e "${RED}Error:${RESET} No internet connectivity detected."
    echo "This installer requires internet access to download tools."
    exit 1
  fi
}

# ─── Helpers ───────────────────────────────────────────────────────────────────

has() { command -v "$1" &>/dev/null; }

version_of() {
  local v
  v=$("$1" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+[0-9.]*' | head -1)
  echo "${v:-unknown}"
}

run_or_dry() {
  if $DRY_RUN; then
    echo -e " ${DIM}(dry-run)${RESET}"
    record_installed
  else
    if eval "$@" > /dev/null 2>&1; then
      log_done
      record_installed
    else
      record_failed "$1" "installation command failed"
    fi
  fi
}

# ─── Package Manager Installation ─────────────────────────────────────────────

install_homebrew() {
  if has brew; then
    record_present "Homebrew ($(version_of brew))"
    return
  fi
  log_install "Homebrew"
  run_or_dry '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
}

install_scoop() {
  if has scoop; then
    record_present "Scoop"
    return
  fi
  log_install "Scoop"
  run_or_dry 'powershell.exe -NoProfile -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser; irm get.scoop.sh | iex"'
}

# ─── Brew/Scoop Tool Install ──────────────────────────────────────────────────

install_brew_tool() {
  local cmd="$1" pkg="${2:-$1}"
  if has "$cmd"; then
    record_present "$cmd ($(version_of "$cmd"))"
    return
  fi
  log_install "$cmd"
  run_or_dry "brew install $pkg"
}

install_scoop_tool() {
  local cmd="$1" pkg="${2:-$1}"
  if has "$cmd"; then
    record_present "$cmd ($(version_of "$cmd"))"
    return
  fi
  log_install "$cmd"
  run_or_dry "scoop install $pkg"
}

install_cli_tool() {
  local cmd="$1" pkg="${2:-$1}"
  if [[ "$OS" == "macos" || "$OS" == "linux" ]]; then
    install_brew_tool "$cmd" "$pkg"
  elif [[ "$OS" == "windows" ]]; then
    install_scoop_tool "$cmd" "$pkg"
  fi
}

# ─── Rust ──────────────────────────────────────────────────────────────────────

install_rust() {
  if $SKIP_RUST; then
    record_skipped "Rust toolchain"
    return
  fi
  if has rustup; then
    record_present "Rust ($(rustc --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo 'installed'))"
    return
  fi
  log_install "Rust (via rustup)"
  run_or_dry 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path'
}

# ─── Node.js / nvm ────────────────────────────────────────────────────────────

install_node() {
  if $SKIP_NODE; then
    record_skipped "Node.js/nvm"
    return
  fi

  local nvm_dir="${NVM_DIR:-$HOME/.nvm}"

  if [[ "$OS" == "windows" ]]; then
    if has nvm; then
      record_present "nvm-windows ($(nvm --version 2>/dev/null || echo 'installed'))"
    else
      log_install "nvm-windows"
      echo -e " ${YELLOW}manual install required${RESET}"
      echo -e "  ${DIM}Download from: https://github.com/coreybutler/nvm-windows/releases${RESET}"
      record_skipped "nvm-windows (manual install)"
    fi
    return
  fi

  if [[ -s "$nvm_dir/nvm.sh" ]]; then
    record_present "nvm ($(. "$nvm_dir/nvm.sh" && nvm --version 2>/dev/null || echo 'installed'))"
  else
    log_install "nvm"
    run_or_dry 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'
  fi

  # Install LTS if nvm is available
  if [[ -s "$nvm_dir/nvm.sh" ]] && ! $DRY_RUN; then
    # shellcheck disable=SC1091
    . "$nvm_dir/nvm.sh"
    if has node; then
      record_present "Node.js ($(node --version 2>/dev/null))"
    else
      log_install "Node.js LTS"
      run_or_dry 'nvm install --lts'
    fi
  fi
}

# ─── uv (Python) ──────────────────────────────────────────────────────────────

install_uv() {
  if has uv; then
    record_present "uv ($(version_of uv))"
    return
  fi
  log_install "uv"
  run_or_dry 'curl -LsSf https://astral.sh/uv/install.sh | sh'
}

# ─── Shell Enhancements ───────────────────────────────────────────────────────

install_shell_enhancements() {
  if [[ "$OS" == "macos" || "$OS" == "linux" ]]; then
    # oh-my-zsh
    if [[ -d "${ZSH:-$HOME/.oh-my-zsh}" ]]; then
      record_present "oh-my-zsh"
    else
      log_install "oh-my-zsh"
      run_or_dry 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
    fi

    # Powerlevel10k
    local p10k_dir="${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/themes/powerlevel10k"
    if [[ -d "$p10k_dir" ]]; then
      record_present "Powerlevel10k"
    else
      log_install "Powerlevel10k"
      run_or_dry "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git '$p10k_dir'"
    fi

  elif [[ "$OS" == "windows" ]]; then
    if [[ -d "${OSH:-$HOME/.oh-my-bash}" ]]; then
      record_present "oh-my-bash"
    else
      log_install "oh-my-bash"
      run_or_dry 'bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended'
    fi
  fi
}

# ─── Main ──────────────────────────────────────────────────────────────────────

main() {
  detect_platform

  echo ""
  echo -e "${BOLD}╔══════════════════════════════════════════════╗${RESET}"
  echo -e "${BOLD}║     iancleary/dotfiles — Tool Installer      ║${RESET}"
  echo -e "${BOLD}╚══════════════════════════════════════════════╝${RESET}"
  echo ""

  if $DRY_RUN; then
    echo -e "  ${YELLOW}DRY RUN${RESET} — no changes will be made"
    echo ""
  fi

  echo -e "  Detected: ${BOLD}${OS}${RESET} (${ARCH})"

  if [[ "$OS" == "unknown" ]]; then
    echo -e "  ${RED}Unsupported operating system${RESET}"
    exit 1
  fi

  check_internet
  echo -e "  Internet: ${GREEN}connected${RESET}"

  # ── Package Manager ──
  log_section "Package Manager"

  if [[ "$OS" == "macos" || "$OS" == "linux" ]]; then
    install_homebrew
  elif [[ "$OS" == "windows" ]]; then
    install_scoop
  fi

  # ── Core CLI Tools ──
  log_section "Core CLI Tools"

  install_cli_tool eza
  install_cli_tool bat
  install_cli_tool delta git-delta
  install_cli_tool zoxide
  install_cli_tool just
  install_cli_tool rg ripgrep
  install_cli_tool lazygit
  install_cli_tool gum
  install_cli_tool fd
  install_cli_tool jq

  if ! $MINIMAL; then
    # ── Development Tools ──
    log_section "Development Tools"

    install_cli_tool gh
    install_rust
    install_node
    install_uv

    # ── macOS-only Tools ──
    if [[ "$OS" == "macos" ]]; then
      log_section "macOS Tools"
      install_brew_tool nvim neovim
      if has ghostty; then
        record_present "Ghostty"
      else
        echo -e "  ${DIM}ℹ Ghostty — install manually from https://ghostty.org${RESET}"
      fi
    fi

    # ── Shell Enhancements ──
    log_section "Shell Enhancements"
    install_shell_enhancements
  else
    record_skipped "Development tools (--minimal)"
    record_skipped "Shell enhancements (--minimal)"
  fi

  # ── Summary ──
  echo ""
  echo -e "${BOLD}───────────────────────────────────────────────${RESET}"
  echo -e "${BOLD}Summary${RESET}"
  echo -e "  Installed:       ${GREEN}${COUNT_INSTALLED}${RESET}"
  echo -e "  Already present: ${BLUE}${COUNT_PRESENT}${RESET}"
  echo -e "  Skipped:         ${YELLOW}${COUNT_SKIPPED}${RESET}"
  echo -e "  Failed:          ${RED}${COUNT_FAILED}${RESET}"
  echo ""

  if (( COUNT_FAILED > 0 )); then
    echo -e "  ${RED}Some installations failed. Review the output above.${RESET}"
    echo ""
  fi

  echo -e "${BOLD}Next steps:${RESET}"
  echo -e "  1. Run ${BOLD}./sync-dotfiles.sh push${RESET}   to restore your dotfiles"
  echo -e "  2. Restart your shell             to pick up new tools"
  echo -e "  3. Run ${BOLD}just status${RESET}                to verify everything"
  if ! $MINIMAL && $SKIP_RUST; then
    :
  elif ! $MINIMAL; then
    echo -e "  4. Run ${BOLD}./install-cargo-tools.sh${RESET}  to install cargo extras (optional)"
  fi
  echo ""
}

main
