{ ... }:
{
  programs.zsh.initContent = ''
    if (( $+commands[herdr] )); then
      eval "$(herdr completion zsh)"
    fi
  '';
}
