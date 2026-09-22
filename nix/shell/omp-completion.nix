{ lib, ... }:
{
  # Oh My Pi is selected independently through mise. Generate completion from
  # the active executable so it stays aligned with that version.
  programs.zsh.initContent = lib.mkAfter ''
    if (( $+commands[omp] )); then
      eval "$(omp completions zsh)"
    fi
  '';
}
