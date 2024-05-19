{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    plugins = with pkgs.vimPlugins; [

      lualine-nvim
      vim-css-color
      #vim-latex-live-preview
      #latex-live-preview
      coc-nvim
      #coc-clangd
      nerdtree
      #nerdtree-git-plugin
      auto-pairs
      catppuccin-nvim
    ];
    extraConfig = builtins.readFile ./init.vim;
  };

}


