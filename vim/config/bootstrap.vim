" ------------------------------------------------------------
" vim-plug bootstrap
" If vim-plug isn't installed, this will download it on first run
" ------------------------------------------------------------
augroup vim_plug_bootstrap
  autocmd!
  if empty(glob('~/.vim/autoload/plug.vim'))
    silent execute '!curl -fLo ' . expand('~/.vim/autoload/plug.vim') . " --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
augroup END
