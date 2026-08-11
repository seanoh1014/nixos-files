{config, pkgs, lib, inputs, ... }:
let
  sxiv = pkgs.sxiv.overrideAttrs (oldAttrs: rec {
     src = inputs.sxiv-src;
  patches = [
    ./patches/sxiv.diff
  ];
  });
in
{
  home.packages = [ sxiv ];
}
