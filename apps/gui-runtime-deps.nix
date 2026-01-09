{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    webkitgtk_4_1
    webkitgtk_4_1.dev
    gtk3
    gtk3.dev
    gtk3-x11
    gdk-pixbuf
    gdk-pixbuf.dev
    glib
    glib.dev
    pango
    pango.dev
    cairo
    cairo.dev
    atk
    atk.dev
    at-spi2-atk
    at-spi2-atk.dev
    at-spi2-core
    at-spi2-core.dev
    libxkbcommon
    libxkbcommon.dev
    libepoxy
    libepoxy.dev
    wayland
  ];

  environment.pathsToLink = ["/lib/pkgconfig"];
}
