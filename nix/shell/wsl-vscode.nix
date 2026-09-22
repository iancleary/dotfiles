{ config, lib, ... }:
{
  options.publicShell.wslVsCodePath = lib.mkOption {
    type = lib.types.str;
    example = "/mnt/c/Users/<username>/AppData/Local/Programs/Microsoft VS Code/bin/code";
    description = ''
      Path to the per-user Windows VS Code launcher as seen from WSL.
      Replace <username> in the example with the Windows account name.
      This is the user installation path, not the system-wide installation.
    '';
  };
  config.programs.zsh.initContent = lib.mkBefore ''
    code() {
      local windows_code=${lib.escapeShellArg config.publicShell.wslVsCodePath}
      [[ -x "$windows_code" ]] || {
        print -u2 "Windows Visual Studio Code CLI is not executable: $windows_code"
        return 127
      }
      command "$windows_code" "$@"
    }
    e() { code "$@"; }
  '';
}
