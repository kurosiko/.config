{ config, pkgs, lib, ... }:

{
  home.username = "kurosiko";
  home.homeDirectory = "/home/kurosiko";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

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
    profileExtra = ''
      # PATH is managed by home-manager; no homebrew on WSL
      if [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi
    '';
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
    # zsh/.zprofile が /opt/homebrew を eval するので
    # WSL では brew は無いので HOME_BREW を空にする
    HOME_BREW = "";
  };

  # dotfiles 既存のリポジトリ ( ~/.config/vim, ... ) を
  # home.file で symlink として配置 (重複管理を避ける)
  # .zshrc/.zprofile/.zshenv は programs.zsh が生成するため、ここでは扱わない
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
  };

  # 古い zsh の自動 exec chain と既存の zshrc/zprofile symlink は
  # home-manager 後は不要なので削除する (リンク衝突回避)
  home.activation.cleanupLegacyFiles = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    BASHRC="$HOME/.bashrc"
    if [ -f "$BASHRC" ] && grep -q "auto-launch zsh" "$BASHRC"; then
      ${pkgs.gnused}/bin/sed -i '/# --- auto-launch zsh (Nix) from bash login ---/,/# --- end zsh launch ---/d' "$BASHRC"
      echo "removed old zsh exec chain from .bashrc"
    fi
    for f in .zshrc .zprofile; do
      target="$HOME/$f"
      if [ -L "$target" ] || [ -e "$target" ]; then
        rm -f "$target"
        echo "removed legacy $f"
      fi
    done
  '';
}
