{pkgs, ...}: {
  home.packages = with pkgs; [
    # Rust toolchain
    rustc
    cargo
    rustfmt
    clippy

    # Additional Rust tools
    cargo-audit
    cargo-expand
    cargo-watch
    rust-analyzer
  ];
}
