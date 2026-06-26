# .config

Personal dotfiles managed in `~/.config`.

## Contents

- **ghostty/** - Terminal emulator config + theme
- **nix-config/** - nix-darwin system configuration
- **vim/** - Neovim/Vim config (vim-plug based)
- **yazi/** - Terminal file manager config
- **zsh/** - Shell config (zshrc, zprofile)
- **atcoder/** - AtCoder dev environment (nix flake, cpprun, tools)

## Prerequisites

- [Nix](https://determinate.systems/nix-installer/) (with flakes enabled)
- [nix-darwin](https://github.com/LnL7/nix-darwin) (macOS) or [NixOS](https://nixos.org)

## Setup

### 1. Clone dotfiles

```bash
git clone --recurse-submodules https://github.com/kurosiko/.config.git ~/.config
```

### 2. Symlink configs

```bash
ln -sf ~/.config/vim/vimrc ~/.vimrc
ln -sfn ~/.config/vim/config ~/.vim/config
ln -sfn ~/.config/vim/autoload ~/.vim/autoload
ln -sf ~/.config/zsh/.zshrc ~/.zshrc
ln -sf ~/.config/zsh/.zprofile ~/.zprofile
ln -sfn ~/.config/atcoder ~/atcoder
```

### 3. Build system with nix-darwin

```bash
cd ~/.config/nix-config
nix run nix-darwin -- switch --flake .#<hostname>
```

This installs all system packages (Neovim, Ghostty, yazi, etc.) and applies macOS system settings declaratively.

### 4. AtCoder environment

```bash
cd ~/atcoder && nix develop --impure
```

First time only: login via browser cookie.

```bash
setup
```
