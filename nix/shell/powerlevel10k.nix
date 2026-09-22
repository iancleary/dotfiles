{ config, lib, pkgs, ... }:
let
  package = pkgs.zsh-powerlevel10k;
  seed = ./p10k.zsh;
in
{
  options.publicShell.powerlevel10k.enable =
    lib.mkEnableOption "Powerlevel10k prompt and initial configuration";

  config = lib.mkIf config.publicShell.powerlevel10k.enable {
    home.packages = [ package ];

    # Keep the source default declarative while leaving the configuration it
    # loads writable for `p10k configure` and manual edits.
    home.file.".config/zsh/load-powerlevel10k.zsh".source =
      ./load-powerlevel10k.zsh;

    home.activation.seedPowerlevel10kConfig =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [[ ! -e "$HOME/.p10k.zsh" ]]; then
          run ${pkgs.coreutils}/bin/install -m 0600 ${seed} "$HOME/.p10k.zsh"
        fi
      '';

    programs.zsh.initContent = lib.mkMerge [
      (lib.mkOrder 500 ''
        # Powerlevel10k instant prompt. Keep this near the start of .zshrc.
        if [[ -r "${config.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "${config.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')
      (lib.mkOrder 1000 ''
        source "${package}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
        source "${config.xdg.configHome}/zsh/load-powerlevel10k.zsh"
      '')
    ];
  };
}
