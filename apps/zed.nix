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
      # Disable telemetry
      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      # Additional settings can be added here
      # ui_font_size = 16;
      # buffer_font_size = 16;
      # vim_mode = true;
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
