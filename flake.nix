{
  description = "Your new nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    claude-code-nixpkgs.url = "github:NixOS/nixpkgs/master";
    codex-desktop-linux.url = "github:ilysenko/codex-desktop-linux";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tmux-which-key = {
      url = "github:alexwforsythe/tmux-which-key";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-doom-emacs-unstraightened = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # These source trees are locked to exact revisions in flake.lock. This
    # keeps the detachable DWM environment reproducible without vendoring
    # additional upstream repositories here.
    st-src = {
      url = "github:seanoh1014/st";
      flake = false;
    };
    dwmblocks-src = {
      url = "github:seanoh1014/dwmblocks-torrinfail";
      flake = false;
    };
    # sxiv-src = {
    #   url = "github:xyb3rt/sxiv";
    #   flake = false;
    # };
    # hyprland.url = "github:hyprwm/Hyprland";
    #tws.url = "./tws";
  };
  # add hyprland in outputs
  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
    let
      system = "x86_64-linux";
      claudeCodePkgs = import inputs.claude-code-nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: {
            claude-code = claudeCodePkgs.claude-code;
          })
          inputs.tmux-which-key.overlays.default
          inputs.nix-vscode-extensions.overlays.default
        ];
      };
      #pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations = {
        thinkpad-t14 = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/thinkpad-t14
          ];
        };
        gram = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/gram
          ];
        };
      };
      homeConfigurations = {
        ohsean = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            inputs.nix-doom-emacs-unstraightened.homeModule
            ./home-manager/home.nix
            #./tws/flake.nix
            # hyprland.homeManagerModules.default
            # {wayland.windowManager.hyprland.enable = true;}
          ];
        };
      };
      packages.${system}.chatgpt-desktop = inputs.codex-desktop-linux.packages.${system}.codex-desktop-computer-use-ui;
    };
}
