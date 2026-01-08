{pkgs, ...}: {
  home.packages = with pkgs; [
    # Node.js 22 LTS ("Iron") - Released October 2024, maintained until April 2027
    # Includes npm package manager (built-in)
    nodejs_22

    # TypeScript compiler and toolchain
    typescript

    # Language servers for editor integration
    typescript-language-server
    vscode-langservers-extracted

    # Package managers
    yarn-berry
    nodePackages.pnpm

    # Additional Node.js development tools
    node2nix
    fx
  ];
}
