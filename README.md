# .config

Personal dotfiles managed in `~/.config`.

## Contents

- **ghostty/** - Terminal emulator config + theme
- **home/** - Home Manager flake (Linux / WSL / NixOS)
- **nix-config/** - nix-darwin system configuration (macOS only)
- **vim/** - Neovim/Vim config (vim-plug based)
- **yazi/** - Terminal file manager config
- **zsh/** - Shell config (zshrc, zprofile)
- **atcoder/** - AtCoder dev environment (nix flake, cpprun, tools)

## Architecture

This repo is split into three Nix entry points by host OS:

| Host | Tool | Config | Purpose |
| --- | --- | --- | --- |
| **macOS** | `nix-darwin` | `nix-config/` | system settings (Dock, Finder, yabai, skhd) + packages |
| **Linux / WSL** | `home-manager` (standalone) | `home/` | user packages, dotfile symlinks, shell config |
| **NixOS** | `home-manager` (NixOS module) | `home/` (imported) | user packages + dotfile symlinks |

The shared parts (`vim/`, `zsh/`, `yazi/`, `ghostty/`, `atcoder/`) are
plain files referenced by both `nix-config/` and `home/` via
`home.file.<path>.source = ../<dir>`.

## Prerequisites

Pick one package manager:

- [Nix](https://determinate.systems/nix-installer/) (recommended; required
  for `nix-darwin` and `home-manager`)
- Or the Determinate Nix installer, which enables flakes by default

Enable flakes if not already:

```sh
mkdir -p ~/.config/nix
cat > ~/.config/nix/nix.conf <<'EOF'
experimental-features = nix-command flakes
EOF
```

## Setup

### 1. Clone dotfiles

```sh
git clone --recurse-submodules https://github.com/kurosiko/.config.git ~/.config
```

### 2. Pick a host

#### macOS — nix-darwin

`nix-darwin` rebuilds `/etc`, `~/.config`, `~/Library/Application Support`
and installs system packages. It is **macOS only**.

```sh
# install nix-darwin once (the first time you use this repo on a Mac)
nix run nix-darwin -- switch --flake ~/.config/nix-config#<hostname>
```

Subsequent rebuilds after editing `nix-config/*.nix`:

```sh
cd ~/.config/nix-config
nix run nix-darwin -- switch --flake .#<hostname>
```

What this does:
- Installs system packages from `nix-config/system.nix` (Neovim, Ghostty,
  yazi, ffmpeg, deno, tmux, figlet, docker, …) into `/run/current-system/sw`
- Applies macOS defaults from `nix-config/mac.nix` (Dock autohide, Finder
  extensions, trackpad)
- Loads yabai tiling WM and skhd hotkey daemon from `nix-config/yabai.nix`
  and `nix-config/skhd.nix`
- Installs JetBrains Mono + Nerd Fonts system-wide
- Enables `programs.zsh` (login shell stays zsh) and `direnv` + `nix-direnv`
- Sets `nix.settings.experimental-features = nix-command flakes`

The current configuration targets host `WindowsVista`. Edit
`nix-config/flake.nix` to match your hostname (`scutil --get LocalHostName`).

To use the shared `vim/`, `yazi/`, `ghostty/`, `zsh/`, `atcoder/` dotfiles on
macOS, add the same `home.file.<path>.source = ../<dir>` block to a
home-manager module inside `nix-config/` (the existing `nix-config/*.nix`
is system-level only).

#### Linux / WSL — Home Manager (standalone)

Use this on plain Linux, WSL, or anywhere you have a user-mode Nix install
but no NixOS.

```sh
# install Home Manager once (downloads the master release)
nix run home-manager/master -- init --switch
# then point it at this repo's flake
nix run home-manager/master -- switch \
    --flake ~/.config/home#kurosiko \
    --impure
```

Notes:
- Edit `home/home.nix` to change `home.username` / `home.homeDirectory` if
  your user is not `kurosiko`. Rename the flake attribute in
  `home/flake.nix` to match.
- `--impure` is required because the `home.file` entries reference
  `$HOME/.config/...` by absolute path. If you prefer pure evaluation, move
  the dotfiles out of `~/.config` and update the `home.file.source` paths.
- An activation script (`home.activation.cleanupLegacyFiles`) removes any
  pre-existing `~/.zshrc` / `~/.zprofile` symlinks before home-manager
  regenerates them.
- After switch, your login shell is still bash. Add this to `~/.bashrc` so
  logins land in the home-manager zsh:

  ```sh
  if [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
  fi
  if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  fi
  if [ -z "$ZSH_RUNTIME" ] && [ -x "$HOME/.nix-profile/bin/zsh" ]; then
    export ZSH_RUNTIME=1
    exec "$HOME/.nix-profile/bin/zsh"
  fi
  ```

  Or, if you can `sudo chsh`, set the login shell to
  `$(command -v zsh)` directly.

To update the configuration after editing `home.nix`:

```sh
cd ~/.config/home
git add -A && git commit -m "update home"
nix run home-manager/master -- switch --flake .#kurosiko --impure
```

#### NixOS — Home Manager (NixOS module)

On NixOS, the `home-manager` module is built into `nixosModules`, so the
`--impure` flag is not needed and there is no separate `nix profile`
install.

Add to `/etc/nixos/configuration.nix`:

```nix
{ pkgs, ... }:
{
  imports = [ ~/.config/home/flake.nix ];
  # pick a username to deploy to
  home-manager.users.kurosiko = import ~/.config/home {
    inherit pkgs;
  };

  # or, if you want the home-manager flake's nixosModules integration
  # home-manager.users.kurosiko.imports = [ ~/.config/home/home.nix ];
}
```

Then:

```sh
sudo nixos-rebuild switch
```

The home-manager user environment replaces `nix-darwin` on Linux; both can
share the same `home.nix` module if you wire it up.

### 3. Symlink shared dotfiles (optional on macOS)

The `home/` module already creates these symlinks for Linux/WSL/NixOS. On
macOS, either hand-link or add a similar block to your nix-darwin home
module:

```sh
ln -sf ~/.config/vim/vimrc ~/.vimrc
ln -sfn ~/.config/vim/config ~/.vim/config
ln -sf ~/.config/zsh/.zshrc ~/.zshrc
ln -sf ~/.config/zsh/.zprofile ~/.zprofile
ln -sfn ~/.config/atcoder ~/atcoder
```

### 4. AtCoder environment

```sh
cd ~/atcoder
nix develop --impure
```

First time only: login via browser cookie.

```
setup
```

## How it fits together

```
~/.config/
├── .gitignore
├── .gitmodules                  # nix-config submodule
├── README.md                    # this file
├── atcoder/                     # shared nix flake (atcoder-cli, oj, aclogin)
├── ghostty/                     # shared config
├── home/                        # home-manager flake (Linux / WSL / NixOS)
│   ├── flake.nix
│   ├── flake.lock
│   └── home.nix
├── nix-config/                  # nix-darwin flake (macOS only)
│   ├── flake.nix
│   ├── flake.lock
│   ├── mac.nix
│   ├── system.nix
│   ├── yabai.nix
│   └── skhd.nix
├── vim/                         # shared config (vim-plug bootstrap)
├── yazi/                        # shared config
└── zsh/                         # shared config
    ├── .zshrc
    └── .zprofile
```

## Troubleshooting

- **`error: Path 'flake.nix' is not tracked by Git`** — Nix flakes require
  the file to be tracked. Run `git add flake.nix && git commit` inside the
  flake directory.
- **`fatal: not a git repository: .../nix-config`** — submodule metadata
  is missing. Run `git submodule update --init --recursive` from the repo
  root.
- **WSL `sudo: a password is required`** — the system Nix installer uses
  the `kurosiko` user; sudo is not needed for `nix profile` or
  `home-manager` operations.
- **macOS: `nix-darwin` cannot find host** — edit `nix-config/flake.nix`
  and replace `WindowsVista` with `scutil --get LocalHostName`.
