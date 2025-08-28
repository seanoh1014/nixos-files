{ config, pkgs, lib, ... }:
let
  dwm = pkgs.dwm.overrideAttrs (old: {
    src = pkgs/dwm;
    #nativeBuildInputs = with pkgs; [ #writing once works for both currently, sort of bug and feature
    #  xorg.libX11.dev
    #  xorg.libXft
    #  imlib2
    #  xorg.libXinerama
    #];
  });

  dmenu = pkgs.dmenu.overrideAttrs (old: {
    src = pkgs/dmenu-5.3;
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
     url = "https://github.com/seanoh1014/dwmblocks-torrinfail/tarball/master";
     sha256 = "1cw78y7i9373a0s3i7ny1b45lizq9b4hxrrqhvrra8ayl4fmqrcm";
  };
  patches = [
    ./patches/dwmblocks-statuscmd.diff
  ];
  });

in
{
  home.packages = [ dwm dmenu dwmblocks st ];
}

