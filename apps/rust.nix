{pkgs, ...}: {
  home.packages = with pkgs; [
    # Pinned Rust nightly toolchain from rust-overlay
    # Version: nightly 2024-12-20
    #
    # To update: Change date and run `nix flake update`
    # To add targets: Add target triple to targets list (see examples below)
    #
    # Common targets:
    # - WebAssembly: wasm32-wasi, wasm32-unknown-unknown, wasm32-wasip1
    # - Embedded ARM: thumbv6m-none-eabi, thumbv7em-none-eabihf, thumbv7m-none-eabi
    # - Linux musl: x86_64-unknown-linux-musl, aarch64-unknown-linux-musl
    # - Cross: aarch64-unknown-linux-gnu, armv7-unknown-linux-gnueabihf
    # Full list: https://doc.rust-lang.org/nightly/rustc/platform-support.html
    (rust-bin.nightly."2025-12-11".default.override {
      extensions = [
        "rust-src" # Standard library sources for rust-analyzer and -Z build-std
        "rust-analyzer" # LSP server for IDE integration
        "rustfmt" # Code formatter
        "clippy" # Linting tool
      ];
      targets = [
        "x86_64-unknown-linux-musl" # Linux with musl libc (static linking)
        "thumbv6m-none-eabi" # Embedded ARM Cortex-M0/M0+
      ];
    })

    # C compiler for crates with C dependencies
    gcc
    pkg-config

    # Additional Rust development tools
    cargo-audit # Security auditing
    cargo-expand # Macro expansion debugging
    cargo-watch # File watching for dev workflow
  ];
}
