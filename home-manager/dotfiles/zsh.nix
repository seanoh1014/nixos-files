{ config, pkgs, lib, ... }:

{
    programs.zsh = {
      enable = true;
      # dotDir = ".config/zsh";
      enableAutosuggestions = true;
      enableCompletion = true;
      shellAliases = {
        ll = "ls -l";
        update = "doas nixos-rebuild switch";
        z = "zathura";
      };
      plugins = [
      {
        name = "zsh-fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
      }
      {
        name = "zsh-powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
      }
    ];
    };
}
