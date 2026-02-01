{pkgs, ...}: {
  programs.zed-editor = {
    enable = true;

    # Extra packages available to Zed (e.g., LSP servers, formatters)
    extraPackages = with pkgs; [
      # Nix language support
      nixd
      nixpkgs-fmt

      # Rust (rust-analyzer included in rust toolchain, but needs PATH access)
      # Already in rust.nix, but making available to Zed

      # TypeScript/JavaScript (already in nodejs.nix)
      # typescript-language-server

      # Python language server & tooling
      basedpyright
      ruff

      # General formatters
      shfmt
      taplo
    ];

    # User settings written to settings.json
    userSettings = {
      # Theme
      theme = "Ayu Mirage";

      # Language-specific settings
      languages = {
        Rust = {
          colorize_brackets = true;
          show_whitespaces = "selection";
        };
      };

      # Disable telemetry
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
    };

    # Extensions to auto-install on startup
    extensions = [
      "nix" # Nix language support
      "toml" # TOML syntax highlighting
      "dockerfile" # Docker support
      "makefile" # Makefile support
      "yaml" # YAML syntax highlighting
    ];
  };
}
