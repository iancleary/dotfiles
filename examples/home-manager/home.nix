{ ... }:
{
  # A real consumer supplies its own identity and local policy here.
  home.username = "example";
  home.homeDirectory = "/home/example";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
