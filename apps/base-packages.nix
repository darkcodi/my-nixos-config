{pkgs, ...}: {
  home.packages = with pkgs; [
    ripgrep
    fd
    bat
    eza
    alejandra
    fzf
    jq
    yq
    tree
    age
    glow
  ];
}
