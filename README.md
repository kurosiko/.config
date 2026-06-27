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

## Prerequisites

Install these once per host, before following the per-OS section below.

### 1. Git identity (any host)

`home-manager` and `nix-darwin` will fail at the first `git commit`
inside the flake if your identity is not set.

```sh
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

### 2. GitHub authentication (for HTTPS push/pull)

The repo is `https://github.com/kurosiko/.config.git`. Cloning over
HTTPS is anonymous. For `git push` you need credentials — pick one:

```sh
# recommended: GitHub CLI (handles credential helper automatically)
sudo apt install gh        # Ubuntu/WSL
brew install gh            # macOS
gh auth login
```

…or use SSH keys: `gh auth login --git-protocol ssh` (or add
`~/.ssh/id_ed25519.pub` to https://github.com/settings/keys and set
`git remote set-url origin git@github.com:kurosiko/.config.git`).

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
`#yourname` in the switch command below instead of `#kurosiko`. There is
no need to edit `home.nix` — the username is forwarded via
`extraSpecialArgs`.

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

The first `nix run nix-darwin -- switch` will:

- prompt for your macOS password (it touches `/etc/zshenv`, `/etc/zprofile`,
  `/etc/sudoers.d`, and the Dock preferences via the `defaults` CLI)
- install `/run/current-system/sw/bin/darwin-rebuild` and add it to your
  shell `PATH` after the next login
- enable `programs.zsh.enable = true`, which runs `chsh -s /bin/zsh` for
  the user. After the next login Terminal.app will open into zsh.

Subsequent rebuilds can use the installed wrapper directly:

```sh
cd ~/.config/nix-config
darwin-rebuild switch --flake .#WindowsVista
```

If you prefer GUI apps to land in zsh immediately, set
*System Settings → Users & Groups → (right-click user) → Advanced Options
→ Login shell → /bin/zsh* (the same shell `nix-darwin` set via `chsh`).

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

WSL means **WSL2** — the Determinate Nix installer requires it. WSL1
will fail with "Nix requires WSL 2". Confirm with `wsl.exe -l -v` from
PowerShell: the `VERSION` column must show `2`.

#### A. Enable WSL

In an **Administrator** PowerShell:

```powershell
wsl --install
# reboot, then "Ubuntu" appears in the Start menu
```

On first launch, Ubuntu prompts for a UNIX username and password. That
user is automatically added to `sudo` and the `adm` group, so the steps
below work out of the box. If you are using a pre-existing distro
created by an older WSL release, ensure your account is in `sudo`:

```sh
sudo usermod -aG sudo "$USER"   # then close and reopen the terminal
```

To enable systemd (optional — needed by some services but not by
`nix-darwin`/`home-manager`):

```sh
sudo tee /etc/wsl.conf <<'EOF'
[boot]
systemd=true
EOF
# from PowerShell:
wsl.exe --shutdown
```

#### B. Install Nix and dotfiles

```sh
# 1. (one-time) install git + curl inside the WSL distro
sudo apt update && sudo apt install -y git curl

# 2. (one-time) install Nix (Determinate installer works without systemd)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 3. open a new WSL terminal (so nix is on PATH), then:
git clone --recurse-submodules https://github.com/kurosiko/.config.git ~/.config
nix run home-manager/master -- switch \
    --flake ~/.config/home#kurosiko \
    --impure
```

#### C. Editor integration (VS Code / Cursor)

Install the **WSL** extension in VS Code / Cursor on the Windows side,
then from inside WSL:

```sh
code .        # or `cursor .`
```

