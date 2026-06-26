" ------------------------------------------------------------
" LSP (vim-lsp) + termdebug
" すべての LSP サーバーは nix 経由で管理
" ------------------------------------------------------------
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete

    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> K  <plug>(lsp-hover)
    nmap <buffer> <Leader>rn <plug>(lsp-rename)
    nmap <buffer> <Leader>ca <plug>(lsp-code-action)
    nmap <buffer> <Leader>gr <plug>(lsp-references)
endfunction

augroup lsp_attach
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

let g:lsp_diagnostics_enabled = 1
let g:lsp_virtual_text_enabled = 1
let g:lsp_semantic_enabled = 1
let g:lsp_semantic_delay = 100
let g:lsp_inlay_hints_enabled = 1
let g:lsp_inlay_hints_delay = 200
let g:lsp_inlay_hints_mode = { 'normal': ['curline'] }

let g:denops#deno = 'deno'
let g:lsp_settings_enable_suggestions = 0

packadd termdebug
let g:termdebugger = "lldb"

" ── Nix 経由で起動するヘルパー ──
function! s:nix_cmd(pkg, binary) abort
  return {server_info -> ['nix', 'shell', 'nixpkgs#' . a:pkg, '-c', a:binary]}
endfunction

" 必ず plugins.vim の g:lsp_settings_lazyload=1 より後に評価される
let g:lsp_settings = get(g:, 'lsp_settings', {})

" Go
let g:lsp_settings['gopls'] = extend(get(g:lsp_settings, 'gopls', {}), {
\   'cmd': s:nix_cmd('gopls', 'gopls'),
\})

" C/C++/ObjC
let g:lsp_settings['clangd'] = extend(get(g:lsp_settings, 'clangd', {}), {
\   'cmd': s:nix_cmd('clang-tools', 'clangd'),
\})

" Rust
let g:lsp_settings['rust-analyzer'] = extend(get(g:lsp_settings, 'rust-analyzer', {}), {
\   'cmd': s:nix_cmd('rust-analyzer', 'rust-analyzer'),
\})

" TypeScript/JavaScript (for Node.js projects)
let g:lsp_settings['typescript-language-server'] = extend(get(g:lsp_settings, 'typescript-language-server', {}), {
\   'cmd': s:nix_cmd('typescript-language-server', 'typescript-language-server'),
\})

" Python
let g:lsp_settings['pyright'] = extend(get(g:lsp_settings, 'pyright', {}), {
\   'cmd': {server_info -> ['nix', 'shell', 'nixpkgs#pyright', '-c', 'pyright-langserver', '--stdio']},
\})

" Lua
let g:lsp_settings['lua-language-server'] = extend(get(g:lsp_settings, 'lua-language-server', {}), {
\   'cmd': s:nix_cmd('lua-language-server', 'lua-language-server'),
\})

" Nix
let g:lsp_settings['nil'] = extend(get(g:lsp_settings, 'nil', {}), {
\   'cmd': s:nix_cmd('nil', 'nil'),
\})

" YAML
let g:lsp_settings['yaml-language-server'] = extend(get(g:lsp_settings, 'yaml-language-server', {}), {
\   'cmd': {server_info -> ['nix', 'shell', 'nixpkgs#yaml-language-server', '-c', 'yaml-language-server', '--stdio']},
\})

" Docker
let g:lsp_settings['dockerfile-language-server'] = extend(get(g:lsp_settings, 'dockerfile-language-server', {}), {
\   'cmd': {server_info -> ['nix', 'shell', 'nixpkgs#dockerfile-language-server-nodejs', '-c', 'docker-langserver', '--stdio']},
\})

" TOML
let g:lsp_settings['taplo'] = extend(get(g:lsp_settings, 'taplo', {}), {
\   'cmd': s:nix_cmd('taplo', 'taplo'),
\})

" R LSP: ~/git/class/data 以下の場合はプロジェクトの nix-shell 経由で起動
let g:lsp_settings['r-languageserver'] = extend(get(g:lsp_settings, 'r-languageserver', {}), {
\   'cmd': {server_info ->
\     stridx(getcwd(), expand('~/git/class/data')) == 0
\       ? ['/run/current-system/sw/bin/nix-shell',
\          expand('~/git/class/data/shell.nix'),
\          '--run',
\          'R --slave -e languageserver::run()']
\       : ['R', '--slave', '-e', 'languageserver::run()']
\   },
\})

" vim-lsp-settings は lazyload されており、この時点で初期化
call lsp_settings#init()
