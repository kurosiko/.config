" ------------------------------------------------------------
" R: vim-slime + auto-launching terminal
" ------------------------------------------------------------
let g:slime_target = "vimterminal"
let g:slime_no_mappings = 1

function! s:setup_r_slime() abort
    if &filetype !=# 'r' | return | endif
    xmap <buffer> <leader>s <Plug>SlimeRegionSend
    nmap <buffer> <leader>s <Plug>SlimeMotionSend
    nmap <buffer> <leader>ss <Plug>SlimeLineSend
endfunction

augroup r_slime_mappings
    autocmd!
    autocmd FileType r call s:setup_r_slime()
augroup END

" R terminal (auto-start, auto-kill on vim exit)
let s:direnv_loaded = 0
let s:r_term_buf = -1
let s:r_kill_in_progress = 0
let s:r_cooldown_until = 0

function! s:do_launch_r(...) abort
    if bufexists(s:r_term_buf) | return | endif
    if localtime() < s:r_cooldown_until | return | endif
    vertical terminal R -q
    let s:r_term_buf = bufnr('%')
    wincmd p
endfunction

function! s:try_launch_r() abort
    if bufexists(s:r_term_buf) | return | endif
    if localtime() < s:r_cooldown_until | return | endif
    call timer_start(0, function('s:do_launch_r'))
endfunction

function! s:try_kill_r() abort
    if s:r_kill_in_progress | return | endif
    if !bufexists(s:r_term_buf) | return | endif
    for buf in range(1, bufnr('$'))
        if bufexists(buf) && getbufvar(buf, '&filetype') ==# 'r' && bufwinnr(buf) > 0
            return
        endif
    endfor
    " Set cooldown to block the re-launch loop (direnv reloads on BufEnter
    " and would otherwise re-fire DirenvLoaded and relaunch R immediately)
    let s:r_cooldown_until = localtime() + 2
    let s:r_kill_in_progress = 1
    let l:term = s:r_term_buf
    let s:r_term_buf = -1
    execute 'noautocmd bwipeout! ' . l:term
    let s:r_kill_in_progress = 0
endfunction

augroup RAutoTerminal
    autocmd!
    autocmd User DirenvLoaded let s:direnv_loaded = 1
        \ | if &filetype ==# 'r' && expand('%:t') !~# '^\.'
        \ |   call s:try_launch_r()
        \ | endif
    autocmd BufRead,BufNewFile *.R if s:direnv_loaded
        \ |   call s:try_launch_r()
        \ | endif
    autocmd WinEnter * call s:try_kill_r()
    autocmd VimLeavePre * if bufexists(s:r_term_buf)
        \ |   let l:term = s:r_term_buf
        \ |   let s:r_term_buf = -1
        \ |   execute 'noautocmd bwipeout! ' . l:term
        \ | endif
augroup END
