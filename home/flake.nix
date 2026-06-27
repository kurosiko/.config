{
  description = "Home Manager flake for kurosiko (mac, Linux, WSL, NixOS)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    {
      # Standalone (mac, Linux, WSL):
      #   nix run home-manager -- switch \
      #       --flake github:kurosiko/.config#kurosiko --impure
      homeConfigurations.kurosiko = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        extraSpecialArgs = { system = "x86_64-linux"; };
        modules = [ ./home.nix ];
      };

      # NixOS: configuration.nix uses:
      #   home-manager.users.kurosiko.imports = [ ./home/home.nix ];
      # or:
      #   imports = [ (builtins.getFlake "github:kurosiko/.config").outputs.nixosModules.home ];
      nixosModules.home = ./home.nix;
    };
}
