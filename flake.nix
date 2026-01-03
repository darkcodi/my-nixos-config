{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";

    disko.url = "github:nix-community/disko";

    impermanence.url = "github:nix-community/impermanence";

    # Add rust-overlay for reproducible Rust toolchains
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    agenix,
    disko,
    impermanence,
    rust-overlay,
    ...
  }: let
    hosts = {
      misato = {
        system = "x86_64-linux";
        user = "darkcodi";
      };
      # Future machines - add as needed
      # rei = {
      #   system = "x86_64-linux";
      #   user = "darkcodi";
      # };
    };
  in {
    # Auto-generate NixOS configurations for all hosts
    nixosConfigurations =
      nixpkgs.lib.mapAttrs (
        hostName: cfg:
          nixpkgs.lib.nixosSystem {
            system = cfg.system;
            modules = [
              agenix.nixosModules.default
              impermanence.nixosModules.impermanence
              disko.nixosModules.disko
              ./hosts/${hostName}/disko.nix
              ./hosts/${hostName}/system.nix

              # Add rust-overlay to nixpkgs.overlays for global availability
              ({pkgs, ...}: {
                nixpkgs.overlays = [rust-overlay.overlays.default];
              })

              {
                _module.args.username = cfg.user;
              }

              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${cfg.user} = {
                  imports = [
                    agenix.homeManagerModules.default
                    ./hosts/${hostName}/user.nix
                  ];
                  home.username = cfg.user;
                  home.homeDirectory = "/home/${cfg.user}";
                  home.stateVersion = "25.11";
                  programs.home-manager.enable = true;
                };
              }
            ];
          }
      )
      hosts;
  };
}
