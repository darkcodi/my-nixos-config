{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    webkitgtk_4_1
    gtk3
    gtk3-x11
    gdk-pixbuf
    glib
    pango
    cairo
    atk
    at-spi2-atk
    at-spi2-core
    libxkbcommon
    libepoxy
    wayland
  ];
}
