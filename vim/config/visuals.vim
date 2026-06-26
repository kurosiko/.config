" ------------------------------------------------------------
" Visuals — devicons, indent-guides, whitespace, startify, yazi
" ------------------------------------------------------------

" vim-devicons (Nerd Font icons for NERDTree, lightline)
let g:webdevicons_enable = 1
let g:webdevicons_enable_airline_tab = 0
let g:WebDevIconsUnicodeDecorateFileNodesHighlighting = 1
let g:webdevicons_conceallevel = 2

" vim-indent-guides — vertical guides for indentation
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0
let g:indent_guides_space_scale = 1
let g:indent_guides_tab_scale = 1
let g:indent_guides_guide_size = 1
" Catppuccin Mocha colors (Surface2 / Overlay0)
autocmd VimEnter,ColorScheme * :hi IndentGuidesOdd  guibg=#313244 ctermbg=237
autocmd VimEnter,ColorScheme * :hi IndentGuidesEven guibg=#1E1E2E ctermbg=235

" vim-better-whitespace — highlight trailing whitespace + full-width space
let g:better_whitespace_enabled = 1
let g:better_whitespace_filetypes_blacklist = ['help', 'nerdtree', 'startify', 'qf']
highlight ExtraWhitespace ctermbg=red guibg=#F38BA5 guifg=#1E1E2E

" vim-startify — start screen with recent files
let g:startify_enable_at_startup = 1
let g:startify_session_pick_height = 0
let g:startify_change_to_vsc_root = 1
let g:startify_change_to_dir = expand('~/git')
let g:startify_bookmarks = []
let g:startify_lists = [
            \ {'type':'commands','header':['Actions']},
            \ {'type':'dir','header':['Current']},
            \ ]

" Transparent background for startify so Ghostty's background image shows through
augroup startify_transparent
    autocmd!
    autocmd FileType startify setlocal wincolor=StartifyBg
augroup END
let g:startify_commands = [
    \{ 'v':['  Edit Vimrc','edit ~/.vimrc']},
    \{ 'n':['  Edit Nix','edit ~/.config/nix-config']},
    \{ 'y':['  Yazi','call YaziOpen()']},
    \{ 'p':['  PlugInstall','PlugInstall']},
    \{ 'u':['  PlugUpdate','PlugUpdate']},
    \{ 'q':['󰗡  Update + Quit','PlugUpdate | qa']},
    \ ]

let g:startify_custom_header = executable('figlet')
    \ ? systemlist('figlet -c -f smslant AhogeVim')
    \ : ['AhogeVim']
