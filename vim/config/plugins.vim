" ------------------------------------------------------------
" Plugin declarations (vim-plug)
" ------------------------------------------------------------
let g:lsp_settings_lazyload = 1

call plug#begin()
    Plug 'itchyny/lightline.vim'
    Plug 'voldikss/vim-floaterm'
    Plug 'prabirshrestha/vim-lsp'
    Plug 'mattn/vim-lsp-settings'

    " DDC
    Plug 'vim-denops/denops.vim'
    Plug 'Shougo/ddc.vim'
    Plug 'Shougo/pum.vim'
    Plug 'Shougo/ddc-ui-pum'

    " sources
    Plug 'shun/ddc-source-vim-lsp'
    Plug 'Shougo/ddc-around'
    Plug 'matsui54/ddc-source-buffer'

    " filters
    Plug 'tani/ddc-fuzzy'
    Plug 'Shougo/ddc-filter-sorter_rank'

    " extra
    " Plug 'luochen1990/rainbow'
    Plug 'catppuccin/vim', { 'as': 'catppuccin' }
    Plug 'direnv/direnv.vim'
    Plug 'jiangmiao/auto-pairs'
    Plug 'jpalardy/vim-slime'

    " visuals
    Plug 'ryanoasis/vim-devicons'
    Plug 'preservim/vim-indent-guides'
    Plug 'ntpeters/vim-better-whitespace'
    Plug 'mhinz/vim-startify'
call plug#end()
