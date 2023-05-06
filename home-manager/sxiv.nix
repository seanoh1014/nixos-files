{config, pkgs, lib, ... }:
let
  sxiv = pkgs.sxiv.overrideAttrs (oldAttrs: rec {
     src = builtins.fetchTarball {
     url = "https://github.com/xyb3rt/sxiv/tarball/master";
     sha256 = "";
  };
  patches = [
    ./sxiv.nix;
  ];
  });
in
{
  home.packages = [ sxiv ];
}
