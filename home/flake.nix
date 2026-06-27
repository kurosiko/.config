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
      # Edit these two values to match your user, then:
      #   nix run home-manager -- switch --flake . --impure
      username = "kurosiko";
      homeDirectory = "/home/kurosiko";
      system = "x86_64-linux";
    in {
      homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; };
        extraSpecialArgs = { inherit system username homeDirectory; };
        modules = [ ./home.nix ];
      };

      nixosModules.home = ./home.nix;
    };
}
