" ------------------------------------------------------------
" DDC (completion) + pum uiParams
" ------------------------------------------------------------
call ddc#custom#patch_global('ui', 'pum')
call ddc#custom#patch_global('sources', ['buffer', 'vim-lsp', 'around'])
call ddc#custom#patch_global('sourceOptions', {
\ '_': {
\   'matchers': ['matcher_fuzzy'],
\   'sorters': ['sorter_rank'],
\   'minAutoCompleteLength': 3,
\ },
\ 'buffer': {
\   'mark': '[B]',
\   'matchers': ['matcher_fuzzy'],
\   'sorters': ['sorter_rank'],
\   'dup': 'force',
\ },
\ 'vim-lsp': {
\   'mark': '[LSP]',
\   'matchers': ['matcher_fuzzy'],
\   'sorters': ['sorter_rank'],
\   'forceCompletionPattern': '\.|:|->',
\   'dup': 'keep',
\   'isVolatile': v:true,
\ },
\ 'around': {
\   'mark': 'A',
\ },
\})

call ddc#custom#patch_global('sourceParams', {
\ 'vim-lsp': {
\   'enableResolveItem': v:true,
\   'enableAdditionalTextEdit': v:true,
\ },
\})

function! s:check_back_space() abort
  try
    let col = col('.') - 1
    return !col || getline('.')[col - 1] =~# '\s'
  catch
    return v:true
  endtry
endfunction

" Key mappings
" <C-n>: manual trigger (when not in popup) / next item (in popup)
execute "inoremap <silent><expr> <C-n>"
      \ 'pum#visible() ? pum#map#select_relative(+1) :'
      \ '<SID>check_back_space() ? "\<TAB>" : ddc#map#manual_complete()'

" <C-p>: previous item
inoremap <expr> <C-p> pum#map#select_relative(-1)

" <Tab>: next item (when popup visible), otherwise Tab
inoremap <expr> <TAB> pum#visible() ? pum#map#select_relative(+1) : "\<TAB>"

" <S-Tab>: previous item (when popup visible)
inoremap <expr> <S-TAB> pum#visible() ? pum#map#select_relative(-1) : "\<S-TAB>"

" <CR>: confirm selection
inoremap <expr> <CR> pum#visible() ? pum#map#confirm() : "\<CR>"

call ddc#enable()

" padding は pum#set_option() で設定
call timer_start(0, {-> pum#set_option({'padding': v:true})})

" ── pum UI ──
" pumwidth=0 → 自動幅, pumheight=20 → 最大行数
set pumwidth=0
set pumheight=20

call ddc#custom#patch_global('uiParams', {
\ 'pum': {
\   'winhighlight': 'Normal:Pmenu,CursorLine:PmenuSel',
\ },
\})
