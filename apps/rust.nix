{pkgs, ...}: {
  home.packages = with pkgs; [
    # Pinned Rust toolchain from rust-overlay
    # Version: 1.92.0 (stable, released December 11, 2025)
    # To update: Change version number and run `nix flake update`
    (rust-bin.stable."1.92.0".default.override {
      extensions = [
        "rust-src" # Standard library sources for rust-analyzer
        "rust-analyzer" # LSP server (also available separately)
        "rustfmt" # Code formatter
        "clippy" # Linter
      ];
    })

    # C compiler for crates with C dependencies (e.g., cc, openssl-sys)
    gcc
    pkg-config

    # Additional Rust development tools (from nixpkgs)
    cargo-audit # Security auditing for Cargo dependencies
    cargo-expand # Macro expansion for debugging
    cargo-watch # File watching for dev workflow
  ];
}
