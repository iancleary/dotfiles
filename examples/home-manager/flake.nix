{
  description = "Example consumer of the public dotfiles Home Manager modules";

  inputs = {
    dotfiles.url = "github:iancleary/dotfiles";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2605.*.tar.gz";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { dotfiles, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      mkHome = extraModules: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          dotfiles.homeManagerModules.workstation
          dotfiles.homeManagerModules.shell
          dotfiles.homeManagerModules.miseActivation
          dotfiles.homeManagerModules.ompCompletion
          dotfiles.homeManagerModules.gitWorktrees
          ./home.nix
        ] ++ extraModules;
      };
    in
    {
      homeConfigurations.example = mkHome [ ];
      homeConfigurations.examplePowerlevel10k = mkHome [
        { publicShell.powerlevel10k.enable = true; }
      ];
    };
}
