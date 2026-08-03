{ config, pkgs, ... }:

{
  # Emacs itself remains in home.nix. This module only supplies Doom's
  # command-line dependencies and connects the writable configuration.
  home.packages = with pkgs; [
    fd
    ripgrep
  ];

  home.sessionVariables.DOOMDIR = "${config.xdg.configHome}/doom";

  home.sessionPath = [
    "${config.xdg.configHome}/emacs/bin"
  ];

  # Keep the config writable and tracked in nixos-files. Unlike a normal
  # Home Manager source, this does not turn the files into read-only links
  # to the Nix store.
  xdg.configFile."doom".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nixos-files/home-manager/dotfiles/doom";
}
