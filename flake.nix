{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, home-manager, agenix, ... }:
    let
      system = "x86_64-linux";
      host = "misato";
      user = "darkcodi";
    in {
      nixosConfigurations.${host} = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${user} = {
              imports = [
                agenix.homeManagerModules.default
                ./home.nix
              ];
              programs.home-manager.enable = true;
              home.username = user;
              home.homeDirectory = "/home/${user}";
              home.stateVersion = "25.11";
            };
          }
        ];
      };
    };
}
