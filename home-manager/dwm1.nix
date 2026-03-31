{ pinnedPkgs, ... }:

pinnedPkgs.dwm.overrideAttrs (oldAttrs: {
  src = pkgs/dwm;
  nativeBuildInputs = with pinnedPkgs; [ #writing once works for both currently, sort of bug and feature
    xorg.libX11.dev
    xorg.libXft
    imlib2
    xorg.libXinerama
  ];
})
