{pkgs, ...}: {
  home.packages = with pkgs; [
    _1password-cli # 1Password CLI tool (op command)
    ripgrep
    fd
    bat
    eza
    alejandra
    fzf
    jq
    yq
    tree
    unzip
    age
    glow
    helix
    xxd
    file # Determine file types by content analysis
    htop # Interactive process viewer
    bottom # Cross-platform graphical system monitor
    zenith # System monitor with zoomable charts and network/disk I/O
  ];
}
