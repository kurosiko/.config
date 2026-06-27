{ config, pkgs, system, username, homeDirectory, ... }:

{
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "24.11";

  # ----- Shell: zsh by default, bash auto-launches it -----
  # On every supported host, login shells land in zsh. For hosts where
  # `chsh` is not possible (WSL without sudo, NixOS before first
  # `users.users.<name>.shell` is set), we make bash auto-exec zsh via
  # programs.bash.bashrcExtra so opening any terminal lands in zsh.
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "eza -la";
      la = "eza -a";
      ls = "eza";
      ".." = "cd ..";
      grep = "rg";
      cat = "bat";
    };
    initContent = ''
      if command -v zoxide >/dev/null 2>&1; then
        eval "$(zoxide init zsh)"
      fi
      if command -v fzf >/dev/null 2>&1; then
        source <(fzf --zsh) 2>/dev/null || true
        if [ -n "$FZF_SHARE" ] && [ -f "$FZF_SHARE/key-bindings.zsh" ]; then
          source "$FZF_SHARE/key-bindings.zsh"
          source "$FZF_SHARE/completion.zsh"
        fi
      fi
    '';
  };

  # bash stays installed and is the literal $SHELL on hosts where chsh
  # is unavailable. We do NOT use programs.bash.enable because that
  # would clobber the OS-default .bashrc. Instead we ship a tiny
  # .bash_profile that execs zsh on login — this works on WSL where
  # every new terminal launches a login bash, on NixOS before the
  # first `users.users.<name>.shell = pkgs.zsh` rebuild, and on macOS
  # for shells opened via Terminal.app's "login shell" preference.
  # We bundle that file into the home.file block below.

  # ----- Packages -----
  home.packages = with pkgs; [
    neovim
    vim
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
    gh
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # ----- Dotfile symlinks + .bash_profile -----
  # `force = true` so re-running switch clobbers stale symlinks cleanly.
  home.file = let cfgDir = homeDirectory + "/.config"; in {
    ".config/zsh"     = { source = cfgDir + "/zsh";     recursive = true; force = true; };
    ".config/vim"     = { source = cfgDir + "/vim";     recursive = true; force = true; };
    ".config/yazi"    = { source = cfgDir + "/yazi";    recursive = true; force = true; };
    ".config/ghostty" = { source = cfgDir + "/ghostty"; recursive = true; force = true; };
    ".config/atcoder" = { source = cfgDir + "/atcoder"; recursive = true; force = true; };
    ".vimrc"          = { source = cfgDir + "/vim/vimrc"; force = true; };
    ".atcoder"        = { source = cfgDir + "/atcoder"; force = true; };
    ".bash_profile" = {
      text = ''
        # Auto-launch zsh for login bash. Touched by home-manager so the
        # user lands in zsh even when chsh is not available.
        if [ -x "$HOME/.nix-profile/bin/zsh" ] && [ -z "$ZSH_RUNTIME" ]; then
          export ZSH_RUNTIME=1
          export SHELL="$HOME/.nix-profile/bin/zsh"
          exec "$HOME/.nix-profile/bin/zsh"
        fi
      '';
      force = true;
    };
  };
}
