{ config, lib, ... }:
{
  imports = [ ./powerlevel10k.nix ];

  options.publicShell.zoxideHook = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Initialize zoxide in interactive Zsh; consumers may supply their own gated hook.";
  };
  config = {
    home.sessionPath = [ "${config.home.profileDirectory}/bin" ];
    home.sessionVariables.DELTA_FEATURES = "+side-by-side";

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      envExtra = ''
        typeset -U path
        path=("${config.home.profileDirectory}/bin" $path)
      '';
      profileExtra = ''
        # Login shells can reorder PATH after .zshenv (macOS path_helper does).
        typeset -U path
        path=("${config.home.profileDirectory}/bin" $path)
      '';
      shellAliases = {
        cat = "bat";
        g = "git";
        gpoc = "git push origin HEAD";
        grep = "rg";
        j = "just";
        l = "eza -alh --icons=auto";
        la = "eza -la --icons=auto";
        lg = "lazygit";
        ll = "eza -l --icons=auto";
        ls = "eza --icons=auto";
        n = "nvim";
      };
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.zoxide = {
      enable = true;
      enableZshIntegration = false;
    };
    programs.zsh.initContent = lib.optionalString config.publicShell.zoxideHook ''
      eval "$(command zoxide init zsh)" >/dev/null 2>&1
    '';
  };
}
