{
  description = "Portable, public Home Manager modules for workstations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      mkCheck = system: homeDirectory:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        (home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            self.homeManagerModules.workstation
            {
              home.username = "portable";
              home.homeDirectory = homeDirectory;
              home.stateVersion = "26.05";
            }
          ];
        }).activationPackage;
    in
    {
      homeManagerModules.workstation = import ./nix/workstation.nix;
      templates.workstation = {
        path = ./templates/workstation;
        description = "Workstation Home Manager flake with local identity and system";
      };
      checks.x86_64-linux.workstation = mkCheck "x86_64-linux" "/home/portable";
      checks.aarch64-darwin.workstation = mkCheck "aarch64-darwin" "/Users/portable";
    };
}
