{ config, lib, ... }:
{
  options.publicShell.npmPrefix = lib.mkOption {
    type = lib.types.str;
    default = "$HOME/.local/share/npm";
    description = "Writable global npm prefix selected by the consumer.";
  };
  config = {
    home.sessionPath = lib.mkBefore [ "${config.publicShell.npmPrefix}/bin" ];
    home.sessionVariables.NPM_CONFIG_PREFIX = config.publicShell.npmPrefix;
    programs.zsh.envExtra = lib.mkBefore ''
      typeset -U path
      path=("${config.publicShell.npmPrefix}/bin" $path)
    '';
    programs.zsh.profileExtra = lib.mkBefore ''
      typeset -U path
      path=("${config.publicShell.npmPrefix}/bin" $path)
    '';
  };
}
