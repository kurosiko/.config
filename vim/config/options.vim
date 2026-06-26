" ------------------------------------------------------------
" General editor options
" ------------------------------------------------------------
syntax enable
if has('termguicolors')
  set termguicolors
endif
set background=dark
let mapleader = "\<Space>"

" Arduino .ino files should be treated as C++ for LSP/syntax support
augroup filetype_custom
  autocmd!
  autocmd BufRead,BufNewFile *.ino setlocal filetype=cpp
augroup END

set shell=zsh
set shellcmdflag=-c
set clipboard=unnamed
set number
set cursorline
set expandtab
set tabstop=4
set shiftwidth=4
set ignorecase
set smartcase
set smartindent
set incsearch
set completeopt=menuone,noinsert,noselect
set shortmess+=c
set updatetime=300
set signcolumn=yes
set termguicolors
set splitright
set exrc
set secure

" Change cursor style
if has('vim_starting')
    let &t_SI .= "\e[6 q"
    let &t_EI .= "\e[2 q"
    let &t_SR .= "\e[4 q"
endif
