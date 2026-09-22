{ config, lib, pkgs, ... }:
{
  assertions = [{
    assertion = pkgs.stdenv.hostPlatform.isDarwin;
    message = "public shell homebrew-paths requires macOS";
  }];
  home.sessionPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];
  programs.zsh.profileExtra = lib.mkAfter ''
    typeset -U path
    path=("${config.home.profileDirectory}/bin" $path)
  '';
}
