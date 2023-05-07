{ pkgs, config, lib, callPackage, ... }:

{
  home.packages = [ (pkgs.callPackage ./fonts/symbols.nix { }) ];
}
