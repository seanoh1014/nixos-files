{ inputs, pkgs, ... }:

{
  imports = [ inputs.tmux-which-key.homeManagerModules.default ];

  programs.tmux = {
    enable = true;
    prefix = "C-a";
    terminal = "tmux-256color";

    tmux-which-key.enable = true;

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor "mocha"
          set -g @catppuccin_window_status_style "rounded"
        '';
      }
    ];

    extraConfig = ''
      unbind C-b
      bind C-a send-prefix
      set -as terminal-features ",st-256color:RGB"
    '';
  };
}
