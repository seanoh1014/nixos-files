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
    initExtraBeforeCompInit = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    '';
    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
    initExtra = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';
    };
}
