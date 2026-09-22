{ config, lib, ... }:
{
  programs.zsh.envExtra = lib.mkAfter ''
    [[ ! -r "$HOME/.cargo/env" ]] || source "$HOME/.cargo/env" >/dev/null 2>&1
    typeset -U path
    path=("${config.home.profileDirectory}/bin" $path "$HOME/.cargo/bin" "$HOME/go/bin" "$HOME/.local/bin")
  '';
}
