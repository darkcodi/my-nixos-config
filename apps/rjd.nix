{pkgs, ...}: let
  src = pkgs.fetchgit {
    url = "https://github.com/darkcodi/rjd.git";
    rev = "v1.1.0";
    sha256 = "sha256-tsTP3SjOnaBJDqo5R/j+VscA9wve6tSElpzc2EdhsKI=";
  };
  rjd = pkgs.rustPlatform.buildRustPackage {
    pname = "rjd";
    version = "1.1.0";
    inherit src;
    cargoLock.lockFile = "${src}/Cargo.lock";
    cargoHash = "";
  };
in {
  home.packages = with pkgs; [
    rjd
  ];
}
