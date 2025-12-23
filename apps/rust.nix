{pkgs, ...}: {
  home.packages = with pkgs; [
    # Rust toolchain
    rustc
    cargo
    rustfmt
    clippy

    # C compiler for crates that need C dependencies (like cc crate)
    gcc
    pkg-config

    # Additional Rust tools
    cargo-audit
    cargo-expand
    cargo-watch
    rust-analyzer
  ];
}
