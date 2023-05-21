{ config, pkgs, lib, ... }:

{
    programs.zsh = {
      enable = true;
      dotDir = ".config/zsh";
      shellAliases = {
        ll = "ls -l";
        update = "sudo nixos-rebuild switch";
        z = "zathura";
      };
      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
      };
      zplug = {
        enable = true;
        plugins = [
          { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
	      { name = "zsh-users/zsh-syntax-highlighting"; }
         #{ name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } 
        ];
      }; 
    };
}
