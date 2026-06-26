# .config

Personal dotfiles managed in `~/.config`.

## Contents

- **ghostty/** - Terminal emulator config + theme
- **nix-config/** - nix-darwin system configuration
- **vim/** - Neovim/Vim config (vim-plug based)
- **yazi/** - Terminal file manager config
- **zsh/** - Shell config (zshrc, zprofile)
- **atcoder/** - AtCoder dev environment (nix flake, cpprun, tools)

## Setup

```bash
git clone --recurse-submodules https://github.com/kurosiko/.config.git ~/.config
ln -sf ~/.config/vim/vimrc ~/.vimrc
ln -sfn ~/.config/vim/config ~/.vim/config
ln -sfn ~/.config/vim/autoload ~/.vim/autoload
ln -sf ~/.config/zsh/.zshrc ~/.zshrc
ln -sf ~/.config/zsh/.zprofile ~/.zprofile
ln -sfn ~/.config/atcoder ~/atcoder
cd ~/atcoder && nix develop --impure
```
