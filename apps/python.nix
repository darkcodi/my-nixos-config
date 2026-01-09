{pkgs, ...}: {
  home.packages = with pkgs; [
    # Python 3 interpreter with pip and venv support
    python3
  ];
}
