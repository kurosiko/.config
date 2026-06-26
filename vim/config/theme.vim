" ------------------------------------------------------------
" Theme — colorscheme, pum style, highlight overrides
" ------------------------------------------------------------
colorscheme catppuccin_mocha

" pum.vim options
call pum#set_option({
\ 'border': 'single',
\ 'max_height': 10,
\ 'scrollbar_char': '|',
\ 'highlight_columns': {
\ 'border': 'FloatBorder',
\ 'hightlight_winblend': 10,
\ },
\ })

" Highlight overrides applied after colorscheme to maintain custom colors
function! s:apply_highlight_overrides() abort
  " Catppuccin Mocha palette
  let s:pink    = "#F5C2E7"
  let s:mauve   = "#CBA6F7"
  let s:red     = "#F38BA8"
  let s:peach   = "#FAB387"
  let s:yellow  = "#F9E2AF"
  let s:green   = "#A6E3A1"
  let s:teal    = "#94E2D5"
  let s:sky     = "#89DCEB"
  let s:blue    = "#89B4FA"
  let s:text    = "#CDD6F4"
  let s:subtext = "#BAC2DE"
  let s:overlay0 = "#6C7086"
  let s:surface = "#313244"
  let s:base    = "#1E1E2E"
  let s:mantle  = "#181825"

  " ── ddc / popup menu styling ──────────────────────────────────
  execute 'highlight Pmenu       guifg=' . s:text    . ' guibg=' . s:surface . ' ctermbg=NONE'
  execute 'highlight PmenuSel    guifg=' . s:base    . ' guibg=' . s:blue    . ' ctermbg=blue'
  execute 'highlight PmenuSbar   guifg=' . s:surface . ' guibg=' . s:mantle  . ' ctermbg=black'
  execute 'highlight PmenuThumb  guifg=' . s:blue    . ' guibg=' . s:surface . ' ctermbg=blue'
  execute 'highlight PmenuBorder guifg=' . s:blue    . ' guibg=NONE ctermbg=NONE'
  execute 'highlight FloatBorder guifg=' . s:blue    . ' guibg=NONE ctermbg=NONE'

  " 補完マッチ部分の強調（Catppuccin green）
  execute 'highlight DdcPopupMatch guifg=' . s:green . ' gui=bold ctermfg=green'
  execute 'highlight PumMenuMatch  guifg=' . s:green . ' gui=bold ctermfg=green'
  execute 'highlight PmenuMatch    guifg=' . s:green . ' gui=bold ctermfg=green'

  " ── Syntax overrides (fine-tune beyond Catppuccin defaults) ───
  execute 'highlight Function  guifg=' . s:mauve  . ' gui=bold'
  execute 'highlight Type      guifg=' . s:yellow . ' gui=NONE'
  execute 'highlight Statement guifg=' . s:peach  . ' gui=NONE'
  execute 'highlight PreProc   guifg=' . s:peach  . ' gui=bold'

  " ── LSP diagnostic colors ──────────────────────────────────────
  execute 'highlight DiagnosticError guifg=' . s:red     . ' guibg=NONE gui=underline ctermfg=red'
  execute 'highlight DiagnosticWarn  guifg=' . s:peach   . ' guibg=NONE gui=bold     ctermfg=yellow'
  execute 'highlight DiagnosticInfo  guifg=' . s:sky     . ' guibg=NONE                ctermfg=cyan'
  execute 'highlight DiagnosticHint  guifg=' . s:subtext . ' guibg=NONE                ctermfg=gray'

  execute 'highlight LspDiagnosticsVirtualTextError       guifg=' . s:red     . ' guibg=NONE gui=underline'
  execute 'highlight LspDiagnosticsVirtualTextWarning     guifg=' . s:peach   . ' guibg=NONE gui=underline'
  execute 'highlight LspDiagnosticsVirtualTextInformation guifg=' . s:sky     . ' guibg=NONE'
  execute 'highlight LspDiagnosticsVirtualTextHint        guifg=' . s:subtext . ' guibg=NONE'

  " ── LSP Semantic Highlighting Links ────────────────────────────
  highlight! link LspSemanticClass Type
  highlight! link LspSemanticStruct Type
  highlight! link LspSemanticType Type
  highlight! link LspSemanticInterface Type
  highlight! link LspSemanticEnum Type
  highlight! link LspSemanticTypeParameter Type
  highlight! link LspNamespace Identifier

  " ── Fine-grained semantic highlighting (Catppuccin-tuned) ─────
  " Standard library variables (cout, cin, cerr, endl …)
  execute 'highlight LspSemanticDefaultLibraryVariable guifg=' . s:teal  . ' gui=bold'
  highlight! link LspSemanticVariable_defaultLibrary LspSemanticDefaultLibraryVariable

  " Standard library functions (printf, sort, swap …)
  execute 'highlight LspSemanticDefaultLibraryFunction guifg=' . s:mauve . ' gui=bold'
  highlight! link LspSemanticFunction_defaultLibrary LspSemanticDefaultLibraryFunction

  " Class/struct properties (pair.first, pair.second …)
  execute 'highlight LspSemanticProperty guifg=' . s:peach  . ' gui=italic'

  " Member methods (vec.push_back, str.substr …)
  execute 'highlight LspSemanticMethod guifg=' . s:mauve   . ' gui=bold'

  " Enum members (std::ios::in, color::red …)
  execute 'highlight LspSemanticEnumMember guifg=' . s:yellow . ' gui=italic'

  " Macros (#define …)
  execute 'highlight LspSemanticMacro guifg=' . s:red      . ' gui=bold'

  " Function parameters
  execute 'highlight LspSemanticParameter guifg=' . s:sky  . ' gui=italic'

  " Local variables
  execute 'highlight LspSemanticVariable guifg=' . s:text  . ' gui=NONE'

  " ── UI accents (CursorLine, Search, StatusLine, etc.) ─────────
  execute 'highlight MatchParen   cterm=bold,underline gui=underline guifg=' . s:peach . ' guibg=NONE'
  execute 'highlight ColorColumn  guifg=NONE guibg=' . s:mantle
  execute 'highlight CursorLineNr guifg=' . s:yellow . ' gui=bold'
  execute 'highlight LineNr       guifg=' . s:overlay0 . ' guibg=NONE'
  execute 'highlight CursorLine   guifg=NONE guibg=' . s:mantle
  execute 'highlight Visual       guifg=NONE guibg=' . s:surface
  execute 'highlight Search       guifg=' . s:base  . ' guibg=' . s:yellow
  execute 'highlight IncSearch    guifg=' . s:base  . ' guibg=' . s:peach
  execute 'highlight StatusLine   guifg=' . s:base  . ' guibg=' . s:sky   . ' gui=bold'
  execute 'highlight StatusLineNC guifg=' . s:subtext . ' guibg=' . s:mantle
  execute 'highlight VertSplit    guifg=' . s:surface . ' guibg=NONE'
  execute 'highlight SignColumn   guifg=NONE guibg=NONE'
  execute 'highlight FoldColumn   guifg=' . s:overlay0 . ' guibg=NONE'
  execute 'highlight Folded       guifg=' . s:subtext  . ' guibg=' . s:surface
  execute 'highlight NonText      guifg=' . s:overlay0 . ' guibg=NONE'
  execute 'highlight SpecialKey   guifg=' . s:overlay0 . ' guibg=NONE'
  execute 'highlight ErrorMsg     guifg=' . s:base    . ' guibg=' . s:red   . ' gui=bold'
  execute 'highlight WarningMsg   guifg=' . s:base    . ' guibg=' . s:peach . ' gui=bold'
  execute 'highlight MoreMsg      guifg=' . s:sky     . ' guibg=NONE gui=bold'
  execute 'highlight Question     guifg=' . s:green   . ' guibg=NONE gui=bold'
  execute 'highlight TabLine      guifg=' . s:subtext . ' guibg=' . s:mantle
  execute 'highlight TabLineSel   guifg=' . s:base    . ' guibg=' . s:sky   . ' gui=bold'
  execute 'highlight TabLineFill  guifg=' . s:overlay0 . ' guibg=' . s:mantle

  " Transparent background for startify (lets terminal background image show through)
  highlight clear StartifyBg
  highlight StartifyBg guibg=NONE ctermbg=NONE
endfunction

function! s:devicons_refresh() abort
  if exists('*vim_devicons_get_icon')
    " Hook into devicons so each colorscheme reapplies its colors
    if exists('g:loaded_devicons')
      let g:webdevicons_loaded = 1
    endif
  endif
endfunction

augroup my_highlight_overrides
  autocmd!
  autocmd ColorScheme * call s:apply_highlight_overrides()
  autocmd ColorScheme * call s:devicons_refresh()
augroup END

call s:apply_highlight_overrides()
call s:devicons_refresh()
