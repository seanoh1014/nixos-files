{ config, pkgs, lib, ... }:

let
  pinnedPkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-21.05.tar.gz";
  }) {};

  callPinned = path: import path { inherit pinnedPkgs; };

in {
  home.packages = [
    (callPinned ./dwmblocks.nix)
    (callPinned ./dwm1.nix)
  ];
}
