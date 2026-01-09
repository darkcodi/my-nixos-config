{pkgs, ...}: let
  src = pkgs.fetchgit {
    url = "https://github.com/darkcodi/ffcv.git";
    rev = "v1.1.1";
    sha256 = "sha256-AyVbYLNEg3BF2ehmdIYs4wVmpJ0Wx8L6wYly7kHkKL0=";
  };

  ffcv = pkgs.rustPlatform.buildRustPackage {
    pname = "ffcv";
    version = "1.1.1";
    inherit src;

    cargoLock.lockFile = "${src}/Cargo.lock";
    cargoHash = "";
  };
in {
  home.packages = with pkgs; [
    ffcv
  ];
}
