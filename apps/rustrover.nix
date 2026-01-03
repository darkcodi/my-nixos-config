{
  pkgs,
  unstable,
  ...
}: {
  home.packages = with unstable; [
    jetbrains.rust-rover
  ];

  # Set RustRover as default application for Rust files
  xdg.mimeApps.defaultApplications = {
    "text/rust" = ["jetbrains-rustrover.desktop"];
    "text/x-rust" = ["jetbrains-rustrover.desktop"];
    "application/x-rust" = ["jetbrains-rustrover.desktop"];
  };
}
