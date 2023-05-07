{config, pkgs, lib, ... }:
let
  sxiv = pkgs.sxiv.overrideAttrs (oldAttrs: rec {
     src = builtins.fetchTarball {
     url = "https://github.com/xyb3rt/sxiv/tarball/master";
     sha256 = "19jg2xlpql505y6xv72lxdfm1kzfhmba0h1yz4zyp5qlxlkh0ii7";
  };
  patches = [
    ./patches/sxiv.diff
  ];
  });
in
{
  home.packages = [ sxiv ];
}
