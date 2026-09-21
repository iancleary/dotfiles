{
  description = "Local work-machine Home Manager profile";

  inputs = {
    dotfiles.url = "github:iancleary/dotfiles";
    nixpkgs.follows = "dotfiles/nixpkgs";
    home-manager.follows = "dotfiles/home-manager";
  };

  outputs = { dotfiles, nixpkgs, home-manager, ... }:
    let
      # Set these for this machine before building. Keep work-only settings
      # in the local home.nix; do not add them to the public source.
      system = "aarch64-darwin"; # Or x86_64-linux.
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system}.home-manager = home-manager.packages.${system}.default;
      homeConfigurations.work = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ dotfiles.homeManagerModules.workstation ./home.nix ];
      };
    };
}
