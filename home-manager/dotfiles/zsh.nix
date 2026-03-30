{ config, pkgs, lib, ... }:

{
    programs.zsh = {
      enable = true;
      # dotDir = ".config/zsh";
      autosuggestion.enable = true;
      enableCompletion = true;
      shellAliases = {
        ll = "ls -l";
        update = "doas nixos-rebuild switch";
        z = "zathura";
        c = "nix-shell -p libgccjit";
      };

      envExtra = ''
       _JAVA_AWT_WM_NONREPARENTING=1
       '';

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
    initContent = lib.mkOrder 550 ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
        source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh 
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';
    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
#    initContent = ''
#      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
#    '';
    };
}
