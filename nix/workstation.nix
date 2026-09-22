{ config, lib, pkgs, ... }:
{
  options.publicWorkstation = {
    gitLabCli = lib.mkEnableOption "GitLab CLI (glab)";
    giteaCli = lib.mkEnableOption "Gitea CLI (tea)";
  };

  config = {
    # Stable user tools only. Mise owns rapidly changing tools and project
    # runtimes; the consuming machine owns identity, shell, SSH, and services.
    manual.manpages.enable = false;

    home.packages = (with pkgs; [
      age
      bat
      delta
      eza
      fd
      fzf
      git
      git-lfs
      gum
      jq
      lazygit
      ripgrep
      shellcheck
      sops
      zoxide
    ])
    ++ lib.optionals config.publicWorkstation.gitLabCli [ pkgs.glab ]
    ++ lib.optionals config.publicWorkstation.giteaCli [ pkgs.tea ];
  };
}
