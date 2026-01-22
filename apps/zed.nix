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

      # Custom theme color overrides
      theme_overrides = {
        "Ayu Mirage" = {
          syntax = {
            keyword = {
              color = "#FF0000";
              font_weight = "bold";
            };
            function = {color = "#00FF00";};
            type = {color = "#0000FF";};
            string = {color = "#FF00FF";};
            comment = {
              color = "#808080";
              font_style = "italic";
            };
            attribute = {color = "#00FFFF";};
            boolean = {
              color = "#FF8000";
              font_weight = "bold";
            };
            "comment.doc" = {
              color = "#606060";
              font_style = "italic";
            };
            constant = {color = "#8000FF";};
            constructor = {color = "#00FF80";};
            embedded = {color = "#FF0080";};
            emphasis = {
              color = "#80FF00";
              font_style = "italic";
            };
            "emphasis.strong" = {
              color = "#8000FF";
              font_weight = "bold";
            };
            enum = {color = "#FF8080";};
            hint = {color = "#8080FF";};
            label = {color = "#80FF80";};
            link_text = {
              color = "#0080FF";
              font_style = "underline";
            };
            link_uri = {
              color = "#FF80FF";
              font_style = "underline";
            };
            number = {color = "#FFFF00";};
            operator = {color = "#FF0080";};
            predictive = {
              color = "#A0A0A0";
              font_style = "italic";
            };
            preproc = {color = "#FFA500";};
            primary = {color = "#00BFFF";};
            property = {color = "#DC143C";};
            punctuation = {color = "#D3D3D3";};
            "punctuation.bracket" = {color = "#F0E68C";};
            "punctuation.delimiter" = {color = "#DDA0DD";};
            "punctuation.list_marker" = {color = "#98FB98";};
            "punctuation.special" = {color = "#F08080";};
            "string.escape" = {color = "#9370DB";};
            "string.regex" = {color = "#20B2AA";};
            "string.special" = {color = "#FFD700";};
            "string.special.symbol" = {color = "#FF6347";};
            tag = {color = "#32CD32";};
            "tag.doctype" = {
              color = "#708090";
              font_style = "italic";
            };
            "text.literal" = {color = "#B0C4DE";};
            title = {
              color = "#FF1493";
              font_weight = "bold";
            };
            variable = {color = "#F5F5DC";};
            "variable.special" = {color = "#DA70D6";};
            variant = {color = "#7FFFD4";};
          };
        };
      };

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
