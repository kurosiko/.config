{
  description = "Home Manager flake (mac, Linux, WSL, NixOS)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      # Single source of truth: edit these two values to match your
      # user, then run:
      #   nix run home-manager -- switch \
      #       --flake github:kurosiko/.config#${username} --impure
      username = "kurosiko";
      homeDirectory = "/home/kurosiko";
      system = "x86_64-linux";

      mkConfig = username: homeDirectory: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; };
        extraSpecialArgs = { inherit system username homeDirectory; };
        modules = [ ./home.nix ];
      };
    in {
      # Standalone (mac, Linux, WSL): the attribute name is the
      # username, so `homeConfigurations.<username>` matches your
      # OS user.
      homeConfigurations.${username} = mkConfig username homeDirectory;

      # NixOS: in /etc/nixos/configuration.nix
      #   imports = [
      #     (builtins.getFlake "github:kurosiko/.config").nixosModules.home
      #   ];
      #   home-manager.users.<username>.home.homeDirectory = "<homeDirectory>";
      nixosModules.home = ./home.nix;
    };
}
