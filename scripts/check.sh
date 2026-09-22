#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

bash -n bootstrap.sh
while IFS= read -r nix_file; do
  nix-instantiate --parse "$nix_file" >/dev/null
done < <(git ls-files '*.nix')

example="path:$repo_root/examples/home-manager"
for profile in example examplePowerlevel10k; do
  nix build --accept-flake-config \
    "$example#homeConfigurations.$profile.activationPackage" \
    --override-input dotfiles "path:$repo_root" \
    --no-write-lock-file --no-link
done
