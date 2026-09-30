{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    extraPackages = with pkgs; [
      clang-tools # clangd
      pyright
      bash-language-server
    ];
    plugins = with pkgs.vimPlugins; [

      lualine-nvim
      vim-css-color
      #vim-latex-live-preview
      #latex-live-preview
      nvim-lspconfig
      #coc-clangd
      nerdtree
      #nerdtree-git-plugin
      auto-pairs
      catppuccin-nvim
    ];
    extraConfig = builtins.readFile ./init.vim;
  };

}


