{ ... }:
{
  home.file.".common/agents-git-trees.sh".source = ./agents-git-trees.sh;
  programs.zsh.initContent = ''
    [[ ! -r "$HOME/.common/agents-git-trees.sh" ]] || source "$HOME/.common/agents-git-trees.sh" >/dev/null
  '';
}
