# .config

Personal dotfiles managed in `~/.config`. Designed to bootstrap a freshly
installed OS to a working developer environment in a few terminal
commands. Login shells land in **zsh** on every supported host, and the
flake is parameterised so the same repo works for any Linux/WSL/macOS
user — not just `kurosiko`.

## Contents

- **home/** - Home Manager flake (Linux / WSL / NixOS)
- **nix-config/** - nix-darwin system configuration (macOS only)
- **vim/** - Neovim/Vim config (vim-plug based)
- **yazi/** - Terminal file manager config
- **zsh/** - Shell config (zshrc, zprofile)
- **ghostty/** - Terminal emulator config + theme
- **atcoder/** - AtCoder dev environment (nix flake, cpprun, tools)

## Architecture

| Host | Tool | Config | Purpose |
| --- | --- | --- | --- |
| **macOS** | `nix-darwin` | `nix-config/` | system settings (Dock, Finder, yabai, skhd) + packages |
| **Ubuntu / WSL** | `home-manager` (standalone) | `home/` | user packages + dotfile symlinks + zsh default |
| **NixOS** | `home-manager` (NixOS module) | `home/` (imported) | user packages + dotfile symlinks + zsh default |

The shared parts (`vim/`, `zsh/`, `yazi/`, `ghostty/`, `atcoder/`) are
plain files referenced by both `nix-config/` and `home/`.

## First-time setup: pick a username

The home-manager flake is parameterised by username and home directory.
The defaults are `kurosiko` / `/home/kurosiko`. To use a different
user, edit two values in `home/flake.nix`:

```nix
homeConfigurations.yourname = home-manager.lib.homeManagerConfiguration {
  pkgs = import nixpkgs { system = "x86_64-linux"; };
  extraSpecialArgs = {
    system = "x86_64-linux";
    username = "yourname";           # <-- edit
    homeDirectory = "/home/yourname"; # <-- edit (macOS: /Users/yourname)
  };
  modules = [ ./home.nix ];
};
```

…renaming the attribute from `kurosiko` to `yourname` as well. Then use
`#yourname` in the switch command below instead of `#kurosiko`.

## Per-OS quick start (fresh install)

Each section starts at "OS just installed, terminal open" and ends at a
working zsh prompt with `nvim`, `yazi`, `fzf`, `eza` on `PATH` and the
dotfiles symlinked.

### macOS

```sh
# 1. (one-time) install Xcode Command Line Tools — opens a dialog
xcode-select --install

# 2. (one-time) install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 3. open a new terminal (so nix is on PATH), then:
git clone --recurse-submodules https://github.com/kurosiko/.config.git ~/.config
# edit hostname in ~/.config/nix-config/flake.nix if not "WindowsVista"
nix run nix-darwin -- switch --flake ~/.config/nix-config#WindowsVista
```

`nix-darwin`'s `programs.zsh.enable = true` (in `nix-config/mac.nix`)
calls `chsh` for you — Terminal.app opens directly into zsh after the
first switch.

What you get:
- zsh as login shell
- system packages: neovim, yazi, ghostty, ffmpeg, deno, tmux, figlet, docker
- macOS defaults: Dock autohide, Finder extensions, trackpad tweaks
- yabai tiling WM + skhd hotkey daemon
- JetBrains Mono + Nerd Fonts system-wide
- direnv + nix-direnv

To apply shared dotfiles (`vim/`, `yazi/`, `ghostty/`, `zsh/`, `atcoder/`)
on macOS, see *Shared dotfiles on macOS* below.

### Ubuntu (22.04+, desktop or server)

```sh
# 1. (one-time) install git + curl
sudo apt update && sudo apt install -y git curl

# 2. (one-time) install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 3. open a new terminal (so nix is on PATH), then:
git clone --recurse-submodules https://github.com/kurosiko/.config.git ~/.config
nix run home-manager/master -- switch \
    --flake ~/.config/home#kurosiko \
    --impure
```

What you get:
- **zsh is your login shell** — `home.file.".bash_profile"` execs zsh
  for login bash (Ubuntu's default terminal opens a login bash, which
  hands off to zsh). If you have sudo, you can also `sudo chsh -s
  $(command -v zsh) $USER` to make this permanent at the OS level.
- user packages: neovim, yazi, ghostty, ripgrep, fd, bat, fzf, zoxide, eza,
  tmux, stow, zsh, figlet, ffmpeg, deno
- symlinks: `~/.vimrc` → repo, `~/.config/{zsh,vim,yazi,ghostty,atcoder}`
  → repo (managed by home-manager from the nix store)
- `EDITOR=nvim` is set in the home-manager session vars

### WSL (Ubuntu 22.04+)

```sh
# 1. (one-time) enable WSL on Windows PowerShell (admin):
#      wsl --install
#    then reboot, launch "Ubuntu" from the Start menu, create your user.

# 2. (one-time) install git + curl inside the WSL distro
sudo apt update && sudo apt install -y git curl

# 3. (one-time) install Nix (Determinate installer works without systemd)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 4. open a new WSL terminal (so nix is on PATH), then:
git clone --recurse-submodules https://github.com/kurosiko/.config.git ~/.config
nix run home-manager/master -- switch \
    --flake ~/.config/home#kurosiko \
    --impure
```

Same result as Ubuntu. Every new Windows Terminal / VS Code / Cursor
terminal opens a login bash, which execs into zsh via the home-manager
`.bash_profile`.

### NixOS (any install method)

After installing NixOS via the official ISO/USB and logging in:

```sh
# 1. (one-time) make sure git is available
sudo nix-shell -p git --run 'true'

# 2. (one-time) clone the repo as root
sudo git clone --recurse-submodules \
    https://github.com/kurosiko/.config.git /etc/dotfiles
sudo chown -R yourname:users /etc/dotfiles

# 3. add the home-manager integration to /etc/nixos/configuration.nix:
sudoedit /etc/nixos/configuration.nix
#   { pkgs, ... }: {
#     imports = [
#       (builtins.getFlake "git+https://github.com/kurosiko/.config").nixosModules.home
#     ];
#     home-manager.users.yourname = {
#       home.homeDirectory = "/home/yourname";
#     };
#     users.users.yourname.shell = pkgs.zsh;   # <-- makes zsh the real login shell
#   }

# 4. rebuild
sudo nixos-rebuild switch
```

What you get:
- the same user packages as Ubuntu/WSL
- the same dotfile symlinks
- **zsh is the real login shell** (`users.users.yourname.shell =
  pkgs.zsh`)
- no `--impure` flag needed — the NixOS module integration is pure

## Updating the configuration

After editing `home/home.nix` or `nix-config/*.nix`:

```sh
# macOS
cd ~/.config/nix-config
nix run nix-darwin -- switch --flake .#WindowsVista

# Ubuntu / WSL
cd ~/.config/home
nix run home-manager/master -- switch --flake .#kurosiko --impure

# NixOS (edit /etc/nixos/configuration.nix too)
sudo nixos-rebuild switch
```

## Shared dotfiles on macOS

`nix-config/` is system-level only — it does not symlink the shared
dotfiles into your home. To use the `vim/`, `yazi/`, `ghostty/`, `zsh/`,
`atcoder/` configs on macOS, add a `home-manager` block inside
`nix-config/`. Example (`nix-config/home.nix`, imported by
`nix-config/flake.nix`):

```nix
{ config, pkgs, ... }: {
  home = {
    username = "kurosiko";
    homeDirectory = "/Users/kurosiko";
    stateVersion = "24.11";
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = { ll = "eza -la"; ls = "eza"; grep = "rg"; cat = "bat"; };
  };
  home.file = let cfg = "/Users/kurosiko/.config"; in {
    ".vimrc"         = { source = "${cfg}/vim/vimrc"; force = true; };
    ".config/zsh"    = { source = "${cfg}/zsh"; recursive = true; force = true; };
    ".config/vim"    = { source = "${cfg}/vim"; recursive = true; force = true; };
    ".config/yazi"   = { source = "${cfg}/yazi"; recursive = true; force = true; };
    ".config/ghostty"= { source = "${cfg}/ghostty"; recursive = true; force = true; };
    ".config/atcoder"= { source = "${cfg}/atcoder"; recursive = true; force = true; };
  };
  home.packages = with pkgs; [ neovim yazi ripgrep fd bat fzf zoxide eza tmux ];
  home.sessionVariables = { EDITOR = "nvim"; VISUAL = "nvim"; };
}
```

Then in `nix-config/flake.nix`, add `nix-darwin`'s home-manager module
and import the new file. (See
[the nix-darwin + home-manager docs](https://nix-darwin.github.io/nix-darwin/manual/index.html#module-home-manager).)

## AtCoder environment

After bootstrapping any host:

```sh
cd ~/atcoder
nix develop --impure
```

First time only: log in via browser cookie.

```
setup
```

## Repository layout

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
- **`command 'nix' not found` after install** — close and reopen the
  terminal so the new `~/.nix-profile/etc/profile.d/nix.sh` is sourced.
- **WSL `sudo: a password is required`** — use the user you created when
  WSL first launched; sudo is not needed for `nix profile` or
  `home-manager` operations.
- **macOS: `nix-darwin` cannot find host** — edit `nix-config/flake.nix`
  and replace `WindowsVista` with `scutil --get LocalHostName`.
- **NixOS: `home-manager` complains about state version** — the first
  switch is allowed to bump `home.stateVersion`; later changes should not
  be made by hand.
- **`--impure` flag** — required on standalone home-manager because the
  `home.file` entries reference `$HOME/.config/...` by absolute path.
  On NixOS the module integration is pure and the flag is not needed.
- **Zsh is not my login shell after the first switch** — on Ubuntu/WSL
  the home-manager `.bash_profile` execs zsh for login bash, but
  `/etc/passwd` still lists bash. `chsh -s $(command -v zsh)` makes
  this permanent (or use the OS GUI on macOS). On NixOS, set
  `users.users.<name>.shell = pkgs.zsh` in `configuration.nix`.
- **Different username / home directory** — edit `home/flake.nix`'s
  `username` and `homeDirectory`, rename the `homeConfigurations` attr
  if desired, then `nix run home-manager -- switch --flake .#<attr>`.
