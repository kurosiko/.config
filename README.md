# .config

Personal dotfiles. Fresh-install any of macOS / Ubuntu / WSL / NixOS to
a working zsh prompt with `nvim`, `yazi`, `fzf`, `eza`, `gh` in a few
terminal commands.

| Host | Tool | Config |
| --- | --- | --- |
| **macOS** | nix-darwin | `nix-config/` |
| **Ubuntu / WSL** | home-manager (standalone) | `home/` |
| **NixOS** | home-manager (NixOS module) | `home/` (imported) |

`vim/`, `zsh/`, `yazi/`, `ghostty/`, `atcoder/` are shared.

## macOS

```sh
xcode-select --install
curl -sSf -L https://install.determinate.systems/nix | sh -s -- install
# new terminal
git clone --recurse-submodules https://github.com/kurosiko/.config.git ~/.config
nix run nix-darwin -- switch --flake ~/.config/nix-config#WindowsVista
```

Edit the hostname in `~/.config/nix-config/flake.nix` to match
`scutil --get LocalHostName`. The first switch prompts for the macOS
password; after that use `darwin-rebuild switch --flake .#WindowsVista`.

## Ubuntu / WSL

```sh
sudo apt update && sudo apt install -y git curl
curl -sSf -L https://install.determinate.systems/nix | sh -s -- install
# new terminal
git clone --recurse-submodules https://github.com/kurosiko/.config.git ~/.config
nix run home-manager/master -- switch --flake ~/.config/home#kurosiko --impure
```

The `#kurosiko` after `#` is the flake's `homeConfigurations` attribute
name (see *Different username* below). WSL2 only. The home-manager
`.bash_profile` execs zsh for login bash so every new terminal lands in
zsh. Make it permanent with `sudo chsh -s $(command -v zsh) $USER`.

## NixOS

```sh
sudo nix-shell -p git --run 'true'
sudo git clone --recurse-submodules \
    https://github.com/kurosiko/.config.git /etc/dotfiles
sudo chown -R yourname:users /etc/dotfiles
```

Add to `/etc/nixos/configuration.nix`:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
imports = [
  (builtins.getFlake "git+https://github.com/kurosiko/.config").nixosModules.home
];
home-manager.users.yourname = { home.homeDirectory = "/home/yourname"; };
users.users.yourname.shell = pkgs.zsh;
```

Then `sudo nixos-rebuild switch`.

## Different username

Edit two values in `home/flake.nix`:

```nix
username = "yourname";             # <-- edit
homeDirectory = "/home/yourname";  # <-- edit (macOS: /Users/yourname)
```

The flake exposes `homeConfigurations.${username}`, so the attribute
name after `#` follows whatever you set. `home.nix` does not need to be
edited — username is forwarded via `extraSpecialArgs`.

## Updating

```sh
git -C ~/.config pull --recurse-submodules
cd ~/.config/home && nix run home-manager/master -- switch --flake .#kurosiko --impure
nix flake update
```

## Layout

```
~/.config/
├── home/                home-manager flake (Linux/WSL/NixOS)
├── nix-config/          nix-darwin flake (macOS)
├── vim/ zsh/ yazi/ ghostty/ atcoder/   shared configs
└── README.md
```

## Troubleshooting

- **`command 'nix' not found`** — close and reopen the terminal.
- **`fatal: not a git repository: .../nix-config`** — `git submodule
  update --init --recursive` from the repo root.
- **WSL `Nix requires WSL 2`** — `wsl.exe --set-version Ubuntu 2`
  (admin PowerShell).
- **WSL `sudo: a password is required`** — `sudo usermod -aG sudo "$USER"`.
- **macOS `darwin-rebuild: command not found`** — log out and back in.
- **macOS: `nix-darwin` cannot find host** — replace `WindowsVista`
  with `scutil --get LocalHostName`.
- **`error: Path 'flake.nix' is not tracked by Git`** — `git add
  flake.nix && git commit` inside the flake directory.
- **`#kurosiko` (or any `#name`) in the switch command** — that's the
  `homeConfigurations.<name>` flake output. Rename it by editing
  `username = "..."` at the top of `home/flake.nix`; the attribute
  follows automatically.
