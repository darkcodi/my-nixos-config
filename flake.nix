{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Unstable channel for packages not yet in stable (e.g., jetbrains.rust-rover)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";

    disko.url = "github:nix-community/disko";

    impermanence.url = "github:nix-community/impermanence";

    # Add rust-overlay for reproducible Rust toolchains
    rust-overlay.url = "github:oxalica/rust-overlay";

    # JetBrains plugins for IDE configuration
    nix-jetbrains-plugins.url = "github:nix-community/nix-jetbrains-plugins";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    agenix,
    disko,
    impermanence,
    rust-overlay,
    nix-jetbrains-plugins,
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

                  # Ensure agenix secrets are deployed before Home Manager activation
                  # Fixes race condition where activation runs before secrets are decrypted
                  systemd.user.services."home-manager-${cfg.user}" = {
                    Unit = {
                      After = "agenix.service";
                      Requires = "agenix.service";
                    };
                  };

                  # Make unstable packages available to home-manager configs
                  _module.args.unstable = import nixpkgs-unstable {
                    system = cfg.system;
                    config.allowUnfree = true; # JetBrains is unfree
                  };
                };
              }
            ];
          }
      )
      hosts;
  };
}