The first launch will download a small server into WSL; subsequent
runs are instant. Terminals opened from VS Code (Ctrl+`) are login
bash, which execs into zsh via the home-manager `.bash_profile`.

What you get (same as Ubuntu):
- **zsh is your login shell** for any terminal (Windows Terminal, VS Code,
  Cursor, plain `wsl.exe`)
- user packages and dotfile symlinks
- `EDITOR=nvim` is set in the home-manager session vars

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
#     # nix-command + flakes are required to evaluate the flake
#     nix.settings.experimental-features = [ "nix-command" "flakes" ];
#
#     # allow github:kurosiko/.config to resolve (newer NixOS only)
#     nix.registry.kurosiko.flake = github:kurosiko/.config;
#
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

Notes:
- The NixOS module integration is **pure** — no `--impure` flag is
  needed (and should not be used here).
- `nix.registry.kurosiko.flake = github:kurosiko/.config;` is only
  required on NixOS releases that don't pre-register the shorthand
  `github:kurosiko/.config` in the global flake registry. On
  24.11+ this is unnecessary; on 23.11 and earlier you need it.
- Do **not** also run `nix run home-manager -- switch --flake .#kurosiko
  --impure` on NixOS — that creates a standalone profile in parallel
  to the NixOS module and the two will conflict. Use the
  `configuration.nix` integration exclusively.

What you get:
- the same user packages as Ubuntu/WSL
- the same dotfile symlinks
- **zsh is the real login shell** (`users.users.yourname.shell =
  pkgs.zsh`)

## Updating the configuration

After editing `home/home.nix` or `nix-config/*.nix`:

```sh
# macOS
cd ~/.config/nix-config
darwin-rebuild switch --flake .#WindowsVista

# Ubuntu / WSL
cd ~/.config/home
nix run home-manager/master -- switch --flake .#kurosiko --impure

# NixOS (edit /etc/nixos/configuration.nix too)
sudo nixos-rebuild switch
```

To pull new commits from `origin` and rebuild in one step:

```sh
git -C ~/.config pull --recurse-submodules
# then run the appropriate switch command above
```

To bump the pinned `nixpkgs` / `home-manager`:

```sh
nix flake update            # bumps all inputs in flake.lock
nix flake update nixpkgs    # only nixpkgs
# then run the switch command
```

## Backing up existing dotfiles

If you already have files at `~/.zshrc`, `~/.vimrc`, etc., the home-manager
activation will overwrite them (the `home.file` blocks use `force = true`
so symlinks are recreated cleanly). To keep a one-off copy first:

```sh
# dry run shows what would change
nix run home-manager/master -- switch --flake ~/.config/home#kurosiko --impure --dry-run

# real run; the activation script backs up clobbered files to
# ~/.local/state/home-manager/bak.<timestamp>/ before linking
nix run home-manager/master -- switch --flake ~/.config/home#kurosiko --impure -b backup

# the `-b backup` option moves each conflict to
#   ~/.local/state/nix/profiles/home-manager-<timestamp>/
# (see `home-manager help switch` for the exact layout)
```

A non-destructive migration path:

1. `git clone --recurse-submodules https://github.com/kurosiko/.config.git ~/.config`
2. Inspect the diff: `git -C ~/.config status`
3. Manually back up anything you want to keep:
   `cp ~/.zshrc ~/.zshrc.before-hm && cp ~/.vimrc ~/.vimrc.before-hm`
4. Run the switch command.

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

The `.gitignore` excludes home-manager activation artefacts that are
per-user and not part of the dotfiles (`environment.d/`, `systemd/`,
`nix/`, `atcoder-cli-nodejs/`, `home/result`, `home/.direnv`).

## Troubleshooting

- **`error: Path 'flake.nix' is not tracked by Git`** — Nix flakes require
  the file to be tracked. Run `git add flake.nix && git commit` inside the
  flake directory.
- **`fatal: not a git repository: .../nix-config`** — submodule metadata
  is missing. Run `git submodule update --init --recursive` from the repo
  root.
- **`command 'nix' not found` after install** — close and reopen the
  terminal so the new `~/.nix-profile/etc/profile.d/nix.sh` is sourced.
  WSL users on Windows: close the Windows Terminal tab and reopen it
  (a new bash subprocess does not always re-source `~/.bashrc`).
- **WSL `sudo: a password is required`** — use the user you created when
  WSL first launched, and ensure they are in the `sudo` group
  (`sudo usermod -aG sudo "$USER"`). `nix profile` and `home-manager`
  themselves never need sudo.
- **WSL `Nix requires WSL 2`** — convert the distro with
  `wsl.exe --set-version Ubuntu 2` (PowerShell, admin) or reinstall via
  `wsl --install`.
- **macOS: `nix-darwin` cannot find host** — edit `nix-config/flake.nix`
  and replace `WindowsVista` with `scutil --get LocalHostName`.
- **macOS: `darwin-rebuild: command not found`** — the wrapper installs
  under `/run/current-system/sw/bin/`. After the first `nix-darwin`
  switch, log out and back in (or open a fresh Terminal tab) so
  `/etc/zprofile` is sourced and the new PATH is on `PATH`. Use
  `nix run nix-darwin -- switch --flake ...` until then.
- **NixOS: `home-manager` complains about state version** — the first
  switch is allowed to bump `home.stateVersion`; later changes should not
  be made by hand.
- **NixOS: `experimental-features` missing** — add
  `nix.settings.experimental-features = [ "nix-command" "flakes" ];`
  to `/etc/nixos/configuration.nix` (shown in the example above).
- **`--impure` flag** — required on standalone home-manager because the
  `home.file` entries reference `$HOME/.config/...` by absolute path.
  On NixOS the module integration is pure and the flag is not needed
  (and should not be used).
- **Zsh is not my login shell after the first switch** — on Ubuntu/WSL
  the home-manager `.bash_profile` execs zsh for login bash, but
  `/etc/passwd` still lists bash. `chsh -s $(command -v zsh)` makes
  this permanent (or use the OS GUI on macOS). On NixOS, set
  `users.users.<name>.shell = pkgs.zsh` in `configuration.nix`.
- **Different username / home directory** — edit `home/flake.nix`'s
  `username` and `homeDirectory`, rename the `homeConfigurations` attr
  if desired, then `nix run home-manager -- switch --flake .#<attr>`.
- **VS Code / Cursor does not see Nix tools inside WSL** — install the
  *WSL* extension on the Windows side, then run `code .` or `cursor .`
  from a WSL terminal. The first launch downloads a small server into
  WSL.
- **Yazi shows broken image previews** — make sure `chafa` and
  `ffmpeg` are on `PATH` (both come from the `home.packages` list in
  `home.nix`).
- **vim-plug download fails on first `nvim` launch** — `bootstrap.vim`
  fetches `https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim`
  with `curl`. If you are behind a corporate proxy, set `HTTPS_PROXY`
  before running `nvim` the first time.
- **Home-manager prints "N unread news items" on every switch** — run
  `home-manager news` once to read them. There is no flag to mute the
  notice, but the message itself is the only side effect.
