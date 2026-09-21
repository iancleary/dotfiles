{ pkgs, ... }:
{
  # Stable user tools only. Mise owns rapidly changing tools and project
  # runtimes; the consuming machine owns identity, shell, SSH, and services.
  manual.manpages.enable = false;

  home.packages = with pkgs; [
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
    just
    lazygit
    ripgrep
    shellcheck
    sops
    tea
    zoxide
  ];
}
