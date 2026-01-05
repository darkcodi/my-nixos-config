{lib, ...}: {
  # ============================
  # Performance Optimizations
  # ============================

  # Binary caches - DRAMATICALLY speeds up rebuilds
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6ebFG5uMUzwInV3pXShvmwDagY4tRczN9PhqG5mxhjs="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimSvo6ov48y4zqeio6QZoMUa1C7PE/U="
  ];

  # Build with more cores (auto-detect)
  nix.settings.max-jobs = lib.mkDefault "auto";

  # Build remote builds (use other machines if available)
  nix.settings.builders-use-substitutes = true;

  # Keep build outputs for faster rebuilds
  nix.settings.keep-going = true;
  nix.settings.keep-outputs = true;

  # Regular garbage collection + prune old generations
  nix.gc = {
    automatic = true;

    # systemd.time(7) format; "weekly" is common
    dates = "weekly";

    # nice on laptops / fleets so everything doesn't hammer disk at once
    randomizedDelaySec = "15min";

    # this is the big one: deletes profiles generations older than N days
    options = "--delete-older-than 14d";
  };

  # Deduplicate the store (saves space; can take time on big stores)
  nix.optimise = {
    automatic = true;
    dates = ["weekly"];
  };
}
