{ pkgs, inputs, ... }:

let
  dwm = pkgs.dwm.overrideAttrs (oldAttrs: {
    src = ./pkgs/dwm;
    buildInputs = (oldAttrs.buildInputs or [ ]) ++ [
      pkgs.imlib2
      pkgs.libxcb
    ];
  });

  dwmblocks = pkgs.dwmblocks.overrideAttrs (oldAttrs: {
    src = inputs.dwmblocks-src;
    patches = (oldAttrs.patches or [ ]) ++ [ ./patches/dwmblocks-statuscmd.diff ];
  });

in {
  home.packages = [
    dwm
    dwmblocks
  ];
}
