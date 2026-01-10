{pkgs, ...}: let
  # Fetch create-tauri-app from crates.io
  # Latest version check: https://crates.io/crates/create-tauri-app
  src = pkgs.fetchCrate {
    pname = "create-tauri-app";
    version = "4.2.0";
    sha256 = "sha256-POJ/HcWpoXVQ6NvXeXo0cZUxFfMtKvzN9mqEYAM1Rqk=";
  };

  # Build using naersk (available via global overlay)
  create-tauri-app = pkgs.naersk.buildPackage {
    pname = "create-tauri-app";
    version = "4.2.0";
    inherit src;
  };
in {
  home.packages = with pkgs; [
    create-tauri-app
  ];
}
