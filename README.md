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
nix run home-manager/master -- switch \
    --flake ~/.config/home#kurosiko --impure
```

WSL2 only. The home-manager `.bash_profile` execs zsh for login bash
so every new terminal lands in zsh. Make it permanent with
`sudo chsh -s $(command -v zsh) $USER`.

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

Edit `home/flake.nix`:

```nix
homeConfigurations.yourname = home-manager.lib.homeManagerConfiguration {
  pkgs = import nixpkgs { system = "x86_64-linux"; };
  extraSpecialArgs = {
    system = "x86_64-linux";
    username = "yourname";
    homeDirectory = "/home/yourname";
  };
  modules = [ ./home.nix ];
};
```

Rename the attribute from `kurosiko` to `yourname` and use
`--flake .#yourname` in the switch command. `home.nix` does not need
editing — username is forwarded via `extraSpecialArgs`.

## Updating

```sh
# pull and rebuild
git -C ~/.config pull --recurse-submodules
cd ~/.config/home && nix run home-manager/master -- switch --flake .#kurosiko --impure

# bump pinned nixpkgs
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
- **WSL `sudo: a password is required`** — ensure the user is in
  the `sudo` group (`sudo usermod -aG sudo "$USER"`).
- **macOS `darwin-rebuild: command not found`** — log out and back in
  so `/etc/zprofile` is sourced.
- **macOS: `nix-darwin` cannot find host** — replace `WindowsVista`
  with `scutil --get LocalHostName`.
- **`error: Path 'flake.nix' is not tracked by Git`** — `git add
  flake.nix && git commit` inside the flake directory.
