{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # WebKit and GTK
    webkitgtk_4_1
    webkitgtk_4_1.dev
    gtk3
    gtk3.dev
    gtk3-x11

    # Graphics and rendering
    gdk-pixbuf
    gdk-pixbuf.dev
    glib
    glib.dev
    pango
    pango.dev
    cairo
    cairo.dev

    # Accessibility
    atk
    atk.dev
    at-spi2-atk
    at-spi2-atk.dev
    at-spi2-core
    at-spi2-core.dev

    # Input and display
    libxkbcommon
    libxkbcommon.dev
    libepoxy
    libepoxy.dev
    wayland

    # Additional GTK dependencies
    harfbuzz
    harfbuzz.dev
    fontconfig
    fontconfig.dev
    fribidi

    # X11 libraries
    xorg.libX11
    xorg.libX11.dev
    xorg.libXext
    xorg.libXext.dev
    xorg.libXrender
    xorg.libXrender.dev
    xorg.libXi
    xorg.libXi.dev
    xorg.libXrandr
    xorg.libXrandr.dev
    xorg.libXcursor
    xorg.libXcursor.dev
    xorg.libXfixes
    xorg.libXfixes.dev
    xorg.libXcomposite
    xorg.libXcomposite.dev
    xorg.libXdamage
    xorg.libXdamage.dev
    xorg.libXinerama
    xorg.libXinerama.dev

    # WebKit2GTK dependencies (libsoup comes from webkitgtk_4_1)
    sqlite
    libxml2
    libxml2.dev
    nettle
    nettle.dev
    libtasn1

    # Additional system libraries (GStreamer)
    gst_all_1.gstreamer
    gst_all_1.gstreamer.dev
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-base.dev
  ];

  environment.pathsToLink = ["/lib/pkgconfig"];
}
