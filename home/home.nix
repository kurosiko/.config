{ config, pkgs, lib, ... }:

{
  home.username = "kurosiko";
  home.homeDirectory = "/home/kurosiko";
  home.stateVersion = "24.11";

  # Keep the OS-default shell. On macOS / Ubuntu / WSL this is bash.
  # On NixOS, leave it set by `users.users.<name>.shell`.
  # We only install CLI tools and manage dotfile symlinks here.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    neovim
    yazi
    ghostty
    ripgrep
    fd
    bat
    fzf
    zoxide
    eza
    tmux
    stow
    zsh
    figlet
    ffmpeg
    deno
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Symlink the shared dotfile directories from this repo into the home.
  # Force = true so re-running switch clobbers stale symlinks cleanly.
  home.file = let
    cfgDir = config.home.homeDirectory + "/.config";
  in {
    ".config/zsh" = {
      source = cfgDir + "/zsh";
      recursive = true;
      force = true;
    };
    ".config/vim" = {
      source = cfgDir + "/vim";
      recursive = true;
      force = true;
    };
    ".config/yazi" = {
      source = cfgDir + "/yazi";
      recursive = true;
      force = true;
    };
    ".config/ghostty" = {
      source = cfgDir + "/ghostty";
      recursive = true;
      force = true;
    };
    ".config/atcoder" = {
      source = cfgDir + "/atcoder";
      recursive = true;
      force = true;
    };
    ".vimrc" = {
      source = cfgDir + "/vim/vimrc";
      force = true;
    };
    ".atcoder" = {
      source = cfgDir + "/atcoder";
      force = true;
    };
  };

  # No shell mutation. The host's /etc/passwd + OS-default shell is
  # left alone so we never clobber ~/.zshrc / ~/.zprofile / ~/.bashrc.
}
