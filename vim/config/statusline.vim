" ------------------------------------------------------------
" Statusline (lightline) — extended with mode, devicons, diagnostics
" ------------------------------------------------------------
let g:airline_theme = 'catppuccin_mocha'
let g:lightline = {
\   'colorscheme': 'catppuccin_mocha',
\   'mode_map': { 'n': 'NORMAL', 'i': 'INSERT', 'R': 'REPLACE', 'v': 'VISUAL', 'V': 'V-LINE', "\<C-v>": 'V-BLOCK', 'c': 'COMMAND', 's': 'SELECT', 'S': 'S-LINE', "\<C-s>": 'S-BLOCK', 't': 'TERMINAL' },
\   'active': {
\     'left':  [ [ 'mode', 'paste' ], [ 'gitbranch', 'readonly', 'filename', 'modified' ] ],
\     'right': [ [ 'lsp_errors', 'lsp_warnings', 'lsp_info', 'lsp_hints' ], [ 'lineinfo' ], [ 'filetype', 'fileencoding', 'fileformat' ] ],
\   },
\   'inactive': {
\     'left':  [ [ 'filename' ] ],
\     'right': [ [ 'lineinfo' ] ],
\   },
\   'tab': {
\     'left':  [ [ 'tabnum' ], [ 'filename' ] ],
\     'right': [ [ 'modified' ] ],
\   },
\   'component': {
\     'lineinfo': '%03l:%03c  %p%%',
\   },
\   'component_function': {
\     'gitbranch': 'LightlineGitbranch',
\     'lsp_errors': 'LightlineLspErrors',
\     'lsp_warnings': 'LightlineLspWarnings',
\     'lsp_info': 'LightlineLspInfo',
\     'lsp_hints': 'LightlineLspHints',
\   },
\ }

if has('nvim') || has('unix')
  function! LightlineGitbranch() abort
    if !exists('*FugitiveHead') || !filereadable(expand('%'))
      return ''
    endif
    let l:head = FugitiveHead()
    return l:head !=# '' ? '  '.l:head.' ' : ''
  endfunction
endif

function! LightlineLspErrors() abort
  let l:counts = get(b:, 'lsp_diagnostics_counts', {})
  let l:n = get(l:counts, 'Error', 0)
  return l:n > 0 ? ' E:'.l:n.' ' : ''
endfunction
function! LightlineLspWarnings() abort
  let l:counts = get(b:, 'lsp_diagnostics_counts', {})
  let l:n = get(l:counts, 'Warning', 0)
  return l:n > 0 ? ' W:'.l:n.' ' : ''
endfunction
function! LightlineLspInfo() abort
  let l:counts = get(b:, 'lsp_diagnostics_counts', {})
  let l:n = get(l:counts, 'Information', 0)
  return l:n > 0 ? ' I:'.l:n.' ' : ''
endfunction
function! LightlineLspHints() abort
  let l:counts = get(b:, 'lsp_diagnostics_counts', {})
  let l:n = get(l:counts, 'Hint', 0)
  return l:n > 0 ? ' H:'.l:n.' ' : ''
endfunction

augroup lightline_lsp_diag
  autocmd!
  autocmd User lsp_buffer_enabled call s:wire_lsp_diagnostics()
  autocmd CompleteDone * call lightline#update()
augroup END

function! s:wire_lsp_diagnostics() abort
  if !exists('*lightline#update')
    return
  endif
  function! lsp_diagnostics_count() abort
    let l:diagnostics = get(g:, 'lsp_diagnostics', [])
    if empty(l:diagnostics) | return {} | endif
    let l:counts = {}
    for d in l:diagnostics
      let l:key = d.severity == 1 ? 'Error' : d.severity == 2 ? 'Warning' : d.severity == 3 ? 'Information' : d.severity == 4 ? 'Hint' : 'Other'
      let l:counts[l:key] = get(l:counts, l:key, 0) + 1
    endfor
    let b:lsp_diagnostics_counts = l:counts
    call lightline#update()
    return l:counts
  endfunction
endfunction
