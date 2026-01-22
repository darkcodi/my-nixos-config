{pkgs, ...}: {
  home.packages = with pkgs; [
    gcolor3 # Simple GTK3 color picker that actually works on GNOME Wayland (uses xdg-desktop-portal)
  ];
}
