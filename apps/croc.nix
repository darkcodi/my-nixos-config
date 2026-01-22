{pkgs, ...}: {
  home.packages = with pkgs; [
    croc # Secure P2P file transfer tool
  ];
}
