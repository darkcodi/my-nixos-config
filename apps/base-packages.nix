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
  ];
}
