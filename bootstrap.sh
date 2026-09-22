#!/usr/bin/env bash
set -euo pipefail

# Bootstrap a personal macOS or Linux user from the public dotfiles repository.
# This script does not activate a Home Manager profile.
repo_url='https://github.com/iancleary/dotfiles.git'
dotfiles_dir="${DOTFILES_DIR:-$HOME/Work/dotfiles}"
mise_config="${MISE_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/mise}"
dry_run=0

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [--dry-run]

Clone the public dotfiles checkout if needed, install mise and Determinate Nix
when absent, link the global mise configuration, install locked tools, and
apply this repository's mise-managed dotfiles. An existing checkout is used
without pulling or resetting it. Set DOTFILES_DIR to choose another location.
EOF
}

die() { printf 'bootstrap: %s\n' "$*" >&2; exit 1; }
note() { printf 'bootstrap: %s\n' "$*" >&2; }

case "${1:-}" in
  '') ;;
  --dry-run) dry_run=1 ;;
  --help|-h) usage; exit 0 ;;
  *) usage >&2; exit 2 ;;
esac
(( $# <= 1 )) || { usage >&2; exit 2; }

case "$(uname -s)" in
  Darwin|Linux) ;;
  *) die 'only macOS and Linux are supported' ;;
esac
command -v git >/dev/null || die 'git is required before bootstrap'
command -v curl >/dev/null || die 'curl is required before bootstrap'

if [[ -e "$dotfiles_dir" || -L "$dotfiles_dir" ]]; then
  [[ -d "$dotfiles_dir/.git" && -f "$dotfiles_dir/mise.toml" && -f "$dotfiles_dir/mise.lock" ]] \
    || die "existing path is not a usable dotfiles checkout: $dotfiles_dir"
  note "using existing checkout without pulling: $dotfiles_dir"
else
  note "would clone $repo_url into $dotfiles_dir"
fi

check_link() {
  local destination="$1" expected="$2"
  if [[ -e "$destination" || -L "$destination" ]]; then
    [[ -L "$destination" && "$(readlink "$destination")" == "$expected" ]] \
      || die "existing $destination is not the expected link; inspect it before retrying"
  fi
}

check_link "$mise_config/config.toml" "$dotfiles_dir/mise.toml"
check_link "$mise_config/mise.lock" "$dotfiles_dir/mise.lock"

if (( dry_run )); then
  command -v mise >/dev/null || [[ -x "$HOME/.local/bin/mise" ]] \
    || note 'would install mise from https://mise.run'
  command -v nix >/dev/null || note 'would install Determinate Nix'
  note "would link mise.toml and mise.lock under $mise_config"
  note 'would run mise install --locked from HOME'
  note 'would run mise bootstrap dotfiles apply --dry-run, then apply'
  exit 0
fi

if [[ ! -d "$dotfiles_dir/.git" ]]; then
  mkdir -p "$(dirname "$dotfiles_dir")"
  git clone "$repo_url" "$dotfiles_dir"
fi
[[ -f "$dotfiles_dir/mise.toml" && -f "$dotfiles_dir/mise.lock" ]] \
  || die 'cloned checkout has no mise.toml or mise.lock'

scratch_dir="$(mktemp -d)"
trap 'rm -rf "$scratch_dir"' EXIT

if command -v mise >/dev/null; then
  mise_bin="$(command -v mise)"
elif [[ -x "$HOME/.local/bin/mise" ]]; then
  mise_bin="$HOME/.local/bin/mise"
else
  note 'installing mise from its official installer'
  curl --proto '=https' --tlsv1.2 -fsSL https://mise.run -o "$scratch_dir/install-mise.sh"
  sh "$scratch_dir/install-mise.sh"
  mise_bin="$HOME/.local/bin/mise"
  [[ -x "$mise_bin" ]] || die "mise installer did not create $mise_bin"
fi
"$mise_bin" --version

if command -v nix >/dev/null; then
  note 'Nix is already installed; leaving its installation unchanged'
else
  note 'installing Determinate Nix with its official installer'
  curl --proto '=https' --tlsv1.2 -fsSL https://install.determinate.systems/nix \
    -o "$scratch_dir/install-nix.sh"
  sh "$scratch_dir/install-nix.sh" install
  if [[ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    # The installer cannot change the environment of this running shell.
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
  command -v nix >/dev/null || die 'Nix installed but is unavailable in this shell'
fi
nix --version

mkdir -p "$mise_config"
[[ -e "$mise_config/config.toml" || -L "$mise_config/config.toml" ]] \
  || ln -s "$dotfiles_dir/mise.toml" "$mise_config/config.toml"
[[ -e "$mise_config/mise.lock" || -L "$mise_config/mise.lock" ]] \
  || ln -s "$dotfiles_dir/mise.lock" "$mise_config/mise.lock"

( cd "$HOME" && "$mise_bin" install --locked )
( cd "$dotfiles_dir" && "$mise_bin" bootstrap dotfiles apply --dry-run )
( cd "$dotfiles_dir" && "$mise_bin" bootstrap dotfiles apply )
( cd "$dotfiles_dir" && "$mise_bin" bootstrap dotfiles status )
note 'bootstrap complete; configure shell activation or apply a Home Manager profile separately'
