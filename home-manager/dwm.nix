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

  st = pkgs.st.overrideAttrs (oldAttrs: rec {
     buildInputs = oldAttrs.buildInputs ++ [ pkgs.harfbuzz ];
     src = builtins.fetchTarball {
     url = "https://github.com/seanoh1014/st/tarball/master";
     sha256 = "13djp8iaincqvj2nhily8vwfxn7aywi579w52lz305imif32gv69";
  };
  });

  dwmblocks = pkgs.dwmblocks.overrideAttrs (oldAttrs: rec {
     src = builtins.fetchTarball {
     url = "https://github.com/seanoh1014/dwmblocks/tarball/master";
     sha256 = "08py394s83jsg4sykp2683kljwld8kmzsy73zj8dbphwrr1pnjnr";
  };
  patches = [
    ./patches/dwmblocks-statuscmd.diff
  ];
  });

in
{
  home.packages = [ dwm dmenu dwmblocks st];
}

