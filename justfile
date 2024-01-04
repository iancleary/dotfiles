#!/usr/bin/env -S just --justfile
# ^ A shebang isn't required, but allows a justfile to be executed
#   like a script, with `./justfile test`, for example.

set dotenv-load

#
# Cross platform open
#
open_url := if os() == "windows" {
  "/cmd /c start"
} else if os() == "macos" {
  "open"
} else if os() == "linux" {
  "xdg-open"
} else {
  "undetected-os {{os()}}"
}

upgrade_command := if os() == "windows" {
  "pipx upgrade-all"
} else if os() == "macos" {
  "brew upgrade"
} else if os() == "linux" {
  "sudo apt update && sudo apt upgrade -y && sudo apt auto-remove -y && sudo snap refresh && flatpak update"
} else {
  "undetected-os {{os()}}"
}


# display all the recipes
help:
  just -l

# cd into chezmoi directory
cd:
  chezmoi cd

# update from chezmoi directory
update:
  chezmoi update -v

# upgrade system packages
upgrade:
  {{ upgrade_command }}

# Caddyfile commands (start and stop)
caddy command:
  caddy {{command}}

# open jellyfin (proxied via caddy, run caddy start first)
jellyfin:
  {{ open_url }} http://jellyfin.localhost/

# show brew tree of dependencies
tree:
  brew deps --tree --installed


# show current version (in .env)
# version:
#   # version := grep -i "VERSION" .env | cut -d "=" -f2
#   echo $VERSION

# # bump version to new version
# bump TO:
#   @#https://www.linode.com/docs/guides/linux-sd-command/

#   sd $VERSION '{{TO}}' .env
#   sd $VERSION '{{TO}}' README.md

# # change to a new version (just change 1.36.2 1.38.0)
# change FROM TO:
#   @#https://www.linode.com/docs/guides/linux-sd-command/

#   sd '{{FROM}}' '{{TO}}' .env
#   sd '{{FROM}}' '{{TO}}' README.md

# enter a shell with youtube-dl
youtube-dl:
  nix-shell -p youtube-dl-light ffmpeg
