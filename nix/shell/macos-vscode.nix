{ lib, pkgs, ... }:
{
  assertions = [{
    assertion = pkgs.stdenv.hostPlatform.isDarwin;
    message = "public shell macos-vscode requires macOS";
  }];
  programs.zsh.initContent = lib.mkBefore ''
    code() {
      VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args "$@"
    }
    e() { code "$@"; }
  '';
}
