{ config, lib, ... }:
{
  options.publicShell.miseCandidates = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [
      "${config.home.homeDirectory}/.local/bin/mise"
      "${config.home.homeDirectory}/.cargo/bin/mise"
    ];
    description = "Ordered candidate paths to the mise executable.";
  };
  config.programs.zsh.initContent = ''
    for _public_mise in ${lib.concatMapStringsSep " " lib.escapeShellArg config.publicShell.miseCandidates}; do
      if [[ -x "$_public_mise" ]]; then
        eval "$("$_public_mise" activate zsh)"
        break
      fi
    done
    unset _public_mise
  '';
}
