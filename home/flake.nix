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
    {
      # ----- Standalone (mac, Linux, WSL) -----
      # Edit the two fields below to match your user, then:
      #   nix run home-manager -- switch \
      #       --flake github:kurosiko/.config#kurosiko --impure
      # If your username is not kurosiko, also rename the attribute
      # (`kurosiko = ...` → `yourname = ...`) and pass `#yourname` above.
      homeConfigurations.kurosiko = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        extraSpecialArgs = {
          system = "x86_64-linux";
          username = "kurosiko";
          homeDirectory = "/home/kurosiko";
        };
        modules = [ ./home.nix ];
      };

      # ----- NixOS module -----
      # In /etc/nixos/configuration.nix:
      #   imports = [
      #     (builtins.getFlake "github:kurosiko/.config").nixosModules.home
      #   ];
      #   home-manager.users.yourname = { ... };
      nixosModules.home = ./home.nix;
    };
}
