{ config, pkgs, lib, ... }:

let
  pinnedPkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-21.05.tar.gz";
  }) {};
in {
  home.packages = [
    (pinnedPkgs.dwmblocks.overrideAttrs (old: {
      src = builtins.fetchTarball {
      url = "https://github.com/seanoh1014/dwmblocks-torrinfail/tarball/master";
      sha256 = "1cw78y7i9373a0s3i7ny1b45lizq9b4hxrrqhvrra8ayl4fmqrcm";
    }))
  ];
}
