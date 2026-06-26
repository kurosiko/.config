" ------------------------------------------------------------
" yazi file picker — :! で Ghostty 側に起動 / nix develop は floaterm
" ------------------------------------------------------------

let s:yazi_bin = '/run/current-system/sw/bin/yazi'
let s:root_markers = ['.git', 'flake.nix', 'shell.nix', 'package.json']

function! YaziOpen() abort
  let l:cwd = expand('%:p:h')
  if empty(l:cwd) || !isdirectory(l:cwd)
    let l:cwd = getcwd()
  endif
  call s:yazi_launch(l:cwd)
endfunction

function! YaziRootOpen() abort
  let l:root = getcwd()
  for l:marker in s:root_markers
    let l:dir = finddir(l:marker, '.;')
    if !empty(l:dir)
      let l:root = fnamemodify(l:dir, ':p:h')
      break
    endif
  endfor
  call s:yazi_launch(l:root)
endfunction

function! s:yazi_launch(cwd) abort
  let l:chooser = tempname()
  call mkdir(fnamemodify(l:chooser, ':h'), 'p')

  silent execute '!cd ' . shellescape(a:cwd) . ' && '
        \ . s:yazi_bin . ' --chooser-file=' . shellescape(l:chooser)
  redraw!

  if v:shell_error
    call delete(l:chooser)
    return
  endif

  if !filereadable(l:chooser) | return | endif
  let l:chosen = trim(join(readfile(l:chooser), ''))
  call delete(l:chooser)

  if !empty(l:chosen) && filereadable(l:chosen)
    execute 'edit' fnameescape(l:chosen)
  endif
endfunction

function! NixDevelop() abort
  let l:bufnr = floaterm#terminal#get_bufnr('nix-develop')
  if l:bufnr > 0
    call floaterm#show(0, l:bufnr, '')
    return
  endif

  let l:root = getcwd()
  for l:marker in s:root_markers
    let l:dir = finddir(l:marker, '.;')
    if !empty(l:dir)
      let l:root = fnamemodify(l:dir, ':p:h')
      break
    endif
  endfor
  call floaterm#new(v:false, 'nix develop', {}, {
        \   'cwd': l:root,
        \   'title': 'nix develop',
        \   'name': 'nix-develop',
        \   'autoclose': 2,
        \   'wintype': 'float',
        \   'width': 0.9,
        \   'height': 0.9,
        \ })
endfunction

" <Leader>e : カレントバッファのディレクトリで yazi
nnoremap <silent> <Leader>e :<C-u>call YaziOpen()<CR>

" <Leader>E : プロジェクトルートで yazi
nnoremap <silent> <Leader>E :<C-u>call YaziRootOpen()<CR>

" <Leader>t : プロジェクトルートで nix develop
nnoremap <silent> <Leader>t :<C-u>call NixDevelop()<CR>
