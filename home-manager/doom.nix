{ config, pkgs, ... }:

{
  # Unstraightened builds Doom, its framework, and its package set through
  # Nix. Editing the tracked Doom files therefore takes effect on the next
  # Home Manager switch instead of relying on a mutable ~/.config/emacs clone.
  programs.doom-emacs = {
    enable = true;
    doomDir = ./dotfiles/doom;
    doomLocalDir = "${config.xdg.dataHome}/nix-doom";
    experimentalFetchTree = true;
  };

  home.packages = with pkgs; [
    fd
    ripgrep
  ];

  home.sessionVariables.GSETTINGS_SCHEMA_DIR =
    pkgs.glib.getSchemaPath pkgs.gsettings-desktop-schemas;
}
