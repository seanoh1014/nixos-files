{ pkgs, ... }:

{
  programs.foot = {
    enable = true;
  };
  programs.foot.server = { enable = true; };
}
