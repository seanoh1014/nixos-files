{ config, pkgs, lib, ... }:
let
  dwm = pkgs.dwm.overrideAttrs (old: {
    src = pkgs/dwm;
    nativeBuildInputs = with pkgs; [ #writing once works for both currently, sort of bug and feature
      xorg.libX11.dev
      xorg.libXft
      imlib2
      xorg.libXinerama
    ];
  });
  dmenu = pkgs.dmenu.overrideAttrs (old: {
    src = pkgs/dmenu;
  });
in
{
  home.packages = [ dwm dmenu ];
}

