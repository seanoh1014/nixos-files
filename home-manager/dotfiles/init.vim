set showmatch
set number
set relativenumber
set mouse=a
set formatoptions+=o
set expandtab
set tabstop=4
set shiftwidth=4
set nojoinspaces
set clipboard+=unnamed,unnamedplus
set backspace=indent,eol,start

set nostartofline

" Completion popup: <Tab>/<S-Tab> cycle, <C-y> accepts, <C-Space> forces it open.
set completeopt=menu,menuone,noinsert,fuzzy,popup
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <C-Space> <Cmd>lua vim.lsp.completion.get()<CR>

colorscheme catppuccin-mocha

hi LineNrAbove guibg=none guifg=#5e6175
hi LineNr      guibg=none guifg=#8286a1, gui=bold
hi LineNrBelow guibg=none guifg=#5e6175

lua << END
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
END

lua << END
vim.lsp.config('clangd', {
  cmd = { 'clangd', '--background-index', '--clang-tidy', '--header-insertion=never' },
})
vim.lsp.enable({ 'clangd', 'pyright', 'bashls' })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })
  end,
})
END
