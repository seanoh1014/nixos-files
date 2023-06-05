{
  description = "Your new nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, nix-doom-emacs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          modules = [
            ./nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.users.ohsean = { pkgs, ... }: {
                home.stateVersion = "22.11";
                imports = [ nix-doom-emacs.hmModule ];
                programs.doom-emacs = {
                  enable = true;
                  doomPrivateDir = ./home-manager/dotfiles/doom; # Directory containing your config.el, init.el
                                         # and packages.el files
                };
              };
            }
          ];
        };
      };
      homeConfigurations = {
        ohsean = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home-manager/home.nix
          ];
        };
      };
    };
}
